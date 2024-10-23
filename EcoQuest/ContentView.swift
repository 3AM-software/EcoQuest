import SwiftUI
import Foundation
import UIKit
import AVFoundation

#if targetEnvironment(simulator)
import MockImagePicker
typealias UIImagePickerController = MockImagePicker
typealias UIImagePickerControllerDelegate = MockImagePickerDelegate
#endif

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

struct ThemeColors {
    static let primary = Color(red: 22/255, green: 162/255, blue: 74/255)
    static let primaryGradient = [
        Color(red: 22/255, green: 162/255, blue: 74/255),
        Color(red: 17/255, green: 185/255, blue: 129/255)
    ]
    
    struct Background {
        static func primary(_ isDark: Bool) -> Color {
            isDark ? Color(red: 20/255, green: 31/255, blue: 37/255) : Color.white
        }
    }
    
    struct Content {
        static func primary(_ isDark: Bool) -> Color {
            isDark ? Color.white : Color.black
        }
        
        static func border(_ isDark: Bool) -> Color {
            isDark ? Color(red: 56/255, green: 70/255, blue: 80/255) : Color(red: 229/255, green: 229/255, blue: 229/255)
        }
    }
    
    struct Card {
        static func background(_ isDark: Bool) -> Color {
            isDark ? Color(red: 20/255, green: 31/255, blue: 37/255) : Color.white
        }
    }
}


struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                LoadingScreen() // Your loading screen view
            } else {
                MainApp() // Your main app view
            }
        }
        .onAppear {
            // Simulate loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        }
    }
}

