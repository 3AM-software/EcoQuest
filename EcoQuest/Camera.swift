import SwiftUI
import Foundation
import AVFoundation

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
                        // Display black screen with fake camera button
                        Color.black
                            .ignoresSafeArea()
                        VStack {
                            Spacer()
                            // Fake camera button
                            Button(action: {
                                // Action when the fake button is tapped (optional)
                                // You can show an alert or instructions for enabling permissions
                            }) {
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
                            .padding(.bottom, 40) // Add some space from the bottom
                        }
                    }

                    // Capture button - visible only if permission is granted
                    if camera.permissionGranted {
                        VStack {
                            Spacer()
                            HStack {
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.white)
                                        .padding()
                                        .padding(.leading, 32)
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
                                Spacer()
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
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
