import SwiftUI

struct CategoryItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date
    var isCompleted: Bool = false
    var priority: Int = 1 // 1-3 scale
}

struct CategoryDetailView: View {
    var categoryName: String
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var particleStore: ParticleStore
    
    // Use AppStorage to store category data
    @AppStorage("personalItems") private var personalItemsData: Data = Data()
    @AppStorage("healthItems") private var healthItemsData: Data = Data()
    @AppStorage("professionalItems") private var professionalItemsData: Data = Data()
    @AppStorage("futureItems") private var futureItemsData: Data = Data()
    
    // Local state for items
    @State private var items: [CategoryItem] = []
    @State private var showingAddItemSheet = false
    @State private var newItemTitle = ""
    @State private var newItemDescription = ""
    @State private var newItemDate = Date()
    @State private var newItemPriority = 1
    
    var body: some View {
        NavigationView {
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
                
                // Add particle effect - using the main ParticleView for consistency
                ParticleView()
                    .ignoresSafeArea()
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        
                        itemsList
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle(categoryName, displayMode: .inline)
            .navigationBarItems(
                leading: backButton,
                trailing: addButton
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(categoryName)
                        .font(.custom("Unna-Regular", size: 24))
                        .foregroundColor(.white)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingAddItemSheet) {
            addItemView
        }
        .transition(.move(edge: .bottom))
        .onAppear {
            configureNavigationBarAppearance()
            loadItems()
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(categoryName.uppercased()) GOALS")
                .foregroundColor(.white)
                .opacity(0.6)
                .font(.custom("Teko-Regular", size: 14))
                .padding(.top, 10)
            
            Text(getCategoryDescription())
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 5)
        }
    }
    
    private var itemsList: some View {
        VStack(spacing: 14) {
            if items.isEmpty {
                emptyStateView
            } else {
                ForEach(items) { item in
                    itemCard(item: item)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: getCategoryIcon())
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#3B8D85").opacity(0.7))
                .padding(.top, 30)
            
            Text("No items added yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Tap + to add your first \(categoryName.lowercased()) goal")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func itemCard(item: CategoryItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Priority indicator
                ZStack {
                    Circle()
                        .fill(getPriorityColor(priority: item.priority))
                        .frame(width: 12, height: 12)
                    
                    Circle()
                        .stroke(getPriorityColor(priority: item.priority), lineWidth: 1)
                        .frame(width: 16, height: 16)
                }
                
                Text(item.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(item.isCompleted ? 0.5 : 0.9))
                    .strikethrough(item.isCompleted)
                
                Spacer()
                
                Button(action: {
                    toggleItemCompletion(item: item)
                }) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isCompleted ? Color(hex: "#3B8D85") : Color.gray.opacity(0.6))
                        .font(.system(size: 20))
                }
            }
            
            if !item.description.isEmpty {
                Text(item.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(formatDate(item.date))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    deleteItem(item: item)
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#1E2221"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var backButton: some View {
        Button(action: {
            isPresented = false
        }) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(Color(hex: "#3B8D85"))
        }
    }
    
    private var addButton: some View {
        Button(action: {
            showingAddItemSheet = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "#3B8D85"))
        }
    }
    
    private var addItemView: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1A1A1D").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        TextField("Title", text: $newItemTitle)
                            .padding()
                            .background(Color(hex: "#2A2A2D"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        
                        TextField("Description (optional)", text: $newItemDescription)
                            .padding()
                            .background(Color(hex: "#2A2A2D"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading) {
                            Text("Target Date")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            DatePicker("", selection: $newItemDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .accentColor(Color(hex: "#3B8D85"))
                                .colorScheme(.dark)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Priority")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Priority", selection: $newItemPriority) {
                                Text("Low").tag(1)
                                Text("Medium").tag(2)
                                Text("High").tag(3)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Add \(categoryName) Item", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingAddItemSheet = false
                    resetNewItemFields()
                },
                trailing: Button("Save") {
                    addNewItem()
                    showingAddItemSheet = false
                }
                .disabled(newItemTitle.isEmpty)
            )
            .accentColor(Color(hex: "#3B8D85"))
        }
    }
    
    // MARK: - Helper Functions
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color(hex: "#1A1A1D").opacity(0.95))
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color(hex: "#3B8D85"))
    }
    
    private func getCategoryDescription() -> String {
        switch categoryName {
        case "Personal":
            return "Track your personal development goals, relationships, hobbies, and personal projects."
        case "Health":
            return "Monitor your physical and mental health goals, fitness milestones, and wellness objectives."
        case "Professional":
            return "Manage your career objectives, skills development, and professional achievements."
        case "Future":
            return "Plan your long-term aspirations, life vision, and legacy goals."
        default:
            return "Manage your goals and track your progress."
        }
    }
    
    private func getCategoryIcon() -> String {
        switch categoryName {
        case "Personal":
            return "person.fill"
        case "Health":
            return "heart.fill"
        case "Professional":
            return "briefcase.fill"
        case "Future":
            return "hourglass"
        default:
            return "list.bullet"
        }
    }
    
    private func getPriorityColor(priority: Int) -> Color {
        switch priority {
        case 1:
            return Color.blue.opacity(0.8)
        case 2:
            return Color.yellow.opacity(0.8)
        case 3:
            return Color.red.opacity(0.8)
        default:
            return Color.blue.opacity(0.8)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // MARK: - Data Management
    
    private func loadItems() {
        let data: Data
        
        switch categoryName {
        case "Personal":
            data = personalItemsData
        case "Health":
            data = healthItemsData
        case "Professional":
            data = professionalItemsData
        case "Future":
            data = futureItemsData
        default:
            data = Data()
        }
        
        if !data.isEmpty {
            do {
                items = try JSONDecoder().decode([CategoryItem].self, from: data)
            } catch {
                print("Error decoding items: \(error)")
                items = []
            }
        } else {
            items = []
        }
    }
    
    private func saveItems() {
        do {
            let data = try JSONEncoder().encode(items)
            
            switch categoryName {
            case "Personal":
                personalItemsData = data
            case "Health":
                healthItemsData = data
            case "Professional":
                professionalItemsData = data
            case "Future":
                futureItemsData = data
            default:
                break
            }
        } catch {
            print("Error encoding items: \(error)")
        }
    }
    
    private func addNewItem() {
        let newItem = CategoryItem(
            title: newItemTitle,
            description: newItemDescription,
            date: newItemDate,
            priority: newItemPriority
        )
        
        items.append(newItem)
        saveItems()
        resetNewItemFields()
    }
    
    private func toggleItemCompletion(item: CategoryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            saveItems()
        }
    }
    
    private func deleteItem(item: CategoryItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    private func resetNewItemFields() {
        newItemTitle = ""
        newItemDescription = ""
        newItemDate = Date()
        newItemPriority = 1
    }
}

// Note: Color extension is already defined in ContentView.swift 