struct MainApp: View {
    @State private var selectedTab: String = "Leaf"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        ZStack {
            ThemeColors.Background.primary(isDarkMode)
                            .ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderTitleView()
                ScrollView {
                    VStack(alignment: .center) {
                        // Switch view based on selected tab
                        if selectedTab == "Leaf" {
                            VStack(){
                                ProfileInfoView()
                                    .padding(.top, -70)
                                    .transition(.opacity)
                                StreakBadge(isDarkMode: isDarkMode)
                                    .transition(.opacity)
                                HStack {
                                    Text("Daily Quests")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    
                                    Image(systemName: "timer")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.orange)
                                        .frame(width:16, height:16)
                                    Text("24 hours")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal)
                                NewQuestView(isDarkMode: isDarkMode)
                                    .transition(.opacity)
                                    .padding(.bottom, 10)
                                HStack {
                                    Text("Your Impact")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    
                                    Menu {
                                        Button("This Month", action: {})
                                        Button("Last Month", action: {})
                                        Button("This Year", action: {})
                                    } label: {
                                        Text("This Month")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .fontWeight(.medium)
                                    }
                                }
                                .padding(.horizontal)
                                ImpactView(isDarkMode: isDarkMode)
                                    .transition(.opacity)
                            }
                        } else if selectedTab == "Awards" {
                            HStack {
                                Text("Completed Quests")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                Spacer()
                                
                                Text("2 Completed Quests")
                                    .foregroundColor(.green)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                            AwardsView()
                                .transition(.opacity)
                        } else if selectedTab == "Users" {
                            HStack {
                                Text("Profile")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            UserProfile(isDarkMode: isDarkMode)
                                .transition(.opacity)
                            HStack {
                                Text("Overview")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            UserOverview(isDarkMode: isDarkMode)
                                .transition(.opacity)
                                .padding(.bottom, 10)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
                bottomNavBar
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var bottomNavBar: some View {
        HStack {
            ForEach(["Leaf", "Awards", "Settings"], id: \.self) { icon in
                ZStack {
                    if selectedTab == icon {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.green, lineWidth:2))
                    }
                   Image(systemName: getSystemImage(for: icon))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                .foregroundColor(selectedTab == icon ? Color.green : .gray)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedTab = icon
                }
            }
        }
        .padding(.horizontal, 64)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(Color.gray.opacity(0.1))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2)),
            alignment: .top
        )
    }
    
    // Helper function for tab titles
    func tabTitle(for icon: String) -> String {
        switch icon {
        case "Leaf": return "Home"
        case "Awards": return "Awards"
        case "Settings": return "User"
        default: return ""
        }
    }
    
    // Helper function for system icons
    func getSystemImage(for icon: String) -> String {
        switch icon {
        case "Leaf": return "leaf.fill"
        case "Awards": return "medal.fill"
        case "Settings": return "gearshape.fill"
        default: return "leaf"
        }
    }
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
        .onChange(of: selectedImage) { image in
            if let image = image {
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

struct CameraView: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        Group {
            if camera.isSimulator {
                SimulatorCameraView(selectedImage: $selectedImage, dismiss: dismiss)
            } else {
                ZStack {
                    // Camera preview
                    if camera.permissionGranted {
                        CameraPreviewView(session: camera.session)
                            .ignoresSafeArea()
                    } else {
                        Text("Camera access not granted")
                            .foregroundColor(.red)
                    }
                    
                    // Capture button
                    if camera.permissionGranted {
                        VStack {
                            Spacer()
                            
                            // Capture button with outline
                            HStack{
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:24,height:24)
                                        .foregroundColor(.white)
                                        .padding()
                                        .padding(.leading,32)
                                }
                                Spacer()
                                Button {
                                    camera.captureImage { image in
                                        selectedImage = image
                                        dismiss()
                                    }
                                } label: {
                                    ZStack {
                                        // Outer circle outline
                                        Circle()
                                            .stroke(Color.white, lineWidth: 4)
                                            .frame(width: 70, height: 70)
                                        
                                        // Inner filled circle
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 60, height: 60)
                                            .shadow(radius: 5)
                                    }
                                }
                                .padding(.bottom, 10)
                                .padding(.leading, -32)
                                
                                // Cancel button
                                Spacer()
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:24,height:24)
                                        .foregroundColor(.clear)
                                        .padding()
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            camera.checkPermissionsAndSetup()
        }
        .onDisappear {
            camera.stopSession()
        }
    }
}

// Simulator specific view
struct SimulatorCameraView: View {
    @Binding var selectedImage: UIImage?
    var dismiss: DismissAction
    
    var body: some View {
        VStack {
            Text("Camera Not Available in Simulator")
                .font(.headline)
                .padding()
            
            Text("Select a test image instead:")
                .padding()
            
            Button("Select Test Image") {
                // Create a simple colored rectangle as a test image
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300))
                let testImage = renderer.image { context in
                    UIColor.blue.setFill()
                    context.fill(CGRect(x: 0, y: 0, width: 400, height: 300))
                    
                    // Add some text to the test image
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.white,
                        .font: UIFont.systemFont(ofSize: 24)
                    ]
                    let text = "Test Image"
                    text.draw(with: CGRect(x: 150, y: 130, width: 200, height: 40),
                            options: .usesLineFragmentOrigin,
                            attributes: attributes,
                            context: nil)
                }
                
                selectedImage = testImage
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
    }
}

class CameraModel: NSObject, ObservableObject {
    @Published var permissionGranted = false
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var completion: ((UIImage?) -> Void)?
    
    // Check if running on simulator
    let isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
    
    override init() {
        super.init()
        session.sessionPreset = .photo
    }
    
    func checkPermissionsAndSetup() {
        // Skip setup for simulator
        guard !isSimulator else { return }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            DispatchQueue.main.async { [weak self] in
                self?.permissionGranted = false
            }
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No camera device available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.permissionGranted = true
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.permissionGranted = false
            }
        }
    }
    
    func stopSession() {
        guard !isSimulator else { return }
        session.stopRunning()
    }
    
    func captureImage(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                    didFinishProcessingPhoto photo: AVCapturePhoto,
                    error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion?(nil)
            return
        }
        
        completion?(image)
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
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

struct ImpactView: View {
    let isDarkMode: Bool
    // MARK: - Properties
    let carbonSaved: Int = 2450
    let energySaved: Int = 384
    let waterSaved: Int = 1280
    let wasteReduced: Int = 86
    
    let co2String: String
    let energyString: String
    let waterString: String
    let wasteString: String
    
    // Animation states
    @State private var showCards = false
    @State private var selectedCard: Int? = nil
    @Namespace private var namespace
    
    // MARK: - Initialization
    init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        self.co2String = String(carbonSaved)
        self.energyString = String(energySaved)
        self.waterString = String(waterSaved)
        self.wasteString = String(wasteReduced)
    }
    
