import SwiftUI
import PhotosUI

struct ContentView: View {
    @AppStorage("fullName") private var fullName: String = ""
    @AppStorage("nickname") private var nickname: String = ""
    @AppStorage("birthDate") private var birthDate: Date = Date()
    @State private var isEditing = false
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @AppStorage("profileImageExists") private var profileImageExists: Bool = false

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1D")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    // Logo centered in the screen
                    HStack {
                        Spacer()
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 34)
                        Spacer()
                    }
                    
                    // Settings icon positioned at the right
                    HStack {
                        Spacer()
                        Menu {
                            Button("Edit", action: { isEditing.toggle() })
                            Button("Export", action: { /* Export action */ })
                            Button("Appearance", action: { /* Appearance action */ })
                            Button("App Details", action: { /* App details action */ })
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.trailing)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        if isEditing {
                            TextField("Full Name", text: $fullName)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .foregroundColor(.black)
                                .font(.title)

                            TextField("Nickname", text: $nickname)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .foregroundColor(.black)

                            DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                                .foregroundColor(.black)
                        } else {
                            Text(fullName)
                                .padding()
                                .foregroundColor(.white)
                                .font(.custom("Unna-Regular", size: 40))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(nickname)
                                .padding(.horizontal)
                                .foregroundColor(.gray)
                                .font(.system(size: 18, weight: .light))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    ProfileImageView(selectedImage: $selectedImage, isEditing: $isEditing, showImagePicker: $showImagePicker)
                        .padding(.top, 20)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(.horizontal)
                
                if isEditing {
                    HStack {
                        Spacer()
                        Button(action: {
                            saveImage()
                            isEditing = false
                        }) {
                            Text("Save")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.trailing)
                    .padding(.top, 10)
                }
                
                // Timeline Section
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        .frame(height: 60)
                        .overlay(
                            VStack(spacing: 8) {
                                HStack(spacing: 0) {
                                    // Birth circle
                                    Circle()
                                        .fill(Color(hex: "#3B8D85"))
                                        .frame(width: 10, height: 10)
                                    
                                    GeometryReader { geometry in
                                        let totalWidth = geometry.size.width
                                        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
                                        let ageWidth = totalWidth * CGFloat(age) / 100
                                        
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .fill(Color(hex: "#3B8D85"))
                                                .frame(width: ageWidth, height: 2)
                                            
                                            Rectangle()
                                                .fill(Color.gray)
                                                .frame(width: totalWidth - ageWidth, height: 2)
                                                .offset(x: ageWidth)
                                        }
                                    }
                                    .frame(height: 2)
                                    
                                    // Death circle
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 10, height: 10)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                HStack {
                                    Text("BIRTH")
                                        .foregroundColor(.white)
                                        .opacity(0.2)
                                        .font(.custom("Teko-Regular", size: 8))
                                    Spacer()
                                    Text("DEATH")
                                        .foregroundColor(.white)
                                        .opacity(0.2)
                                        .font(.custom("Teko-Regular", size: 8))
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 8)
                            }
                        )
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onAppear {
            loadSavedImage()
        }
    }

    private func saveImage() {
        guard let image = selectedImage else {
            // If no image is selected, clear any saved image
            if profileImageExists {
                deleteExistingProfileImage()
                profileImageExists = false
            }
            return
        }
        
        // Convert image to JPEG data
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            // Save to UserDefaults
            UserDefaults.standard.set(imageData, forKey: "profileImageData")
            profileImageExists = true
        }
    }
    
    private func loadSavedImage() {
        // Check if there's image data in UserDefaults
        if profileImageExists, let imageData = UserDefaults.standard.data(forKey: "profileImageData") {
            // Create UIImage from data
            if let uiImage = UIImage(data: imageData) {
                selectedImage = uiImage
            }
        }
    }
    
    private func deleteExistingProfileImage() {
        // Remove the image data from UserDefaults
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        selectedImage = nil
    }
}

struct ProfileImageView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isEditing: Bool
    @Binding var showImagePicker: Bool
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    .shadow(radius: 3)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .padding(25)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    .shadow(radius: 3)
            }
            
            if isEditing {
                Button("Change Image") {
                    showImagePicker = true
                }
                .foregroundColor(.blue)
                
                Button("Remove Image") {
                    selectedImage = nil
                }
                .foregroundColor(.red)
            }
        }
    }
}

// ImagePicker implementation
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}

// Helper to use hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let scanner = Scanner(string: hex)
        if hex.hasPrefix("#") { scanner.currentIndex = scanner.string.index(after: scanner.currentIndex) }
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
