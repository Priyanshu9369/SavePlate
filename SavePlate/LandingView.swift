//
//  LandingView.swift
//  SavePlate
//

import SwiftUI

struct LandingView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                    .frame(height: 320)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Rescue. Share.")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundStyle(Color.black)
                        Text("Nourish.")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundStyle(HearthColor.earth)
                    }

                    Text("Connecting local surplus with community needs to build a world without food waste.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.38))
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 14) {
                        donorCTA
                        receiverCTA
                    }
                    .padding(.top, 8)

                    footerStats
                        .padding(.top, 24)
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 36)
            }
        }
        .background(HearthGradient.landingHero.ignoresSafeArea())
    }

    private var hero: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [HearthColor.mint, Color.white.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 12) {
                HStack {
                    Label(HearthBrand.tagline, systemImage: "leaf.fill")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(HearthColor.forest)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(HearthColor.mintWash, in: Capsule())
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ZStack(alignment: .topTrailing) {
                    landingIllustration
                        .padding(.top, 8)

                    impactGoalCard
                        .padding(.trailing, 16)
                        .offset(y: 4)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var landingIllustration: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.5))
                .frame(height: 200)
                .padding(.horizontal, 16)

            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(HearthColor.forest.opacity(0.85))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(HearthColor.terracotta.opacity(0.35))
                        .frame(width: 40, height: 6)
                }
                Image(systemName: "table.furniture.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(HearthColor.leaf)
                VStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(HearthColor.forest.opacity(0.75))
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .font(.title2)
                        .foregroundStyle(HearthColor.earthMuted)
                }
            }
        }
    }

    private var impactGoalCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("IMPACT GOAL")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(HearthColor.leaf)
            Text("1.2M LBS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(HearthColor.forestDeep)
            Text("Meals rescued this month")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 132, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }

    private var donorCTA: some View {
        Button {
            session.chooseDonor()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "fork.knife")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("I Have Surplus Food")
                        .font(.system(size: 17, weight: .bold))
                    Text("Join as a Donor")
                        .font(.system(size: 14, weight: .regular))
                        .opacity(0.9)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(HearthColor.forest, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: HearthColor.forest.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var receiverCTA: some View {
        Button {
            session.chooseReceiverOnboarding()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(HearthColor.peach.opacity(0.65))
                        .frame(width: 48, height: 48)
                    Image(systemName: "hands.and.sparkles.fill")
                        .font(.title3)
                        .foregroundStyle(HearthColor.earth)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("I Need Food")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.black)
                    Text("Access local rescues")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var footerStats: some View {
        HStack {
            statCol(value: "500+", label: "KITCHENS")
            divider
            statCol(value: "12k", label: "NEIGHBORS")
            divider
            statCol(value: "85%", label: "CO2 SAVED")
        }
        .padding(.vertical, 16)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.25))
            .frame(width: 1, height: 36)
    }

    private func statCol(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LandingView()
        .environment(AppSession())
}