    // Card data
    let cards = [
            ImpactCardData(
                gradient: [Color(red: 16/255, green: 185/255, blue: 129/255),
                          Color(red: 5/255, green: 150/255, blue: 105/255)],
                color: Color.green.opacity(0.15),
                outline: Color.green,
                text: Color.green,
                icon: "leaf.fill",
                title: "CO₂ Saved",
                detail: """
                Your carbon savings are making a real difference:
                • Equivalent to 100 car trips avoided
                • Equal to planting 40 trees
                • Offset of 3 months of energy use
                
                Keep up the great work! Your daily choices are helping combat climate change.
                """
            ),
            ImpactCardData(
                gradient: [Color(red: 245/255, green: 158/255, blue: 11/255),
                          Color(red: 234/255, green: 138/255, blue: 0/255)],
                color: Color.yellow.opacity(0.15),
                outline: Color.yellow,
                text: Color.yellow,
                icon: "bolt.fill",
                title: "Energy Saved",
                detail: """
                Your energy conservation efforts:
                • Powered 38 homes for a day
                • Saved 384 kWh of electricity
                • Reduced peak grid demand
                
                These savings help reduce strain on power plants and promote sustainability.
                """
            ),
            ImpactCardData(
                gradient: [Color(red: 59/255, green: 130/255, blue: 246/255),
                          Color(red: 37/255, green: 99/255, blue: 235/255)],
                color: Color.blue.opacity(0.15),
                outline: Color.blue,
                text: Color.blue,
                icon: "drop.fill",
                title: "Water Saved",
                detail: """
                Your water conservation impact:
                • Saved 6,400 glasses of water
                • Equivalent to 32 full bathtubs
                • Protected vital water resources
                
                Every drop counts in preserving our planet's most precious resource.
                """
            ),
            ImpactCardData(
                gradient: [Color(red: 139/255, green: 92/255, blue: 246/255),
                          Color(red: 124/255, green: 58/255, blue: 237/255)],
                color: Color.purple.opacity(0.15),
                outline: Color.purple,
                text: Color.purple,
                icon: "arrow.3.trianglepath",
                title: "Waste Reduced",
                detail: """
                Your waste reduction achievements:
                • Prevented 430 plastic bags from landfills
                • Recycled 86 kg of materials
                • Saved valuable landfill space
                
                Your efforts help create a cleaner, more sustainable future.
                """
            )
        ]
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(Array(zip(cards.indices, cards)), id: \.0) { index, card in
                        OpaqueCompactCardView(
                            card: card,
                            value: getValue(for: index),
                            unit: getUnit(for: index),
                            show: showCards
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedCard = index
                            }
                        }
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
            
            // Full screen expanded card
            if let selected = selectedCard {
                ExpandedCardView(
                    card: cards[selected],
                    value: getValue(for: selected),
                    unit: getUnit(for: selected),
                    onClose: {
                        withAnimation(.easeInOut) {
                            selectedCard = nil
                        }
                    }
                )
                .zIndex(1)
                .transition(.move(edge: .bottom))
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures full screen fill
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            showCards = true // Show cards immediately without animation
        }
    }
    
    private func getValue(for index: Int) -> String {
        switch index {
        case 0: return co2String
        case 1: return energyString
        case 2: return waterString
        case 3: return wasteString
        default: return ""
        }
    }
    
    private func getUnit(for index: Int) -> String {
        switch index {
        case 0: return "kg"
        case 1: return "kWh"
        case 2: return "L"
        case 3: return "kg"
        default: return ""
        }
    }
}

// MARK: - Supporting Types
struct ImpactCardData {
    let gradient: [Color]
    let color: Color
    let outline: Color
    let text: Color
    let icon: String
    let title: String
    let detail: String
}

// MARK: - Compact Card View
struct CompactCardView: View {
    let card: ImpactCardData
    let value: String
    let unit: String
    let show: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: card.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: card.icon)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack {
                    Text(value)
                        .font(.system(size: 28))
                        .tracking(-0.5)
                        .fontWeight(.heavy)
                    Text(unit)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                
                Text(card.title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
            .padding(.leading, -15)
        }
        .frame(height: 140)
        .opacity(show ? 1 : 0)
    }
}

struct OpaqueCompactCardView: View {
    let card: ImpactCardData
        let value: String
        let unit: String
        let show: Bool

        var body: some View {
            ZStack {
                Color(card.color)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(card.outline, lineWidth: 1.5))
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: card.icon)
                        .font(.title2)
                        .foregroundColor(card.text)

                    HStack {
                        Text(value)
                            .font(.system(size: 28))
                            .tracking(-0.5)
                            .fontWeight(.heavy)
                            .foregroundColor(card.text)
                        Text(unit)
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(card.text)
                    }
                    .foregroundColor(.white)

                    Text(card.title)
                        .font(.subheadline)
                        .foregroundColor(card.text)
                        .opacity(0.8)
                }
                .padding(.leading, -15)
            }
            .frame(height: 140)
            .opacity(show ? 1 : 0)
        }
}

