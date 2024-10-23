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

struct AwardsView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red:229/255, green:229/255, blue:229/255), lineWidth:2))
        .padding(.horizontal)
    }
}

struct NewQuest: Identifiable {
    let id = UUID() // Unique identifier
    let title: String
    var currActions: Int
    let maxActions: Int
    let icon: String
    let iconColor: Color
    let completionPrompt: String? // Made optional to match one of the versions
    var isCompleted: Bool { currActions >= maxActions } // Completion status
    var points: Int { maxActions * 10 }
    var completionTime: String?
    var progress: Double { Double(currActions) / Double(maxActions) }
}

struct NewQuestView: View {
    let isDarkMode: Bool
    @Namespace private var animationNamespace
    @State private var quests: [NewQuest]

    // State for handling camera presentation and image selection
    @State private var isCameraPresented: Bool = false
    @State private var selectedQuest: NewQuest?
    @State private var selectedImage: UIImage?
    @State private var processingImage: Bool = false

    init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        _quests = State(initialValue: [
            NewQuest(title: "Use a reusable water bottle", currActions: 1, maxActions: 1, icon: "drop.fill", iconColor: .blue, completionPrompt: "Does the image contain a reusable water bottle? Please answer using just 'yes' or 'no'."),
            NewQuest(title: "Recycle 3 items", currActions: 2, maxActions: 3, icon: "arrow.3.trianglepath", iconColor: .purple, completionPrompt: "Does the image contain a recyclable item? Please answer using just 'yes' or 'no'."),
            NewQuest(title: "Take public transport", currActions: 3, maxActions: 5, icon: "bus.fill", iconColor: .green, completionPrompt: "Does the image contain a form of public transport? Please answer using just 'yes' or 'no'"),
        ])
    }

    var body: some View {
        ZStack {
            VStack {
                ForEach(quests.indices, id: \.self) { index in
                    questButton(for: index)
                    
                    // Divider between quests
                    if index < quests.count - 1 {
                        questDivider()
                    }
                }
            }
            .padding()
            .background(ThemeColors.Card.background(isDarkMode))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
            )
            .padding(.horizontal)
            .fullScreenCover(isPresented: $isCameraPresented) {
                CameraView(selectedImage: $selectedImage) // Pass binding to CameraView
            }
            .onChange(of: selectedImage) {
                if let image = selectedImage {
                    let base64Image = encodeImage(image: image)
                    processingImage = true
                    isCameraPresented = false
                    if let selectedQuest = selectedQuest {
                        print(selectedQuest.completionPrompt ?? "")
                        
                        // Call sendImageToOpenAI asynchronously
                        DispatchQueue.global(qos: .userInitiated).async {
                            let completed = sendImageToOpenAI(base64Image: base64Image, prompt: selectedQuest.completionPrompt ?? "")
                            
                            // Ensure any UI updates are done on the main thread
                            DispatchQueue.main.async {
                                print(completed)
                                processingImage = false
                                if (completed.lowercased().contains("yes")){
                                    if let index = quests.firstIndex(where: { $0.id == selectedQuest.id }) {
                                        if completed.lowercased().contains("yes") {
                                            quests[index].currActions += 1 // Update the actual quest's currActions
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Loading Screen ZStack
            if processingImage {
                Color.black.opacity(0.7) // Semi-transparent background
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white)) // White progress indicator
                        .padding()
                    
                    Text("Processing Quest")
                        .foregroundColor(.white) // Text color to match dark mode
                        .font(.headline)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the screen
            }
        }
    }

    @ViewBuilder
    private func questButton(for index: Int) -> some View {
        Button(action: {
            if !quests[index].isCompleted {
                isCameraPresented = true
                selectedQuest = quests[index]
            }
        }) {
            HStack(alignment: .center, spacing: 16) {
                questIcon(for: index)
                
                VStack(alignment: .leading, spacing: 13) {
                    questTitleAndPoints(for: index)
                    questProgressBar(for: index)
                }
                
                if !quests[index].isCompleted {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 0)
            .padding(.bottom, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func questIcon(for index: Int) -> some View {
        ZStack {
            Circle()
                .fill(quests[index].iconColor.opacity(0.15))
                .frame(width: 48, height: 48)
            
            Image(systemName: quests[index].icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(quests[index].iconColor)
        }
    }

    @ViewBuilder
    private func questTitleAndPoints(for index: Int) -> some View {
        HStack(alignment: .center) {
            Text(quests[index].title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.Content.primary(isDarkMode))
            
            Spacer()
            
            Text("+\(quests[index].points)pts")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(quests[index].isCompleted ? quests[index].iconColor : Color.gray.opacity(0.8))
                )
        }
        .padding(.top, 10)
    }

    @ViewBuilder
    private func questProgressBar(for index: Int) -> some View {
        NewProgressBar(
            currActions: quests[index].currActions,
            maxActions: quests[index].maxActions,
            color: quests[index].iconColor
        )
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func questDivider() -> some View {
        Divider()
            .frame(height: 2)
            .overlay(ThemeColors.Content.border(isDarkMode))
            .padding(.horizontal, -32)
            .padding(.vertical, 8)
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
