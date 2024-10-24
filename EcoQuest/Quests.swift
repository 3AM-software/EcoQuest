import ConfettiSwiftUI
import SwiftUI

func encodeImage(image: UIImage) -> String {
    // Convert UIImage to JPEG data
    if let imageData = image.jpegData(compressionQuality: 1.0) { // Change to pngData() if needed
        return imageData.base64EncodedString()
    }
    return "";
}

// Function to send image and prompt to OpenAI
func sendImageToOpenAI(base64Image: String, prompt: String) -> String {
    let apiKey = "API_KEY"
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
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
    @State private var counter: Int = 0
    @State private var errorQuestId: UUID?
    
    
    init(isDarkMode: Bool, userViewModel: UserViewModel) {
        self.isDarkMode = isDarkMode
        _quests = State(initialValue: [
            NewQuest(title: "Use a reusable water bottle", currActions: userViewModel.bottleActions, maxActions: 1, icon: "drop.fill", iconColor: .blue, completionPrompt: "Does the image contain a reusable water bottle? Please answer using just 'yes' or 'no'.", actionPrompt: "reusableBottle"),
            NewQuest(title: "Recycle items", currActions: userViewModel.recycleActions, maxActions: 5, icon: "arrow.3.trianglepath", iconColor: .purple, completionPrompt: "Does the image contain a recyclable item? Please answer using just 'yes' or 'no'.", actionPrompt: "recyclableItem"),
            NewQuest(title: "Take public transport", currActions: userViewModel.transportAction, maxActions: 1, icon: "bus.fill", iconColor: .green, completionPrompt: "Does the image contain a form of public transport? Please answer using just 'yes' or 'no'.", actionPrompt: "publicTransport"),
            NewQuest(title: "Plant a tree", currActions: userViewModel.treeAction, maxActions: 1, icon: "tree.fill", iconColor: .brown, completionPrompt: "Does the image contain a newly planted tree? Please answer using just 'yes' or 'no'.", actionPrompt: "plantTree"),
            NewQuest(title: "Switch off unused lights", currActions: userViewModel.lightAction, maxActions: 4, icon: "lightbulb.fill", iconColor: .yellow, completionPrompt: "Does the image show a light switch being turned off? Please answer using just 'yes' or 'no'.", actionPrompt: "switchLight")
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
            
            .background(ThemeColors.Card.background(isDarkMode))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
            )
            .padding(.horizontal)
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraView(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) {
                processImageSelection(selectedImage)
            }
        }
        .confettiCannon(counter: $counter)
    }
    
    // MARK: - Helper Methods
    
    private func handleQuestSelection(_ quest: NewQuest) {
        if !quest.isCompleted {
            selectedQuest = quest
            isCameraPresented = true
        }
    }
    
    private func processImageSelection(_ image: UIImage?) {
        guard let image = image, let selectedQuest = selectedQuest else { return }
        let base64Image = encodeImage(image: image)
        
        processingQuestId = selectedQuest.id
        processingImage = true
        isCameraPresented = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            let completed = sendImageToOpenAI(base64Image: base64Image, prompt: selectedQuest.completionPrompt ?? "analyze")
            
            DispatchQueue.main.async {
                processingImage = false
                processingQuestId = nil
                
                if completed.lowercased().contains("yes"),
                   let index = quests.firstIndex(where: { $0.id == selectedQuest.id }) {
                    withAnimation(.spring()) {
                        quests[index].currActions += 1
                        userViewModel.addActions(quests[index].actionPrompt)
                        if quests[index].isCompleted {
                            userViewModel.addPoints(quests[index].points)
                            counter += 1
                        }
                    }
                } else {
                    withAnimation {
                        errorQuestId = selectedQuest.id
                        showErrorMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showErrorMessage = false
                            errorQuestId = nil
                        }
                    }
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
                    
                    if index < quests.count - 1 {
                        QuestDivider(isDarkMode: isDarkMode)
                    }
                }
            }
            .padding()
            .padding(.top, -4)
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
                    }
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
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
                Circle()
                    .fill(quest.iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: quest.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(quest.iconColor)
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
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.Content.primary(isDarkMode))
                
                Spacer()
                
                Text("+\(quest.points)pts")
                    .font(.subheadline)
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
                maxActions: quest.maxActions,
                color: quest.iconColor
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
                        .font(.headline)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    struct NewProgressBar: View {
        let currActions: Int
        let maxActions: Int
        let color: Color
        
        private var progress: Float {
            return maxActions > 0 ? Float(currActions) / Float(maxActions) : 0
        }
        
        private func textColor(in geometry: GeometryProxy) -> Color {
            let progressWidth = CGFloat(progress) * geometry.size.width
            let centerX = geometry.size.width / 2
            return progressWidth > centerX ? .white : .gray
        }
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background Rectangle
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Progress Rectangle
                    Rectangle()
                        .fill(color)
                        .frame(width: CGFloat(progress) * geometry.size.width, height: 16)
                        .cornerRadius(8)
                        .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: -1)
                    
                    // Text Overlay
                    Text("\(currActions)/\(maxActions)")
                        .foregroundColor(textColor(in: geometry))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .animation(.easeInOut(duration: 0.2), value: progress)
                }
            }
            .frame(height: 16)
        }
    }
}
