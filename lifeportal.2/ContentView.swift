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
    @State private var selectedCategory: String? = nil
    @State private var selectedTab = 0
    @State private var showExportView = false
    @State private var showAppearanceView = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab with particles
            ZStack {
                ParticleView()
                HomeView(
                    fullName: $fullName,
                    nickname: $nickname,
                    birthDate: $birthDate, 
                    isEditing: $isEditing,
                    selectedImage: $selectedImage,
                    showImagePicker: $showImagePicker,
                    selectedCategory: $selectedCategory,
                    showExportView: $showExportView,
                    showAppearanceView: $showAppearanceView,
                    saveImage: saveImage,
                    loadSavedImage: loadSavedImage,
                    deleteExistingProfileImage: deleteExistingProfileImage
                )
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            // Victories Tab
            ZStack {
                ParticleView()
                VictoriesView()
            }
            .tabItem {
                Image(systemName: "trophy.fill")
                Text("Victories")
            }
            .tag(1)
            
            // Kin Tab
            ZStack {
                ParticleView()
                KinView()
            }
            .tabItem {
                Image(systemName: "person.3.fill")
                Text("Kin")
            }
            .tag(2)
            
            // Memories Tab
            ZStack {
                ParticleView()
                MemoriesView()
            }
            .tabItem {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Memories")
            }
            .tag(3)
        }
        .accentColor(AppColors.accent)
        .onAppear {
            loadSavedImage()
            
            // Set tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            appearance.backgroundColor = UIColor(Color(hex: "#1A1A1D").opacity(0.92))
            
            // Set colors for the tab items
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.gray
            ]
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(AppColors.accent)
            ]
            
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            appearance.stackedLayoutAppearance.normal.iconColor = .gray
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.accent)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .sheet(isPresented: $showExportView) {
            ExportView(isPresented: $showExportView)
        }
        .sheet(isPresented: $showAppearanceView) {
            AppearanceView(isPresented: $showAppearanceView)
        }
    }

    private func saveImage() {
        guard let image = selectedImage else {
            if profileImageExists {
                deleteExistingProfileImage()
                profileImageExists = false
            }
            return
        }
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "profileImageData")
            profileImageExists = true
        }
    }
    
    private func loadSavedImage() {
        if profileImageExists, let imageData = UserDefaults.standard.data(forKey: "profileImageData") {
            if let uiImage = UIImage(data: imageData) {
                selectedImage = uiImage
            }
        }
    }
    
    private func deleteExistingProfileImage() {
        UserDefaults.standard.removeObject(forKey: "profileImageData")
        selectedImage = nil
    }
}

// Home View (extracted from the original ContentView)
struct HomeView: View {
    @Binding var fullName: String
    @Binding var nickname: String
    @Binding var birthDate: Date
    @Binding var isEditing: Bool
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    @Binding var selectedCategory: String?
    @Binding var showExportView: Bool
    @Binding var showAppearanceView: Bool
    var saveImage: () -> Void
    var loadSavedImage: () -> Void
    var deleteExistingProfileImage: () -> Void
    @State private var showCategoryDetail = false
    @State private var currentCategory: String = ""
    
