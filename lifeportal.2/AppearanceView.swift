import SwiftUI

struct AppearanceView: View {
    @Binding var isPresented: Bool
    @State private var selectedColor: ColorOption = AppColors.currentAccentColor
    
    // Grid layout columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#1A1A1D").ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header image
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 60))
                        .foregroundColor(selectedColor.color)
                        .padding(.top, 20)
                    
                    // Title
                    Text("Appearance Settings")
                        .font(.custom("Unna-Regular", size: 28))
                        .foregroundColor(.white)
                    
                    // Description
                    Text("Choose an accent color for your LifePortal experience")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    // Color grid
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(AccentColors.all) { colorOption in
                            ColorOptionButton(
                                colorOption: colorOption,
                                isSelected: selectedColor.hex == colorOption.hex,
                                action: {
                                    selectColor(colorOption)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Preview section
                    VStack(spacing: 15) {
                        Text("Preview")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Button preview
                        Button(action: {}) {
                            Text("Button")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .background(selectedColor.color)
                                .cornerRadius(10)
                        }
                        .disabled(true)
                        
                        // Toggle preview
                        HStack(spacing: 20) {
                            Toggle("Toggle", isOn: .constant(true))
                                .toggleStyle(SwitchToggleStyle(tint: selectedColor.color))
                                .foregroundColor(.white)
                                .disabled(true)
                            
                            // Progress preview
                            ProgressView(value: 0.7)
                                .progressViewStyle(LinearProgressViewStyle(tint: selectedColor.color))
                                .frame(width: 100)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                    .background(Color(hex: "#1E2221").opacity(0.6))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Apply button
                    Button(action: {
                        AppColors.setAccentColor(selectedColor)
                        isPresented = false
                    }) {
                        Text("Apply Changes")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(selectedColor.color)
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
    
    // Function to select a color
    private func selectColor(_ colorOption: ColorOption) {
        withAnimation {
            selectedColor = colorOption
        }
    }
}

// Color option button
struct ColorOptionButton: View {
    var colorOption: ColorOption
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Color circle
                    Circle()
                        .fill(colorOption.color)
                        .frame(width: 60, height: 60)
                        .shadow(color: colorOption.color.opacity(0.5), radius: isSelected ? 10 : 0)
                    
                    // Selection indicator
                    if isSelected {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 68, height: 68)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Color name
                Text(colorOption.name)
                    .font(.system(size: 14))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? colorOption.color.opacity(0.15) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView(isPresented: .constant(true))
    }
} 