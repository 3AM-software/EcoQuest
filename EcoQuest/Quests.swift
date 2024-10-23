import SwiftUI

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
    let currActions: Int
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

    init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        _quests = State(initialValue: [
            NewQuest(title: "Use a reusable water bottle", currActions: 1, maxActions: 1, icon: "drop.fill", iconColor: .blue, completionPrompt: "Does the image contain a reusable water bottle? Please answer using just 'yes' or 'no'."),
            NewQuest(title: "Recycle 3 items", currActions: 2, maxActions: 3, icon: "arrow.3.trianglepath", iconColor: .purple, completionPrompt: "Does the image contain a recyclable item? Please answer using just 'yes' or 'no'."),
            NewQuest(title: "Take public transport", currActions: 3, maxActions: 5, icon: "bus.fill", iconColor: .green, completionPrompt: "Does the image contain a form of public transport? Please answer using just 'yes' or 'no'"),
        ])
    }

    var body: some View {
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
                
                // Assuming you have a way to select the appropriate quest
                if let selectedQuest = selectedQuest {
                    print(selectedQuest.completionPrompt ?? "") // Print the completion prompt
                    // Here you can call your API or any other function
                    // let completed = sendImageToOpenAI(base64Image: base64Image, prompt: selectedQuest.completionPrompt)
                }
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
