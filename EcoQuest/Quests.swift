import SwiftUI
import Foundation
import ConfettiSwiftUI

func encodeImage(image: UIImage) -> String {
    // Convert UIImage to JPEG data
    if let imageData = image.jpegData(compressionQuality: 1.0) { // Change to pngData() if needed
        return imageData.base64EncodedString()
    }
    return "";
}

func encodeJPEGImage(data: Data) -> String {
    let base64String = data.base64EncodedString()
    return "data:image/jpeg;base64,\(base64String)"
}


func sendImageToOpenAI(base64Image: String, prompt: String) -> String {

    let apiKey = "FRI"

    let url = URL(string: "POST https://api.moondream.ai/v1/query")!
    
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("your_api_key_here", forHTTPHeaderField: "X-Moondream-Auth")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Create the request body
    // Prepare individual components to simplify the main dictionary construction
    let modelKey = "model"
    let modelValue = "gpt-4o-mini"

    let roleKey = "role"
    let roleValue = "user"

    let contentKey = "content"
    let temperatureKey = "temperature"
    let temperatureValue: Double = 1
    let maxTokensKey = "max_tokens"
    let maxTokensValue = 4

    // Constructing the content array
    let textContent: [String: Any] = [
        "type": "text",
        "text": prompt // Use the prompt parameter
    ]

    let imageContent: [String: Any] = [
        "type": "image_url",
        "image_url": [
            "url": "data:image/jpeg;base64,\(base64Image)"
        ]
    ]

    let contentArray: [[String: Any]] = [textContent, imageContent]

    // Constructing the messages array
    let messages: [[String: Any]] = [
        [
            roleKey: roleValue,
            contentKey: contentArray
        ]
    ]

    // Constructing the final body dictionary
    let body: [String: Any] = [
        modelKey: modelValue,
        "messages": messages,
        temperatureKey: temperatureValue,
        maxTokensKey: maxTokensValue
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    // Create a semaphore to wait for the response
    let semaphore = DispatchSemaphore(value: 0)
    var result: String = "Failed to get a response" // Default value in case of failure
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            semaphore.signal()
            return
        }
        
        guard let data = data else {
            print("No data received.")
            semaphore.signal()
            return
        }
        print("here")
        // Handle the response
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            result = content // Store the response in the result variable
        } else {
            print("Failed to parse JSON.")
        }
        
        semaphore.signal() // Signal that the request is complete
    }
    
    task.resume()
    
    // Wait until the task signals that it's done
    semaphore.wait()
    return result // Return the result
}


func queryMoondream(base64Image: String, prompt: String) -> String {
    let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXlfaWQiOiIzNzY5NjViMC0wYjU1LTQwNDUtOGNiNS00MzYyMDZjMmQyNmUiLCJvcmdfaWQiOiI5SHhQRzhoUnVlT0ROZUp3aXZJYjRPY3JLa2M2TjlQZiIsImlhdCI6MTc0NDk0OTI4MywidmVyIjoxfQ.UBzHSQOf66Ythpp0pV_1Gp-FLeRu2MBfUAiL_x6-fwQ"
    let url = URL(string: "https://api.moondream.ai/v1/query")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue(apiKey, forHTTPHeaderField: "X-Moondream-Auth")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
        "image_url": base64Image,
        "question": prompt,
        "stream": false
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    let semaphore = DispatchSemaphore(value: 0)
    var result = "Failed to get response"

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer { semaphore.signal() }

        if let error = error {
            print("Request error: \(error)")
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
        }

        guard let data = data else {
            print("No data received.")
            return
        }
    
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let answer = json["answer"] as? String {
                result = answer
            } else {
                print("Invalid response format.")
            }
        } catch {
            print("Failed to parse JSON: \(error)")
        }
    }

    task.resume()
    semaphore.wait() // Wait for the response
    return result
}


struct NewQuest: Identifiable {
    let id = UUID() // Unique identifier
    let title: String
    var currActions: Int
    let maxActions: Int
    let icon: String
    let iconColor: Color
    let completionPrompt: String? // Made optional to match one of the versions
    let actionPrompt: String
    var isCompleted: Bool { currActions >= maxActions } // Completion status
    var points: Int { maxActions * 10 }
    var completionTime: String?
    var progress: Double { Double(currActions) / Double(maxActions) }
}

class GlobalState: ObservableObject {
    static let shared = GlobalState()
    
    @Published var processingImage: Bool = false
    @Published var showErrorMessage: Bool = false
    @Published var counter: Int = 0
    
    @Published var isLoggingOut = false
    
    private init() {}
}