    var body: some View {
        ZStack {
            // Background with subtle gradient to add depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1A1A1D"),
                    Color(hex: "#18191B")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Add particle effect above background but below content
            ParticleView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Area
                ZStack {
                    // Logo centered in the screen
                    HStack {
                        Spacer()
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        Spacer()
                    }
                    
                    // Settings icon positioned at the right
                    HStack {
                        Spacer()
                        Menu {
                            Button("Edit", action: { isEditing.toggle() })
                            Button("Export", action: { showExportView = true })
                            Button("Appearance", action: { showAppearanceView = true })
                            Button("App Details", action: { /* App details action */ })
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color.gray.opacity(0.6))
                                .padding()
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.trailing, 4)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Profile Section
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 6) {
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
                                        .foregroundColor(.white)
                                        .font(.custom("Unna-Regular", size: 36))
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(nickname)
                                        .foregroundColor(.gray)
                                        .font(.system(size: 18, weight: .light))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            Spacer()
                            
                            ProfileImageView(selectedImage: $selectedImage, isEditing: $isEditing, showImagePicker: $showImagePicker)
                                .frame(width: 110, height: 110)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        if isEditing {
                            HStack {
                                Spacer()
                                Button(action: {
                                    saveImage()
                                    isEditing = false
                                }) {
                                    Text("Save")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(AppColors.accent)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.trailing)
                        }
                        
                        // Timeline Section - Refined
                        TimelineView(birthDate: birthDate)
                            .padding(.horizontal)
                        
                        // Quick Actions section moved above Life Categories
                        VStack(alignment: .leading, spacing: 14) {
                            Text("QUICK ACTIONS")
                                .foregroundColor(.white)
                                .opacity(0.6)
                                .font(.custom("Teko-Regular", size: 12))
                                .padding(.leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // Add Goal quick action
                                    QuickActionButton(
                                        title: "Add Goal",
                                        icon: "target",
                                        color: AppColors.accent,
                                        action: { /* Add Goal action */ }
                                    )
                                    
                                    // Track Progress quick action
                                    QuickActionButton(
                                        title: "Track Habit",
                                        icon: "chart.line.uptrend.xyaxis",
                                        color: AppColors.accent,
                                        action: { /* Track Progress action */ }
                                    )
                                    
                                    // Journal Entry quick action
                                    QuickActionButton(
                                        title: "Journal",
                                        icon: "book.fill",
                                        color: AppColors.accent,
                                        action: { /* Journal Entry action */ }
                                    )
                                    
                                    // Calendar Event quick action
                                    QuickActionButton(
                                        title: "Schedule",
                                        icon: "calendar",
                                        color: AppColors.accent,
                                        action: { /* Calendar Event action */ }
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 5)
                        
                        // Life Categories Grid - Refined
                        VStack(alignment: .leading, spacing: 14) {
                            Text("LIFE CATEGORIES")
                                .foregroundColor(.white)
                                .opacity(0.6)
                                .font(.custom("Teko-Regular", size: 12))
                                .padding(.leading)
                            
                            // 2x2 Grid of category buttons with refined spacing
                            VStack(spacing: 14) {
                                // First row
                                HStack(spacing: 14) {
                                    // Personal Button
                                    CategoryButton(
                                        title: "Personal",
                                        icon: "person.fill",
                                        color: AppColors.accent,
                                        isSelected: selectedCategory == "PERSONAL",
                                        action: { 
                                            selectedCategory = "PERSONAL"
                                            currentCategory = "Personal"
                                            showCategoryDetail = true
                                        }
                                    )
                                    
                                    // Health Button
                                    CategoryButton(
                                        title: "Health",
                                        icon: "heart.fill",
                                        color: AppColors.accent,
                                        isSelected: selectedCategory == "HEALTH",
                                        action: { 
                                            selectedCategory = "HEALTH"
                                            currentCategory = "Health"
                                            showCategoryDetail = true
                                        }
                                    )
                                }
                                
                                // Second row
                                HStack(spacing: 14) {
                                    // Professional Button
                                    CategoryButton(
                                        title: "Professional",
                                        icon: "briefcase.fill",
                                        color: AppColors.accent,
                                        isSelected: selectedCategory == "PROFESSIONAL",
                                        action: { 
                                            selectedCategory = "PROFESSIONAL"
                                            currentCategory = "Professional"
                                            showCategoryDetail = true
                                        }
                                    )
                                    
                                    // Future Button
                                    CategoryButton(
                                        title: "Future",
                                        icon: "hourglass",
                                        color: AppColors.accent,
                                        isSelected: selectedCategory == "FUTURE",
                                        action: { 
                                            selectedCategory = "FUTURE"
                                            currentCategory = "Future"
                                            showCategoryDetail = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20) // Add padding to the bottom for separation from tab bar
                        }
                        .padding(.top, 10)
                        
                    }
                    .padding(.bottom, 10) // Increased to ensure content doesn't crowd the tab bar
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .fullScreenCover(isPresented: $showCategoryDetail) {
            CategoryDetailView(categoryName: currentCategory, isPresented: $showCategoryDetail)
        }
    }
}

// Victories View
struct VictoriesView: View {
    var body: some View {
        ZStack {
            // Background with subtle gradient to add depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1A1A1D"),
                    Color(hex: "#18191B")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Add particle effect above background
            ParticleView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Area
                ZStack {
                    // Logo centered in the screen
                    HStack {
                        Spacer()
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        Spacer()
                    }
                }
                .padding(.top, 12)
                
                Spacer() // Placeholder - keep content blank for now
            }
        }
    }
}

// Kin View
struct KinView: View {
    var body: some View {
        ZStack {
            // Background with subtle gradient to add depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1A1A1D"),
                    Color(hex: "#18191B")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Add particle effect above background
            ParticleView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Area
                ZStack {
                    // Logo centered in the screen
                    HStack {
                        Spacer()
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        Spacer()
                    }
                }
                .padding(.top, 12)
                
                Spacer() // Placeholder - keep content blank for now
            }
        }
    }
}

// Memories View
struct MemoriesView: View {
    var body: some View {
        ZStack {
            // Background with subtle gradient to add depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#1A1A1D"),
                    Color(hex: "#18191B")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Add particle effect above background
            ParticleView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Area
                ZStack {
                    // Logo centered in the screen
                    HStack {
                        Spacer()
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                        Spacer()
                    }
                }
                .padding(.top, 12)
                
                Spacer() // Placeholder - keep content blank for now
            }
        }
    }
}

// Timeline View Component
struct TimelineView: View {
    var birthDate: Date
    
    var body: some View {
        // Calculate age percentage for the timeline
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        let agePercentage = min(age, 100)
        
        return VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1E2221"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .frame(height: 72)
                .overlay(
                    VStack(spacing: 6) {
                        // Header section with label and percentage
                        HStack(spacing: 6) {
                            Text("LIFE PROGRESS")
                                .foregroundColor(.white)
                                .opacity(0.6)
                                .font(.custom("Teko-Regular", size: 12))
                            
                            Spacer()
                            
                            // Enhanced percentage display
                            ZStack {
                                Capsule()
                                    .fill(Color(hex: "#253835"))
                                    .frame(height: 24)
                                
                                HStack(spacing: 0) {
                                    Text("\(agePercentage)")
                                        .font(.custom("Teko-Regular", size: 13))
                                        .fontWeight(.medium)
                                    
                                    Text("%")
                                        .font(.custom("Teko-Regular", size: 13))
                                        .fontWeight(.medium)
                                        .baselineOffset(1)
                                }
                                .foregroundColor(AppColors.accent)
                                .padding(.horizontal, 8)
                            }
                            .fixedSize()
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 10)
                        
                        // Timeline bar
                        HStack(spacing: 0) {
                            // Birth circle
                            Circle()
                                .fill(AppColors.accent)
                                .frame(width: 6, height: 6)
                            
                            GeometryReader { geometry in
                                let totalWidth = geometry.size.width
                                let ageWidth = totalWidth * CGFloat(agePercentage) / 100
                                
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(AppColors.accent)
                                        .frame(width: ageWidth, height: 2)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: totalWidth - ageWidth, height: 2)
                                        .offset(x: ageWidth)
                                }
                            }
                            .frame(height: 2)
                            
                            // Death circle
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 6, height: 6)
                        }
                        .padding(.horizontal, 12)
                        
                        // Labels under the timeline
                        HStack {
                            Text("BIRTH")
                                .foregroundColor(.white)
                                .opacity(0.3)
                                .font(.custom("Teko-Regular", size: 8))
                            Spacer()
                            Text("DEATH")
                                .foregroundColor(.white)
                                .opacity(0.3)
                                .font(.custom("Teko-Regular", size: 8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                    }
                )
        }
    }
}

struct ProfileImageView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isEditing: Bool
    @Binding var showImagePicker: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .padding(18)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
            }
            
            if isEditing {
                Button("Change Image") {
                    showImagePicker = true
                }
                .foregroundColor(AppColors.accent)
                .font(.system(size: 12))
                
                Button("Remove") {
                    selectedImage = nil
                }
                .foregroundColor(Color.red.opacity(0.8))
                .font(.system(size: 12))
            }
        }
    }
}

