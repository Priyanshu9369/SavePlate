//
//  DonorImpactDashboardView.swift
//  SavePlate
//

import Charts
import SwiftUI

struct DonorImpactDashboardView: View {
    @Environment(DonationStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard

                    HStack(spacing: 12) {
                        miniMetricCard(
                            title: "\(store.estimatedCO2KgReduced)kg Carbon Footprint Reduced",
                            progress: 0.55,
                            tint: HearthColor.terracotta,
                            icon: "cloud.fill"
                        )
                        miniMetricCard(
                            title: "\(max(1, store.totalMealsDonated / 24)) Families Helped",
                            progress: 0.42,
                            tint: HearthColor.forest,
                            icon: "person.2.fill"
                        )
                    }

                    trajectoryCard

                    leaderboardCard

                    sponsorCard
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
            .scrollContentBackground(.hidden)
            .hearthScreenBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(HearthColor.forest)
                }
                ToolbarItem(placement: .principal) {
                    Text(HearthBrand.name)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(HearthColor.forestHeader)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(HearthColor.forest)
                }
            }
            .hearthNavBar()
        }
    }

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(HearthGradient.impactHero)

            VStack(alignment: .leading, spacing: 12) {
                Text("IMPACT DASHBOARD")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.15), in: Capsule())
                    .foregroundStyle(.white)

                Text("Your contribution is transforming lives.")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text("Thank you for being a vital part of the food rescue revolution. Every donation makes a ripple.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))

                HStack(spacing: 12) {
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundStyle(.white)
                    VStack(alignment: .leading) {
                        Text("\(store.totalMealsDonated)")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                        Text("MEALS SAVED")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(20)
        }
        .frame(minHeight: 220)
    }

    private func miniMetricCard(title: String, progress: CGFloat, tint: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle().fill(HearthColor.peach.opacity(0.9)).frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)
            }
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule()
                        .fill(tint.opacity(0.85))
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }

    private var trajectoryCard: some View {
        let series = store.monthlyMealTrend(monthsBack: 6)
        return VStack(alignment: .leading, spacing: 12) {
            Label("Impact Trajectory", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            if series.allSatisfy({ $0.1 == 0 }) {
                Text("Log donations to see your trajectory.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(Array(series.enumerated()), id: \.offset) { i, row in
                    BarMark(
                        x: .value("M", row.0),
                        y: .value("Meals", row.1)
                    )
                    .foregroundStyle(barGradient(index: i, count: series.count))
                    .cornerRadius(6)
                }
                .frame(height: 180)
            }

            let growth = store.mealsThisWeekVsLastWeek()
            let pct = growth.lastWeek > 0
                ? Int((Double(growth.thisWeek - growth.lastWeek) / Double(growth.lastWeek)) * 100)
                : 24
            (Text("Your impact has grown by ")
                + Text("\(pct)%").fontWeight(.bold).foregroundStyle(HearthColor.forest)
                + Text(" since last month."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func barGradient(index: Int, count: Int) -> LinearGradient {
        let t = Double(index) / Double(max(count - 1, 1))
        let a = Color(red: 0.55, green: 0.85, blue: 0.55)
        let b = HearthColor.forestDeep
        return LinearGradient(
            colors: [a.opacity(1 - t * 0.4), b.opacity(0.75 + t * 0.25)],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    private var leaderboardCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Community Heroes")
                        .font(.headline)
                    Text("See how your efforts rank in the neighborhood.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("View All")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(HearthColor.forest)
            }

            leaderRow(rank: 1, name: "Marcus Chen", subtitle: "GOLD CONTRIBUTOR", points: "2,490", highlight: false)
            HStack {
                Spacer()
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            leaderRow(rank: 12, name: "You", subtitle: "RISING HERO", points: "\(store.totalMealsDonated) pts", highlight: true)
        }
        .padding(16)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private func leaderRow(rank: Int, name: String, subtitle: String, points: String, highlight: Bool) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.caption.weight(.bold))
                .frame(width: 24)
            Circle()
                .fill(highlight ? HearthColor.forest : Color(.systemGray4))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(highlight ? "You" : String(name.prefix(1)))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(HearthColor.earthMuted)
            }
            Spacer()
            Text(points)
                .font(.caption.weight(.bold))
                .foregroundStyle(HearthColor.forest)
        }
        .padding(10)
        .background(highlight ? HearthColor.mint.opacity(0.35) : Color.clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var sponsorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(HearthColor.terracotta.opacity(0.9))
                .frame(height: 72)
                .overlay {
                    Text("COMMUNITY DONATE")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.white)
                }
            Text("Ready to increase your impact?")
                .font(.headline)
            (Text("There are currently ")
                + Text("\(store.sampleUrgentRequests.count) active food rescue requests")
                .fontWeight(.bold)
                .foregroundStyle(HearthColor.terracotta)
                + Text(" in your immediate area that need a sponsor."))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
            } label: {
                Text("Sponsor Now")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HearthColor.terracotta, in: Capsule())
                    .foregroundStyle(.white)
            }
            Button {
            } label: {
                Text("Learn More")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white, in: Capsule())
                    .overlay(Capsule().stroke(Color.black.opacity(0.12)))
            }
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.5), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
