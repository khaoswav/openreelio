import SwiftUI

enum BMColor {
    static let rose = Color(red: 223 / 255, green: 60 / 255, blue: 95 / 255)
    static let navy = Color(red: 34 / 255, green: 65 / 255, blue: 147 / 255)
    static let blue = Color(red: 111 / 255, green: 155 / 255, blue: 209 / 255)
    static let canvas = Color(red: 0.055, green: 0.063, blue: 0.082)
    static let panel = Color(red: 0.085, green: 0.096, blue: 0.122)
    static let elevated = Color(red: 0.115, green: 0.129, blue: 0.160)
    static let line = Color.white.opacity(0.075)
    static let muted = Color.white.opacity(0.48)
}

struct GlassPanel<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.075), lineWidth: 1)
            }
    }
}

struct SectionEyebrow: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(BMColor.muted)
    }
}

struct BrandMark: View {
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.29, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BMColor.rose, BMColor.navy],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "waveform.path")
                .font(.system(size: size * 0.47, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: BMColor.rose.opacity(0.24), radius: 14, y: 5)
    }
}