// Category button used in the 2x2 grid
struct CategoryButton: View {
    var title: String
    var icon: String
    var color: Color
    var isSelected: Bool
    var action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    // Button background with subtle gradient
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: isSelected ? "#2A3633" : "#222A29"),
                                    Color(hex: isSelected ? "#253230" : "#1E2423")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 90)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? 
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                color.opacity(0.6),
                                                color.opacity(0.2)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "#2E3836").opacity(0.6),
                                                Color(hex: "#2E3836").opacity(0.3)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                    lineWidth: isSelected ? 1.5 : 1
                                )
                        )
                    
                    // Content with icon and text
                    VStack(spacing: 12) {
                        // Icon container
                        ZStack {
                            // Icon background
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: isSelected ? "#253532" : "#1B2220"))
                                .frame(width: 38, height: 38)
                            
                            // Icon with subtle gradient overlay for depth
                            Image(systemName: icon)
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(Color.white.opacity(0.9))
                        }
                        
                        // Title with improved typography
                        Text(title)
                            .font(.custom("Teko-Regular", size: 15))
                            .tracking(1.2)
                            .foregroundColor(.white)
                            .opacity(0.9)
                    }
                    .padding(.vertical, 14)
                }
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: {
            isPressed = true
        }, onRelease: {
            isPressed = false
        })
    }
}

