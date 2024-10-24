
import Foundation
import SwiftUI

struct Record: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let value: String
    let date: String
    let color: Color
}


struct RecordCardView: View {
    var record: Record
    var isDarkMode: Bool

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: record.icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(record.color)
                .padding(16)
                .background(record.color.opacity(0.15))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(record.color, lineWidth: 2)
                        .padding(1)
                )
            Text(record.value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(record.color)
            
            Text(record.title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text(record.date)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 160, height: 220) // Adjusted height to make cards taller
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
        )
    }
}

import SwiftUI

struct RecordsView: View {
    @ObservedObject var userViewModel: UserViewModel
    let isDarkMode: Bool

    init(userViewModel: UserViewModel, isDarkMode: Bool) {
        self.userViewModel = userViewModel
        self.isDarkMode = isDarkMode
    }

    var records: [Record] {
        // Create a DateFormatter to format the date for display
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Set the date style (short, medium, long, full)
        dateFormatter.timeStyle = .none // We only want the date, not the time

        return [
            Record(
                title: "Highest Streak",
                icon: "flame.fill",
                value: String(userViewModel.highStreak),
                date: userViewModel.dateOfHighestStreak.map { dateFormatter.string(from: $0) } ?? "N/A", // Use the stored date
                color: .orange
            ),
            Record(
                title: "Daily Points",
                icon: "bolt.fill",
                value: String(userViewModel.highestDailyPoints),
                date: userViewModel.dateOfHighestDailyPoints.map { dateFormatter.string(from: $0) } ?? "N/A", // Use the stored date
                color: .yellow
            ),
            Record(
                title: "Quests Done",
                icon: "calendar",
                value: String(userViewModel.numQuests),
                date: userViewModel.dateOfNumQuests.map { dateFormatter.string(from: $0) } ?? "N/A", // Use the stored date
                color: .indigo
            )
        ]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(records) { record in
                    RecordCardView(record: record, isDarkMode: isDarkMode)
                }
            }
            .padding()
        }
    }
}

struct AwardItemView: View {
    let isUnlocked: Bool
    let icon: String // SF Symbol name
    let text: String
    let color: Color
    let isDarkMode: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Award icon with background
            ZStack {
                // Background rectangle
                RoundedRectangle(cornerRadius: 8)
                    .fill(isUnlocked ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isUnlocked ? color : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .frame(width: 65, height: 65)
                    .rotationEffect(.degrees(45))
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? color : Color.gray.opacity(0.5))
            }
            .frame(width: 80, height: 80) // Larger frame to accommodate rotation
            .padding(.bottom,4)
            // Award text
            Text(text)
                .font(.system(size: 16))
                .fontWeight(isUnlocked ? .bold : .regular)
                .foregroundColor(isUnlocked ? (isDarkMode ? Color.white : Color.black) : Color.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 100) // Fixed width for consistent grid layout
    }
}

struct AwardsView: View {
    @ObservedObject var userViewModel: UserViewModel
    let isDarkMode: Bool

    init(userViewModel: UserViewModel, isDarkMode: Bool) {
        self.userViewModel = userViewModel
        self.isDarkMode = isDarkMode
    }
    
    var body: some View {
        // Sample awards data with text
        let awards = [
            (icon: "star.fill", text: "First Steps", isUnlocked: userViewModel.firstAwardUnlocked, color: Color.yellow),
            (icon: "flame.fill", text: "On Fire", isUnlocked: false, color: Color.orange),
            (icon: "shield.fill", text: "Warrior", isUnlocked: false, color: Color.blue),
            (icon: "leaf.arrow.circlepath", text: "Dedicated", isUnlocked: false, color: Color.red),
            (icon: "leaf.fill", text: "Nature Friend", isUnlocked: false, color: Color.green),
            (icon: "crown.fill", text: "Champion", isUnlocked: false, color: Color.purple)
        ]

        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 24) { // Increased spacing for text
                    ForEach(awards.indices, id: \.self) { index in
                        AwardItemView(
                            isUnlocked: awards[index].isUnlocked,
                            icon: awards[index].icon,
                            text: awards[index].text,
                            color: awards[index].color,
                            isDarkMode: isDarkMode
                        )
                    }
                }
            }
            .padding()
            .background(ThemeColors.Card.background(isDarkMode))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
            )
            .padding(.horizontal)
        }
    }
}

