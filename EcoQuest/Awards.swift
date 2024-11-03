
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
                .font(.custom("Fredoka", size: 30))
                .fontWeight(.bold)
                .foregroundColor(record.color)
            
            Text(record.title)
                .font(.custom("Fredoka", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                .multilineTextAlignment(.center)
            Text(record.date)
                .font(.custom("Fredoka", size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color.gray)
        }
        .padding([.leading,.trailing])
        .frame(width: 160, height: 220) // Adjusted height to make cards taller
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
        )
    }
}

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
                icon: "star.fill",
                value: String(userViewModel.highestDailyPoints),
                date: userViewModel.dateOfHighestDailyPoints.map { dateFormatter.string(from: $0) } ?? "N/A", // Use the stored date
                color: .yellow
            ),
            Record(
                title: "Quests Done",
                icon: "bolt.fill",
                value: String(userViewModel.numQuests),
                date: userViewModel.dateOfNumQuests.map { dateFormatter.string(from: $0) } ?? "N/A", // Use the stored date
                color: .purple
            )
        ]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(records) { record in
                    RecordCardView(record: record, isDarkMode: isDarkMode)
                }
            }
            .padding()
        }
    }
}

struct NewProgressBar: View {
    let currActions: Int
    let maxActions: Int
    let color: Color
    
    private var progress: Float {
        return maxActions > 0 ? min(Float(currActions) / Float(maxActions), 1) : 0
    }
    
    private func textColor(in geometry: GeometryProxy) -> Color {
        let progressWidth = CGFloat(progress) * geometry.size.width
        let centerX = geometry.size.width / 2
        return progressWidth > centerX ? .white : .gray
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Rectangle
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Progress Rectangle
                Rectangle()
                    .fill(color)
                    .frame(width: CGFloat(progress) * geometry.size.width, height: 16)
                    .cornerRadius(8)
                    .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: -1)
                
                // Text Overlay
                Text("\(currActions)/\(maxActions)")
                    .foregroundColor(textColor(in: geometry))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .font(.custom("Fredoka", size: 16))
                    .fontWeight(.bold)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
        }
        .frame(height: 16)
    }
}

