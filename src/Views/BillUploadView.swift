import SwiftUI
import PhotosUI

struct BillUploadView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var isScanning: Bool = false
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            if !isScanning {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.nexIndigo.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 40))
                            .foregroundColor(.nexIndigo)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Scan Receipt")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.nexSlate900)
                        Text("Snap a photo or upload a receipt to automatically split items and taxes.")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .padding(.top, 40)
            }
            
            if isScanning {
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Advanced Scanner UI
                    ZStack {
                        // Outer pulsating waves
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(Color.nexIndigo.opacity(0.2), lineWidth: 2)
                                .frame(width: 120, height: 120)
                                .scaleEffect(isScanning ? 2.5 : 1)
                                .opacity(isScanning ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 2)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(i) * 0.4),
                                    value: isScanning
                                )
                        }
                        
                        // Rotating gradient ring
                        Circle()
                            .strokeBorder(
                                AngularGradient(
                                    gradient: Gradient(colors: [.nexIndigo, .nexPurple, .nexIndigo]),
                                    center: .center
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 140, height: 140)
                            .rotationEffect(Angle(degrees: isScanning ? 360 : 0))
                            .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isScanning)
                        
                        // Inner circle
                        Circle()
                            .fill(Color.nexSlate50)
                            .frame(width: 120, height: 120)
                            .shadow(color: .nexIndigo.opacity(0.2), radius: 10)
                        
                        // Icon
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.nexPrimaryGradient)
                            .symbolEffect(.bounce, options: .repeating, value: isScanning)
                            .scaleEffect(isScanning ? 1.1 : 0.9)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isScanning)
                    }
                    
                    VStack(spacing: 16) {
                        Text("Analyzing Receipt")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.nexSlate900)
                        
                        Text("NexSplit AI is extracting items and prices...")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        HStack(spacing: 8) {
                            StatusPill(text: "Scanning", active: true)
                            StatusPill(text: "Processing", active: isScanning)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            } else {
                VStack(spacing: 20) {
                    // Camera Option
                    Button {
                        showingCamera = true
                    } label: {
                        UploadOptionCard(
                            icon: "camera.fill",
                            title: "Use Camera",
                            subtitle: "Take a fresh photo of your receipt",
                            color: .nexIndigo
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Gallery Option
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        UploadOptionCard(
                            icon: "photo.on.rectangle.angled",
                            title: "Choose from Gallery",
                            subtitle: "Select an existing photo or PDF",
                            color: .nexPurple
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Manual Entry Option
                    Button {
                        appState.startManualEntry()
                    } label: {
                        UploadOptionCard(
                            icon: "square.and.pencil",
                            title: "Manual Entry",
                            subtitle: "Enter receipt details without scanning",
                            color: .teal
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                
                if let error = error {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                NexButton("Go Back", variant: .outline) {
                    appState.navigate(to: .dashboard)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .background(Color.nexSlate50)
        .sheet(isPresented: $showingCamera) {
            CameraPicker(image: $capturedImage, isPresented: $showingCamera) { image in
                processCapturedImage(image)
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedItem) { _, newItem in
            if let newItem {
                processGalleryItem(newItem)
            }
        }
    }
    
    private func processCapturedImage(_ image: UIImage) {
        appState.billImage = image
        startScanning()
    }
    
    private func processGalleryItem(_ item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    appState.billImage = image
                    startScanning()
                }
            } else {
                await MainActor.run {
                    error = "Failed to load image from gallery."
                }
            }
        }
    }
    
    private func startScanning() {
        // Toggle off then on to restart animation if needed
        isScanning = false
        withAnimation {
            isScanning = true
        }
        error = nil
        
        Task {
            // Add a minimum delay to show off the fancy animation
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            do {
                try await appState.parseSelectedImage()
                await MainActor.run {
                    withAnimation {
                        isScanning = false
                        appState.navigate(to: .editor)
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation {
                        isScanning = false
                        self.error = "Scan failed: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

struct UploadOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        AppCard(padding: 24) {
            HStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.nexSlate900)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.nexSlate200)
            }
        }
    }
}

struct StatusPill: View {
    let text: String
    let active: Bool
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .black))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(active ? Color.nexIndigo.opacity(0.1) : Color.nexSlate50)
            .foregroundColor(active ? .nexIndigo : .nexSlate400)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(active ? Color.nexIndigo.opacity(0.2) : Color.nexSlate100, lineWidth: 1)
            )
    }
}

// MARK: - Camera Picker Component
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImageCaptured(uiImage)
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