struct NewQuestView: View {
    let isDarkMode: Bool
    @Namespace private var animationNamespace
    @State private var quests: [NewQuest]
    @ObservedObject var userViewModel: UserViewModel
    @State private var isCameraPresented: Bool = false
    @State private var selectedQuest: NewQuest?
    @State private var selectedImage: UIImage?
    @State private var processingImage: Bool = false
    @State private var processingQuestId: UUID?
    @State private var showErrorMessage: Bool = false
    @State private var errorQuestId: UUID?
    
    
    init(isDarkMode: Bool, userViewModel: UserViewModel) {
        self.isDarkMode = isDarkMode
        _quests = State(initialValue: [
            NewQuest(title: "Use a reusable water bottle", currActions: userViewModel.bottleActions, maxActions: 1, icon: "drop", iconColor: .blue, completionPrompt: "Does the image contain a reusable water bottle? Please answer using just 'yes' or 'no'.", actionPrompt: "reusableBottle"),
            NewQuest(title: "Recycle items", currActions: userViewModel.recycleActions, maxActions: 5, icon: "arrow.3.trianglepath", iconColor: .purple, completionPrompt: "Does the image contain a recyclable item? Please answer using just 'yes' or 'no'.", actionPrompt: "recyclableItem"),
            NewQuest(title: "Take public transport", currActions: userViewModel.transportAction, maxActions: 1, icon: "bus", iconColor: .green, completionPrompt: "Does the image contain a form of public transport? Please answer using just 'yes' or 'no'.", actionPrompt: "publicTransport"),
            NewQuest(title: "Plant a tree", currActions: userViewModel.treeAction, maxActions: 1, icon: "tree", iconColor: .brown, completionPrompt: "Does the image contain a newly planted tree? Please answer using just 'yes' or 'no'.", actionPrompt: "plantTree"),
            NewQuest(title: "Switch off unused lights", currActions: userViewModel.lightAction, maxActions: 4, icon: "lightbulb", iconColor: .yellow, completionPrompt: "Does the image show a set of lights that are turned off? Please answer using just 'yes' or 'no'.", actionPrompt: "switchLight")
        ])
        self.userViewModel = userViewModel
    }
    
    var body: some View {
        
        ZStack {
            QuestListView(
                quests: $quests,
                isDarkMode: isDarkMode,
                processingQuestId: processingQuestId,
                cameraAction: handleQuestSelection,
                errorQuestId: errorQuestId
            )
            .background(.clear)
            .cornerRadius(12)
            .padding(.horizontal)
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraView(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) {
                processImageSelection(selectedImage)
            }
        }
    }
    private func handleQuestSelection(_ quest: NewQuest) {
        if !quest.isCompleted {
            selectedQuest = quest
            isCameraPresented = true
        }
    }
    
    private func processImageSelection(_ image: UIImage?) {
        @ObservedObject var globalState = GlobalState.shared
        
        guard let image = image, let selectedQuest = selectedQuest else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG")
            return
        }
        
        let base64URI = encodeJPEGImage(data: imageData)
        
        globalState.processingImage = true
        isCameraPresented = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            let completed = queryMoondream(base64Image: base64URI, prompt: selectedQuest.completionPrompt ?? "analyze")
            
