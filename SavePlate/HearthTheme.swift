//
//  HearthTheme.swift
//  SavePlate — The Conscious Hearth visual system
//

import SwiftUI

enum HearthBrand {
    static let name = "The Conscious Hearth"
    static let tagline = "THE CONSCIOUS HEARTH"
}

/// Mock-aligned palette: forest green, terracotta, mint, earth brown.
enum HearthColor {
    /// #14532D / deep forest
    static let forest = Color(red: 0.078, green: 0.325, blue: 0.176)
    /// #1B5E20
    static let forestDeep = Color(red: 0.106, green: 0.369, blue: 0.125)
    /// #135D1B header greens
    static let forestHeader = Color(red: 0.075, green: 0.365, blue: 0.106)
    /// #4CAF50 accent leaf
    static let leaf = Color(red: 0.298, green: 0.686, blue: 0.314)
    /// #944D00 / burnt orange-brown CTA
    static let terracotta = Color(red: 0.580, green: 0.302, blue: 0.0)
    /// #8B4513 headline accent
    static let earth = Color(red: 0.545, green: 0.271, blue: 0.075)
    /// #965A3E small caps
    static let earthMuted = Color(red: 0.588, green: 0.353, blue: 0.243)
    /// #E0F2F1 mint
    static let mint = Color(red: 0.878, green: 0.949, blue: 0.945)
    /// #F1F8E9 light mint wash
    static let mintWash = Color(red: 0.945, green: 0.973, blue: 0.914)
    /// #F7FAF9 off-white screen
    static let canvas = Color(red: 0.969, green: 0.980, blue: 0.976)
    static let peach = Color(red: 1.0, green: 0.82, blue: 0.70)
}

enum HearthGradient {
    static let landingHero = LinearGradient(
        colors: [HearthColor.mint, Color.white],
        startPoint: .top,
        endPoint: .bottom
    )

    static let liveImpactCard = LinearGradient(
        colors: [
            Color(red: 0.40, green: 0.73, blue: 0.42),
            HearthColor.forestDeep,
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let impactHero = LinearGradient(
        colors: [
            Color(red: 0.30, green: 0.69, blue: 0.31),
            HearthColor.forestDeep,
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct HearthScreenBackground: View {
    var body: some View {
        LinearGradient(
            colors: [HearthColor.mint.opacity(0.35), HearthColor.canvas],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct HearthCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 14, y: 6)
    }
}

extension View {
    func hearthScreenBackground() -> some View {
        background { HearthScreenBackground() }
    }

    func hearthNavBar() -> some View {
        toolbarBackground(HearthColor.mint.opacity(0.5), for: .navigationBar)
    }

    func hearthTabBar() -> some View {
        toolbarBackground(.white, for: .tabBar)
    }
}

/// Pin / small accents for map and legacy call sites.
enum SPColor {
    static let leaf = HearthColor.leaf
}
