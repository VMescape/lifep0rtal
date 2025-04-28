import SwiftUI
import UniformTypeIdentifiers

// Structure to hold all exportable app data
struct LifePortalData: Codable {
    var profileData: ProfileData
    var categoryData: CategoryData
    var exportDate: Date = Date()
    var appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
}

// Profile data structure
struct ProfileData: Codable {
    var fullName: String
    var nickname: String
    var birthDate: Date
    var profileImage: Data?
}

// Category data structure
struct CategoryData: Codable {
    var personal: [CategoryItem]
    var health: [CategoryItem]
    var professional: [CategoryItem]
    var future: [CategoryItem]
}

class DataExporter {
    static func exportData() {
        // Get data from UserDefaults
        let fullName = UserDefaults.standard.string(forKey: "fullName") ?? ""
        let nickname = UserDefaults.standard.string(forKey: "nickname") ?? ""
        let birthDate = UserDefaults.standard.object(forKey: "birthDate") as? Date ?? Date()
        let profileImageData = UserDefaults.standard.data(forKey: "profileImageData")
        
        // Get category items data
        let personalItemsData = UserDefaults.standard.data(forKey: "personalItems") ?? Data()
        let healthItemsData = UserDefaults.standard.data(forKey: "healthItems") ?? Data()
        let professionalItemsData = UserDefaults.standard.data(forKey: "professionalItems") ?? Data()
        let futureItemsData = UserDefaults.standard.data(forKey: "futureItems") ?? Data()
        
        // Initialize empty category arrays
        var personalItems: [CategoryItem] = []
        var healthItems: [CategoryItem] = []
        var professionalItems: [CategoryItem] = []
        var futureItems: [CategoryItem] = []
        
        // Decode category data if available
        if !personalItemsData.isEmpty {
            if let items = try? JSONDecoder().decode([CategoryItem].self, from: personalItemsData) {
                personalItems = items
            }
        }
        
        if !healthItemsData.isEmpty {
            if let items = try? JSONDecoder().decode([CategoryItem].self, from: healthItemsData) {
                healthItems = items
            }
        }
        
        if !professionalItemsData.isEmpty {
            if let items = try? JSONDecoder().decode([CategoryItem].self, from: professionalItemsData) {
                professionalItems = items
            }
        }
        
        if !futureItemsData.isEmpty {
            if let items = try? JSONDecoder().decode([CategoryItem].self, from: futureItemsData) {
                futureItems = items
            }
        }
        
        // Create the data structures
        let profileData = ProfileData(
            fullName: fullName,
            nickname: nickname,
            birthDate: birthDate,
            profileImage: profileImageData
        )
        
        let categoryData = CategoryData(
            personal: personalItems,
            health: healthItems,
            professional: professionalItems,
            future: futureItems
        )
        
        let lifePortalData = LifePortalData(
            profileData: profileData,
            categoryData: categoryData
        )
        
        // Encode to JSON
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            
            let jsonData = try encoder.encode(lifePortalData)
            
            // Create a temporary file URL
            let temporaryDirectoryURL = FileManager.default.temporaryDirectory
            let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent("LifePortalData.json")
            
            // Write data to the temporary file
            try jsonData.write(to: temporaryFileURL)
            
            // Share the file
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(
                    activityItems: [temporaryFileURL],
                    applicationActivities: nil
                )
                
                // Present the activity view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(activityVC, animated: true, completion: nil)
                }
            }
        } catch {
            print("Error exporting data: \(error)")
        }
    }
}

// SwiftUI View for the export sheet
struct ExportView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1A1A1D").ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.accent)
                        .padding(.top, 40)
                    
                    Text("Export Your Life Data")
                        .font(.custom("Unna-Regular", size: 28))
                        .foregroundColor(.white)
                    
                    Text("This will export all your personal information, goals, and settings as a JSON file that you can save and import later.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Text("Your data includes:")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        DataExportItem(icon: "person.fill", text: "Profile Information")
                        DataExportItem(icon: "target", text: "Personal Goals")
                        DataExportItem(icon: "heart.fill", text: "Health Objectives")
                        DataExportItem(icon: "briefcase.fill", text: "Professional Goals")
                        DataExportItem(icon: "hourglass", text: "Future Aspirations")
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    Button(action: {
                        DataExporter.exportData()
                        isPresented = false
                    }) {
                        Text("Export Data")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(AppColors.accent)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(AppColors.accent)
            )
        }
    }
}

struct DataExportItem: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.accent)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

// Preview provider for ExportView
struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView(isPresented: .constant(true))
    }
} 