            DispatchQueue.main.async {
                globalState.processingImage = false
                processingQuestId = nil
                
                print("analzying")
                if completed.lowercased().contains("yes"),
                   let index = quests.firstIndex(where: { $0.id == selectedQuest.id }) {
                    withAnimation(.spring()) {
                        quests[index].currActions += 1
                        userViewModel.addActions(quests[index].actionPrompt)
                        if quests[index].isCompleted {
                            userViewModel.addPoints(quests[index].points)
                            globalState.counter += 1
                            print("yes", globalState.counter)
                        }
                    }
                } else {
                    withAnimation {
                        globalState.showErrorMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            globalState.showErrorMessage = false
                        }
                    }
                }
            }
        }
    }
    
    private func completeQuestManually(for quest: NewQuest) {
        @ObservedObject var globalState = GlobalState.shared
        
        if let index = quests.firstIndex(where: { $0.id == quest.id }) {
            withAnimation(.spring()) {
                quests[index].currActions += 1
                userViewModel.addActions(quests[index].actionPrompt)
                if quests[index].isCompleted {
                    userViewModel.addPoints(quests[index].points)
                    globalState.counter += 1
                }
            }
        }
    }
    
    // MARK: - Quest List View
    
    struct QuestListView: View {
        @Binding var quests: [NewQuest]
        let isDarkMode: Bool
        let processingQuestId: UUID?
        let cameraAction: (NewQuest) -> Void
        let errorQuestId: UUID? // Add this state variable
        
        var body: some View {
            VStack {
                ForEach(quests.indices, id: \.self) { index in
                    QuestButton(
                        quest: quests[index],
                        isDarkMode: isDarkMode,
                        isProcessing: processingQuestId == quests[index].id,
                        showErrorMessage: errorQuestId == quests[index].id,
                        onTap: { cameraAction(quests[index]) }
                    )
                    .padding(.bottom, 4)
                }
            }
            .padding(2)
        }
    }
    
    // MARK: - Quest Button
    
    struct QuestButton: View {
        let quest: NewQuest
        let isDarkMode: Bool
        let isProcessing: Bool
        let showErrorMessage: Bool // Add this parameter
        let onTap: () -> Void
        
        var body: some View {
            Button(action: onTap) {
                HStack(alignment: .center, spacing: 16) {
                    QuestIcon(quest: quest)
                    
                    VStack(alignment: .leading, spacing: 13) {
                        QuestTitleAndPoints(quest: quest, isDarkMode: isDarkMode)
                        QuestProgressBar(quest: quest)
                    }
                    
                    
                    if !quest.isCompleted {
                        
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .regular))
                    
                        
                    }
                    
                }
                .padding(8)
                .padding(.horizontal, 14)
                .background(ThemeColors.Card.background(isDarkMode))
                .cornerRadius(24)
                .overlay(
                    Group {
                        if isProcessing {
                            LoadingOverlay()
                                .padding([.leading, .trailing, .bottom], -16)
                                .padding(.top, -16)
                        }
                        if showErrorMessage { // Condition for error message
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 24))
                                
                                Text("You didn't meet the quest requirement!")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(ThemeColors.Card.background(isDarkMode))
                            .cornerRadius(8)
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                            .padding(.top, -16) // Adjust padding to align with loading overlay
                        }
                    }
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    
    // MARK: - Quest Icon
    
    struct QuestIcon: View {
        let quest: NewQuest
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(quest.iconColor)
                    .frame(width: 56, height: 56)
                ZStack {
                    Image(systemName: "\(quest.icon).fill")
                        .font(.system(size: 24, weight: .medium))
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(quest.iconColor)
                    Image(systemName: quest.icon)
                        .font(.system(size: 24, weight: .medium))
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Quest Title and Points
    
    struct QuestTitleAndPoints: View {
        let quest: NewQuest
        let isDarkMode: Bool
        
        var body: some View {
            HStack {
                Text(quest.title)
                    .font(.custom("Fredoka", fixedSize: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                
                Spacer()
                
                Text("+\(quest.points)pts")
                    .font(.custom("Fredoka", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(quest.isCompleted ? quest.iconColor : Color.gray.opacity(0.8))
                    )
            }
            .padding(.top, 10)
        }
    }
    
    // MARK: - Quest Progress Bar
    
    struct QuestProgressBar: View {
        let quest: NewQuest
        
        var body: some View {
            NewProgressBar(
                currActions: quest.currActions,
                maxActions: quest.maxActions
            )
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Quest Divider
    
    struct QuestDivider: View {
        let isDarkMode: Bool
        
        var body: some View {
            Divider()
                .frame(height: 2)
                .overlay(ThemeColors.Content.border(isDarkMode))
                .padding(.horizontal, -32)
                .padding(.vertical, 8)
        }
    }
    
    
    struct LoadingOverlay: View {
        var body: some View {
            ZStack {
                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea(.all)
                
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding()
                    
                    Text("Processing Quest")
                        .foregroundColor(.white)
                        .font(.custom("Fredoka", size: 20))
                        .fontWeight(.medium)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    struct NewProgressBar: View {
        let currActions: Int
        let maxActions: Int
        
        private var progress: Float {
            return maxActions > 0 ? Float(currActions) / Float(maxActions) : 0
        }
        
        private func textColor(in geometry: GeometryProxy) -> Color {
            let progressWidth = CGFloat(progress) * geometry.size.width
            let centerX = geometry.size.width / 2
            return progressWidth > centerX ? Color(red: 0.72, green: 0.55, blue: 0.11) : .gray
        }
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background Rectangle (2 pixels larger in all directions)
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.gray.opacity(0.2))
                        .frame(
                            width: geometry.size.width,
                            height: 26 // 2 pixels taller
                        )
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Gold Progress Rectangle (slightly inset to show border)
                    let inset: CGFloat = 6
                    let rawWidth = CGFloat(progress) * geometry.size.width - inset
                    let barWidth = max(rawWidth, 0)   // <-- prevents negative

                    RoundedRectangle(cornerRadius: 30)
                      .fill(Color(red: 1, green: 0.8, blue: 0.267))
                      .frame(width: barWidth, height: 20)
                      .padding(.leading, inset/2)
                      .padding(.vertical, 1)
                    
                    
                    // Text Overlay
                    Text("\(currActions)/\(maxActions)")
                        .foregroundColor(textColor(in: geometry))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.custom("Fredoka", size: 16))
                        .fontWeight(.bold)
                        .tracking(1.5)
                        .animation(.easeInOut(duration: 0.2), value: progress)
                }
            }
            .frame(height: 22) // Match background height
        }
    }
}
