import SwiftUI

// Extension for Color from hex - shared across the app
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

// Available accent colors for the app
struct AccentColors {
    static let teal = ColorOption(name: "Teal", hex: "#3B8D85")
    static let purple = ColorOption(name: "Purple", hex: "#8E7CC3")
    static let blue = ColorOption(name: "Blue", hex: "#5B9BD5")
    static let orange = ColorOption(name: "Orange", hex: "#E36C09")
    static let green = ColorOption(name: "Green", hex: "#70AD47")
    static let red = ColorOption(name: "Red", hex: "#C00000")
    
    static let all = [teal, purple, blue, orange, green, red]
    
    static func colorFromHex(_ hex: String) -> ColorOption {
        return all.first { $0.hex == hex } ?? teal
    }
}

// Color option structure
struct ColorOption: Identifiable, Hashable {
    var id: String { hex }
    var name: String
    var hex: String
    
    var color: Color {
        Color(hex: hex)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hex)
    }
    
    static func == (lhs: ColorOption, rhs: ColorOption) -> Bool {
        return lhs.hex == rhs.hex
    }
}

// Shared app colors with dynamic accent
class AppColors {
    @AppStorage("accentColorHex") static var accentColorHex: String = "#3B8D85"
    
    static var background: Color { Color(hex: "#1A1A1D") }
    static var backgroundSecondary: Color { Color(hex: "#18191B") }
    static var cardBackground: Color { Color(hex: "#1E2221") }
    static var textPrimary: Color { Color.white }
    static var textSecondary: Color { Color.white.opacity(0.7) }
    static var textTertiary: Color { Color.white.opacity(0.5) }
    
    // Dynamic accent color based on user selection
    static var accent: Color {
        Color(hex: accentColorHex)
    }
    
    // Update the accent color
    static func setAccentColor(_ option: ColorOption) {
        accentColorHex = option.hex
    }
    
    // Get the current accent color option
    static var currentAccentColor: ColorOption {
        AccentColors.colorFromHex(accentColorHex)
    }
} 