// AwardItemView.swift
struct AwardItemView: View {
    let isUnlocked: Bool
    let icon: String
    let isSystemIcon: Bool
    let text: String
    let color: Color
    let isDarkMode: Bool
    @State private var isPressed = false
    @Binding var showSheet: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            awardIcon
            awardText
        }
        .frame(width: 100)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture(perform: onTap)
        .onLongPressGesture(
            minimumDuration: 0.1,
            pressing: { inProgress in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = inProgress
                }
            },
            perform: {}
        )
    }
    
    private var awardIcon: some View {
        ZStack {
            iconBackground
            iconContent
        }
        .frame(width: 90, height: 90)
        .padding(.bottom, 4)
    }
    
    private var iconBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isUnlocked ? color.opacity(0.2) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isUnlocked ? color : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .frame(width: 65, height: 65)
            .rotationEffect(.degrees(45))
    }
    
    private var iconContent: some View {
        Group {
            if isSystemIcon {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? color : Color.gray.opacity(0.5))
            } else {
                customIcon
            }
        }
    }
    
    private var customIcon: some View {
        Group {
            if isUnlocked {
                Image("\(icon)_color")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            } else {
                Image(isDarkMode ? "\(icon)_dark" : "\(icon)_light")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
        }
    }
    
    private var awardText: some View {
        Text(text)
            .font(.custom("Fredoka", size: 16))
            .fontWeight(isUnlocked ? .semibold : .medium)
            .foregroundColor(isUnlocked ? (ThemeColors.Text.primary(isDarkMode)) : Color.gray)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// AwardSheetView.swift
struct AwardSheetView: View {
    let isDarkMode: Bool
    let isUnlocked: Bool
    let icon: String
    let isSystemIcon: Bool
    let text: String
    let color: Color
    let currActions: Int
    let maxActions: Int
    let detail: String
    
    var body: some View {
        ZStack {
            ThemeColors.Background.primary(isDarkMode)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 24) {
                awardItem
                progressBar
                detailText
            }
            .padding(.horizontal)
        }
    }
    
    private var awardItem: some View {
        AwardItemView(
            isUnlocked: isUnlocked,
            icon: icon,
            isSystemIcon: isSystemIcon,
            text: text,
            color: color,
            isDarkMode: isDarkMode,
            showSheet: .constant(false),
            onTap: {}
        )
    }
    
    private var progressBar: some View {
        NewProgressBar(
            currActions: currActions,
            maxActions: maxActions,
            color: color
        )
    }
    
    private var detailText: some View {
        Group {
            if !isUnlocked {
                Text(detail)
                    .font(.custom("Fredoka", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            } else {
                Text("You have unlocked this award. Nice Job!")
                    .font(.custom("Fredoka", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// AwardsView.swift
struct AwardsView: View {
    @ObservedObject var userViewModel: UserViewModel
    let isDarkMode: Bool
    @State private var showAwardSheet = false
    @State private var selectedAward: Award
    @State private var selectedDetent: PresentationDetent = .height(400)
    
    var defaultAward = Award(
            icon: "default.icon",
            text: "Default Award",
            isUnlocked: false,
            color: .gray,
            isSystemIcon: true,
            currActions: 0,
            maxActions: 10,
            detail: "This is a default award."
        )
    
    init(userViewModel: UserViewModel, isDarkMode: Bool) {
            self.userViewModel = userViewModel
            self.isDarkMode = isDarkMode
            // Set the default selected award
            self._selectedAward = State(initialValue: defaultAward)
        }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            ForEach(AwardCategory.allCases, id: \.self) { category in
                awardSection(
                    title: category.title,
                    awards: category.awards(for: userViewModel)
                )
            }
        }
        .padding()
        .background(.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showAwardSheet) {
            let award = selectedAward
            
            AwardSheetView(
                isDarkMode: isDarkMode,
                isUnlocked: award.isUnlocked,
                icon: award.icon,
                isSystemIcon: award.isSystemIcon,
                text: award.text,
                color: award.color,
                currActions: award.currActions,
                maxActions: award.maxActions,
                detail: award.detail
            )
            .presentationDetents([.height(400),.height(700)], selection: $selectedDetent)
            .presentationDragIndicator(.visible)

        }
    }
    
    func awardSection(title: String, awards: [Award]) -> some View {
        VStack(alignment: .leading) {
            sectionHeader(title: title, awards: awards)
            awardsList(awards: awards)
            if title != "Waste Milestones" {
                sectionDivider
            }
        }
        .padding(.vertical, 8)
    }
    
    private var sectionDivider: some View {
        Divider()
            .frame(height: 2)
            .overlay(ThemeColors.Content.border(isDarkMode))
            .padding(.horizontal, -32)
            .padding(.top)
            .padding(.bottom, -6)
    }
}

// Award.swift
struct Award {
    let icon: String
    let text: String
    let isUnlocked: Bool
    let color: Color
    let isSystemIcon: Bool
    let currActions: Int
    let maxActions: Int
    let detail: String
}

// AwardCategory.swift
enum AwardCategory: CaseIterable {
    case streak
    case level
    case co2
    case energy
    case bottles
    case waste
    
    var title: String {
        switch self {
        case .streak: return "Streak Awards"
        case .level: return "Level Awards"
        case .co2: return "CO2 Milestones"
        case .energy: return "Energy Milestones"
        case .bottles: return "Bottle Milestones"
        case .waste: return "Waste Milestones"
        }
    }
    
    func awards(for viewModel: UserViewModel) -> [Award] {
        switch self {
        case .streak:
            return [
                Award(icon: "star.fill", text: "First Steps", isUnlocked: true, color: .yellow, isSystemIcon: true, currActions: viewModel.highStreak, maxActions: 1, detail: "Complete your first quest to unlock this award."),
                Award(icon: "flame.fill", text: "On Fire", isUnlocked: false, color: .orange, isSystemIcon: true, currActions: viewModel.highStreak, maxActions: 10, detail: "Reach a 10 day streak to unlock this award."),
                Award(icon: "medal.fill", text: "Dedicated", isUnlocked: false, color: .red, isSystemIcon: true, currActions: viewModel.highStreak, maxActions: 100, detail: "Reach a 100 day streak to unlock this award.")
            ]
        case .level:
            return [
                Award(icon: "star", text: "Novice", isUnlocked: true, color: Color.pink, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 1, detail: "Reach level 1 to unlock this award"),
                Award(icon: "star.lefthalf.fill", text: "Adept", isUnlocked: true, color: Color.red, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 2, detail: "Reach level 2 to unlock this award"),
                Award(icon: "star.fill", text: "Fighter", isUnlocked: false, color: Color.orange, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 3, detail: "Reach level 3 to unlock this award"),
                Award(icon: "shield", text: "Defender", isUnlocked: false, color: Color.brown, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 4, detail: "Reach level 4 to unlock this award"),
                Award(icon: "shield.fill", text: "Guardian", isUnlocked: false, color: Color.green, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 5, detail: "Reach level 5 to unlock this award"),
                Award(icon: "figure.martial.arts", text: "Warrior", isUnlocked: false, color: Color.teal, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 6, detail: "Reach level 6 to unlock this award"),
                Award(icon: "star.circle.fill", text: "Hero", isUnlocked: false, color: Color.blue, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 7, detail: "Reach level 7 to unlock this award"),
                Award(icon: "sparkles", text: "Sage", isUnlocked: false, color: Color.indigo, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 8, detail: "Reach level 8 to unlock this award"),
                Award(icon: "globe.americas.fill", text: "Legend", isUnlocked: false, color: Color.purple, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 9, detail: "Reach level 9 to unlock this award"),
                Award(icon: "crown.fill", text: "Champion", isUnlocked: false, color: Color.yellow, isSystemIcon: true, currActions: Level(totalPoints: viewModel.totalpoints).levelNum, maxActions: 9, detail: "Reach level 10 to unlock this award")
            ]
        case .co2:
            return [
                Award(icon: "leaf.fill", text: "10 kg CO2 Saved", isUnlocked: true, color: Color.green, isSystemIcon: true, currActions: viewModel.co2, maxActions: 10, detail: "Save a total of 10 kg of CO2 to unlock this award."),
                Award(icon: "leaf.fill", text: "50 kg CO2 Saved", isUnlocked: true, color: Color.brown, isSystemIcon: true, currActions: viewModel.co2, maxActions: 50, detail: "Save a total of 50 kg of CO2 to unlock this award."),
                Award(icon: "polar_bear", text: "100 kg CO2 Saved", isUnlocked: false, color: Color.cyan, isSystemIcon: false, currActions: viewModel.co2, maxActions: 100, detail: "Save a total of 100 kg of CO2 to unlock this award.")
            ]
        
        case .energy:
            return [
                Award(icon: "bolt.fill", text: "100 kWh Saved", isUnlocked: true, color: Color.yellow, isSystemIcon: true, currActions: viewModel.energy, maxActions: 100, detail: "Save a total of 100 kWh of energy to unlock this award."),
                Award(icon: "bolt.fill", text: "500 kWh Saved", isUnlocked: true, color: Color.orange, isSystemIcon: true, currActions: viewModel.energy, maxActions: 500, detail: "Save a total of 500 kWh of energy to unlock this award."),
                Award(icon: "pika", text: "1000 kWh Saved", isUnlocked: false, color: Color.red, isSystemIcon: false, currActions: viewModel.energy, maxActions: 1000, detail: "Save a total of 1000 kWh of energy to unlock this award.")
        ]
        
        case .bottles:
            return [
                Award(icon: "drop.fill", text: "10 Bottles Saved", isUnlocked: true, color: Color.teal, isSystemIcon: true, currActions: viewModel.bottles, maxActions: 10, detail: "Save a total of 10 plastic bottles to unlock this award."),
                Award (icon: "drop.fill", text: "50 Bottles Saved", isUnlocked: true, color: Color.blue, isSystemIcon: true, currActions: viewModel.bottles, maxActions: 50, detail: "Save a total of 50 plastic bottles to unlock this award."),
                Award(icon: "turtle", text: "100 Bottles Saved", isUnlocked: false, color: Color.blue, isSystemIcon: false, currActions: viewModel.bottles, maxActions: 100, detail: "Save a total of 100 plastic bottles to unlock this award.")
        ]
        
        case .waste:
            return [
            Award(icon: "trash.fill", text: "5 kg Waste Saved", isUnlocked: true, color: Color.purple, isSystemIcon: true, currActions: viewModel.bottles, maxActions: 5, detail: "Reduce a total of 5 kg of waste to unlock this award."),
            Award(icon: "trash.fill", text: "25 kg Waste Saved", isUnlocked: true, color: Color.indigo, isSystemIcon: true, currActions: viewModel.bottles, maxActions: 25, detail: "Reduce a total of 25 kg of waste to unlock this award."),
            Award(icon: "elephant", text: "50 kg Waste Saved", isUnlocked: false, color: Color.indigo, isSystemIcon: false, currActions: viewModel.bottles, maxActions: 50, detail: "Reduce a total of 50 kg of waste to unlock this award.")
        ]
        default:
            return []
        }
    }
}

// AwardSectionHeader.swift
extension AwardsView {
    func sectionHeader(title: String, awards: [Award]) -> some View {
        HStack {
            Text(title)
                .font(.custom("Fredoka", size: 22))
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.Text.primary(isDarkMode))
            Spacer()
            Text("\(awards.filter { $0.isUnlocked }.count) of \(awards.count)")
                .font(.custom("Fredoka", size: 18))
                .fontWeight(.medium)
                .foregroundColor(.gray)
        }
        .background(.clear)
    }
    
    func awardsList(awards: [Award]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(awards, id: \.text) { award in
                        Button(action: {
                            selectedAward = award // Set the selectedAward before showing the sheet
                            showAwardSheet = true // Show the sheet
                        }) {
                            AwardItemView(
                                isUnlocked: award.isUnlocked,
                                icon: award.icon,
                                isSystemIcon: award.isSystemIcon,
                                text: award.text,
                                color: award.color,
                                isDarkMode: isDarkMode,
                                showSheet: .constant(false),
                                onTap: {
                                    selectedAward = award
                                    showAwardSheet = true
                                    print("Selected Award: \(selectedAward)")
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle()) // Ensure the button does not have a default style that alters appearance
                    }
            }
        }
    }
}
