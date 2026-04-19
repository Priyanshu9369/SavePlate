//
//  HearthTheme.swift
//  SavePlate — The Conscious Hearth design system
//

import SwiftUI

// MARK: - Color tokens (spec)

enum HearthTokens {
    /// Eco Green — growth, branding, success
    static let primary = Color(red: 13 / 255, green: 99 / 255, blue: 27 / 255) // #0d631b
    /// Warm Orange — urgency, appetite, key CTAs
    static let secondary = Color(red: 150 / 255, green: 73 / 255, blue: 0 / 255) // #964900

    static let surface = Color(red: 0.97, green: 0.98, blue: 0.975)
    static let surfaceContainerLow = Color(red: 0.945, green: 0.955, blue: 0.95)
    static let surfaceContainerLowest = Color.white
    static let onSurface = Color(red: 0.12, green: 0.13, blue: 0.12)
    static let onSurfaceVariant = Color(red: 0.38, green: 0.4, blue: 0.39)
    static let outlineVariant = Color.black.opacity(0.15)

    static let mintTint = Color(red: 0.91, green: 0.97, blue: 0.93)
}

enum HearthBrand {
    static let name = "The Conscious Hearth"
    static let tagline = "THE CONSCIOUS HEARTH"
}

/// Semantic aliases (legacy names map to spec tokens).
enum HearthColor {
    static let forest = HearthTokens.primary
    static let forestDeep = Color(red: 0.05, green: 0.32, blue: 0.12)
    static let forestHeader = HearthTokens.primary
    static let leaf = Color(red: 0.298, green: 0.686, blue: 0.314)
    static let terracotta = HearthTokens.secondary
    static let earth = HearthTokens.secondary
    static let earthMuted = Color(red: 0.45, green: 0.38, blue: 0.32)
    static let mint = HearthTokens.mintTint
    static let mintWash = Color(red: 0.93, green: 0.98, blue: 0.94)
    static let canvas = HearthTokens.surface
    static let peach = Color(red: 1.0, green: 0.88, blue: 0.78)
}

enum HearthShadow {
    static func ambient() -> some View {
        Color.black.opacity(0.06)
    }

    static let cardRadius: CGFloat = 24
}

enum HearthFont {
    /// Display / headlines — editorial weight (Plus Jakarta Sans when bundled; system rounded fallback).
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func labelCaps(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

enum HearthGradient {
    static let landingHero = LinearGradient(
        colors: [HearthTokens.mintTint, HearthTokens.surfaceContainerLowest],
        startPoint: .top,
        endPoint: .bottom
    )

    static let liveImpactCard = LinearGradient(
        colors: [
            Color(red: 0.22, green: 0.62, blue: 0.32),
            HearthTokens.primary,
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let impactHero = LinearGradient(
        colors: [
            Color(red: 0.2, green: 0.55, blue: 0.28),
            HearthTokens.primary,
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let pulseGreen = LinearGradient(
        colors: [HearthTokens.primary, Color(red: 0.06, green: 0.42, blue: 0.16)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct HearthScreenBackground: View {
    var body: some View {
        HearthTokens.surface
            .ignoresSafeArea()
    }
}

struct HearthCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HearthTokens.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: HearthShadow.cardRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 24, y: 8)
    }
}

/// No-line rule: filled surface, optional ghost outline at 15% opacity.
struct HearthInputField<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(HearthTokens.surfaceContainerLow, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(HearthTokens.outlineVariant.opacity(0.35), lineWidth: 0)
            )
    }
}

extension View {
    func hearthScreenBackground() -> some View {
        background { HearthScreenBackground() }
    }

    func hearthNavBar() -> some View {
        toolbarBackground(HearthTokens.mintTint.opacity(0.85), for: .navigationBar)
    }

    func hearthTabBar() -> some View {
        toolbarBackground(HearthTokens.surfaceContainerLowest, for: .tabBar)
    }

    func hearthAmbientShadow() -> some View {
        shadow(color: Color.black.opacity(0.06), radius: 24, y: 8)
    }
}

enum SPColor {
    static let leaf = HearthColor.leaf
}