// MARK: - Expanded Card View
struct ExpandedCardView: View {
    let card: ImpactCardData
    let value: String
    let unit: String
    let onClose: () -> Void // Close action closure

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: card.icon)
                    .font(.title)
                    .foregroundColor(.white)
                Text(card.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: onClose) { // Close button
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(size: 48))
                    .fontWeight(.heavy)
                Text(unit)
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            
            
            Text(card.detail)
                .font(.body)
                .foregroundColor(.white)

                .multilineTextAlignment(.leading)
                .padding(.vertical)
        
            Spacer()
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: card.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.bottom)
        .transition(.move(edge: .bottom))
    }
}

struct HeaderTitleView: View {
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 22/255, green: 162/255, blue: 74/255),
                    Color(red: 17/255, green: 185/255, blue: 129/255)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 100)
            HStack {
                Text("EcoQuest")
                    .font(.system(size: 26))
                    .tracking(-0.5)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.white)
            }
            .padding([.leading, .trailing], 20.0)
            .padding(.top, 35)
        }
    }
}

struct ProfileInfoView: View {
    @State private var levelProgress: Double = 0.7
    let user: String = "Eco Warrior"
    let level: Int = 7
    let points: Int = 1250
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 22/255, green: 162/255, blue: 74/255),
                    Color(red: 17/255, green: 185/255, blue: 129/255)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 250)
            
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.yellow)
                            Text("Level 12 Warrior")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Text("Next: 550 pts")
                            .font(.subheadline)
                    }
                    
                    LevelProgressBar(progress: levelProgress)
                    
                    // Points Display
                    HStack {
                        HStack{
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width:24,height:24)
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("2,450")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Total Points")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("+125")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Today's Points")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(16)
            }
            .padding(.top, 40)
            .padding([.leading,.trailing])
        }
        .foregroundColor(.white)
    }
    
    
}

struct LevelProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.yellow)
                    .frame(width: geometry.size.width * progress, height: 12)
            }
        }
        .frame(height: 12)
    }
}

struct StreakBadge: View {
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Text("🔥")
            Text("15 Day Streak!")
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.Content.primary(isDarkMode))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(20)
        .shadow(color: isDarkMode ? .clear : .black.opacity(0.1), radius: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 1)
        )
        .offset(y: -20)
    }
}

struct UserOverview: View {
    var totalPoints: Int = 1200 // Example value
    var streak: Int = 5 // Example value
    let isDarkMode: Bool
    
    init(isDarkMode: Bool){
        self.isDarkMode = isDarkMode
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Rectangle for Total Points
                VStack(alignment: .center) {
                    Text("Graph Coming Soon")
                        .font(.headline)
                        .padding(.bottom, 2)
                }
                .frame(width: 150, height: 100) // Set your desired size
                .background(Color.white)
                .cornerRadius(10)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red:229/255, green:229/255, blue:229/255), lineWidth:2))
                Spacer()
            }
        }
        .padding()
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct UserProfile: View {
    @State private var showSettings = false
    let isDarkMode: Bool
    
    init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Arco23")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
                    Spacer()
                    
                    Button(action: {
                        showSettings.toggle() // Show settings when the gear icon is tapped
                    }) {
                        HStack {
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                            .presentationDetents([.medium, .fraction(0.75),.height(700)])
                    }
                }
                
                HStack {
                    Text("@Arco23")
                        .font(.body)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Joined October 2024")
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(ThemeColors.Card.background(isDarkMode))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
}

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(isDarkMode ? .blue : .yellow)
                            Text(isDarkMode ? "Dark Mode" : "Light Mode")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct LoadingScreen: View {
    @State private var progress: CGFloat = 0
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 22/255, green: 163/255, blue: 74/255),
                    Color(red: 21/255, green: 128/255, blue: 61/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // Logo Animation
                VStack(spacing: -10) {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
                        .onAppear {
                            self.isAnimating = true
                        }
                }
                .padding(.bottom, 20)

                Text("EcoQuest")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // Eco Tip Card
                VStack {
                    Text("🌿 Did You Know?")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Bamboo grows up to 35 inches per day, making it one of the most sustainable building materials on Earth. Using bamboo products helps reduce deforestation!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(10)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.bottom, 20)

                // Loading Bar
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 200, height: 10)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red:134/255,green:239/255,blue:172/255))
                        .frame(width: progress * 200 / 100, height: 10)
                        .animation(.linear(duration: 0.5), value: progress)
                        .padding(.top, -18)
                }
                .padding(.bottom, 10)

                Text("Loading your eco journey...")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .onAppear {
            // Simulate loading progress
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if self.progress < 100 {
                    self.progress += 20
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