// Quick Action button component
struct QuickActionButton: View {
    var title: String
    var icon: String
    var color: Color
    var action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icon with background - using rounded square instead of circle
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#222A29"),
                                    Color(hex: "#1B2220")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            color.opacity(0.6),
                                            color.opacity(0.2)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    // Add a subtle plus indicator to show it's an action
                    ZStack {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(color)
                            .offset(x: 12, y: -12)
                    }
                }
                
                // Title
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(0.75)
            }
            .frame(width: 85)
            .padding(.vertical, 8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: {
            isPressed = true
        }, onRelease: {
            isPressed = false
        })
    }
}

// Add a ViewModifier to handle press events
struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

// Extension for the pressEvents modifier
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
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

// Add this new ParticleView component
struct ParticleView: View {
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var size: CGFloat
        var opacity: Double
        var speed: CGFloat
        var direction: CGFloat // Angle in radians
        var color: Color
    }
    
    // Use environment object to preserve state across view redraws
    @EnvironmentObject var store: ParticleStore
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(store.particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .blendMode(.screen) // This helps make particles more visible
                }
            }
            .onAppear {
                if store.particles.isEmpty {
                    generateParticles(in: geometry.size)
                }
            }
            .onChange(of: geometry.size) { oldSize, newSize in
                // Only regenerate particles if the size changes substantially
                if abs(oldSize.width - newSize.width) > 50 || abs(oldSize.height - newSize.height) > 50 {
                    generateParticles(in: newSize)
                }
            }
            .onReceive(timer) { _ in
                updateParticles(in: geometry.size)
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        // Use an array of colors for more variety
        let colors = [
            AppColors.accent, // Dynamic accent color
            Color(hex: "#5B9BD5"), // Blue
            Color.white,          // White
            Color(hex: "#8E7CC3")  // Purple
        ]
        
        let particleCount = 30
        
        store.particles = (0..<particleCount).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                size: CGFloat.random(in: 2...5),
                opacity: Double.random(in: 0.1...0.3), // Increased opacity
                speed: CGFloat.random(in: 0.1...0.5), // Reduced speed range (was 0.3...1.2)
                direction: CGFloat.random(in: 0...(2 * .pi)),
                color: colors.randomElement() ?? Color.white
            )
        }
    }
    
    private func updateParticles(in size: CGSize) {
        guard !store.particles.isEmpty else { return }
        
        for i in 0..<store.particles.count {
            // Update position based on direction and speed
            let dx = store.particles[i].speed * cos(store.particles[i].direction)
            let dy = store.particles[i].speed * sin(store.particles[i].direction)
            var newPosition = CGPoint(
                x: store.particles[i].position.x + dx,
                y: store.particles[i].position.y + dy
            )
            
            // Slightly change direction occasionally to make movement more organic
            if Int.random(in: 0...100) < 5 {
                store.particles[i].direction += CGFloat.random(in: -0.2...0.2)
            }
            
            // Keep particles within bounds
            if newPosition.x < 0 {
                newPosition.x = size.width
            } else if newPosition.x > size.width {
                newPosition.x = 0
            }
            
            if newPosition.y < 0 {
                newPosition.y = size.height
            } else if newPosition.y > size.height {
                newPosition.y = 0
            }
            
            store.particles[i].position = newPosition
        }
    }
}

// Class to store and persist particles
class ParticleStore: ObservableObject {
    @Published var particles: [ParticleView.Particle] = []
}

#Preview {
    ContentView()
        .environmentObject(ParticleStore())
}

