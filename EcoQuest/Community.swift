import SwiftUI
import Foundation
import FirebaseFirestore

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .clear,
                                    Color.white.opacity(0.4),
                                    .clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(30))
                        .offset(x: -geometry.size.width * 2 + phase, y: 0)
                        .frame(width: geometry.size.width * 3, height: geometry.size.height)
                }
                .clipped()
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 2 * UIScreen.main.bounds.width
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        self.modifier(Shimmer())
    }
}

class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()

    var dailySorted: [LeaderboardEntry] {
        entries.sorted { $0.dailyPoints > $1.dailyPoints }
    }

    var allTimeSorted: [LeaderboardEntry] {
        entries.sorted { $0.allTimePoints > $1.allTimePoints }
    }

    func fetchLeaderboard() async {
        await MainActor.run {
            self.isLoading = true
        }

        do {
            print("Fetching leaderboard")
            let snapshot = try await db.collection("leaderboard").getDocuments()

            var updatedEntries: [LeaderboardEntry] = []

            for document in snapshot.documents {
                print("\(document.documentID) => \(document.data())")

                if let newEntry = try? document.data(as: LeaderboardEntry.self) {
                    updatedEntries.append(newEntry)
                }
            }

            // Update entries on the main thread
            DispatchQueue.main.async {
                for newEntry in updatedEntries {
                    if let index = self.entries.firstIndex(where: { $0.id == newEntry.id }) {
                        self.entries[index] = newEntry
                    } else {
                        self.entries.append(newEntry)
                    }
                }

                print(self.entries)
            }

        } catch {
            print("Error getting documents: \(error)")
        }
        await Task.sleep(3_000_000_000)
        
        await MainActor.run {
                    self.isLoading = false
                }
    }
}

struct LeaderboardCardSkeleton: View {
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Fake rank or medal
            Circle()
                .fill(ThemeColors2.Skeleton.base(isDarkMode))
                .frame(width: 24, height: 24)

            // Profile Image placeholder
            Circle()
                .fill(ThemeColors2.Skeleton.base(isDarkMode))
                .frame(width: 50, height: 50)

            // Username placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(ThemeColors2.Skeleton.base(isDarkMode))
                .frame(width: 120, height: 18)

            Spacer()

            // Points placeholder
            RoundedRectangle(cornerRadius: 4)
                .fill(ThemeColors2.Skeleton.base(isDarkMode))
                .frame(width: 60, height: 18)
        }
        .padding(.top, 0)
        .padding([.horizontal])
        .shimmering()
    }
        
}

enum ThemeColors2 {
    enum Skeleton {
        static func base(_ isDarkMode: Bool) -> Color {
            isDarkMode ? Color.white.opacity(0.1) : Color.gray.opacity(0.3)
        }
    }
}

// Sample data model for a friend
struct User: Identifiable {
    let id = UUID()
    let username: String
    let points: Int
}

// Sample data for friends (mockup data)
struct Community: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var authViewModel: UserAuthViewModel
    let isDarkMode: Bool
    let communityTab: String
    
    init(userViewModel: UserViewModel, authViewModel: UserAuthViewModel, isDarkMode: Bool, communityTab: String) {
        self.userViewModel = userViewModel
        self.authViewModel = authViewModel
        self.isDarkMode = isDarkMode
        self.communityTab = communityTab
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Content Area
            ZStack {
                ThemeColors.Background.primary(isDarkMode)
                    .ignoresSafeArea()
                
                if communityTab == "Leaderboard" {
                    LeaderboardView(userViewModel: userViewModel, authViewModel: authViewModel, isDarkMode: isDarkMode)
                        .padding(.top, -420)
                        .padding(.bottom, -32)
                } else {
                    
                }
            }
        }
    }
}


struct LeaderboardEntry: Identifiable, Decodable {
    @DocumentID var id: String?  // Automatically populated by Firestore
    var displayName: String
    var uid: String
    var dailyPoints: Int
    var allTimePoints: Int

    // You may need to adjust the properties to match the Firestore fields
}

struct LeaderboardView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var authViewModel: UserAuthViewModel
    @State private var countdown: String = "24" // To hold the countdown string
    @State private var timer: Timer?
    let isDarkMode: Bool
    @State private var selectedTab: String = "Daily"
    @StateObject var leaderboardVM = LeaderboardViewModel()
    
    let sampleFriends = [
        User(username: "Joshua Luo", points: 1275),
        User(username: "Michael Johnson", points: 620),
        User(username: "Liam O'Connor", points: 785),
        User(username: "Sofia Martinez", points: 350),
        User(username: "Emily Chen", points: 430),
        User(username: "Mia Thompson", points: 1125),
        User(username: "David Smith", points: 890),
        User(username: "Ava Patel", points: 220),
        User(username: "Brayden Watt", points: 190),
        User(username: "Enpeng Jiang", points: 50)
    ]
    
    var leaderboardEntries: [LeaderboardEntry] {
        selectedTab == "Daily" ? leaderboardVM.dailySorted : leaderboardVM.allTimeSorted
    }
    
    var currentUserRank: Int? {
        leaderboardEntries.firstIndex(where: { $0.uid == authViewModel.currentUserUid })?.advanced(by: 1)
    }

    func getRankColor(for rank: Int?) -> Color {
        guard let rank = rank else { return .black }  // Default color for invalid rank or no rank
        switch rank {
        case 1:
            return .yellow  // Yellow for rank 1
        case 2:
            return .gray  // Silver-ish color for rank 2
        case 3:
            return .brown  // Brown for rank 3
        default:
            return .black  // Gray for all other ranks
        }
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                (isDarkMode ? Color(red: 85/255, green: 130/255, blue: 65/255)
                            : Color(red: 123/255, green: 182/255, blue: 92/255))
                .frame(height: 500)
                VStack(alignment: .center, spacing: 16) {
                    Text("Leaderboard")
                        .font(.custom("Fredoka", size: 24))
                        .fontWeight(.semibold)
                    HStack(spacing: 12) {
                        ZStack {
                            
                            Rectangle()
                                .cornerRadius(32)
                                .foregroundColor(selectedTab == "Daily" ? .white : .clear)
                            Text("Daily")
                                .font(.custom("Fredoka", size: 18))
                                .fontWeight(selectedTab == "Daily" ? .medium : .medium)
                                .foregroundColor(selectedTab == "Daily" ? Color(red:123/255, green:182/255, blue:92/255) : .white)
                        }
                        .frame(height: 32)
                        .onTapGesture {
                            withAnimation {
                                selectedTab = "Daily"
                                Task {
                                    await leaderboardVM.fetchLeaderboard()
                                }
                            }
                        }
                        ZStack {
                           
                            Rectangle()
                                .cornerRadius(32)
                                .foregroundColor(selectedTab == "All Time" ? .white : .clear)
                            Text("All Time")
                                .font(.custom("Fredoka", size: 18))
                                .fontWeight(selectedTab == "All Time" ? .medium : .medium)
                                .foregroundColor(selectedTab == "All Time" ? Color(red:123/255, green:182/255, blue:92/255) : .white)
                        }
                        .frame(height: 32)
                        .onTapGesture {
                            withAnimation {
                                selectedTab = "All Time"
                                Task {
                                    await leaderboardVM.fetchLeaderboard()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(32)
                }
                .padding(.top, 420)
                .padding(.bottom, 24)
                .padding([.leading, .trailing])
            }
            .foregroundColor(.white)
                if selectedTab == "Daily" {
                    VStack {
                        HStack(spacing: 0) {
                            Spacer()
                            HStack (alignment: .center) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 24))
                                        .foregroundColor(.orange)
                                    VStack (alignment: .leading) {
                                        HStack (alignment: .bottom) {
                                            Text("\(Int(countdown) ?? 0)")
                                                .font(.custom("Fredoka", size: 22))
                                                .fontWeight(.heavy)
                                                .foregroundColor(.orange)
                                            Text("hours")
                                                .font(.custom("Fredoka", size: 18))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.orange)
                                        }
                                        Text("Resets In")
                                            .font(.custom("Fredoka", size: 16))
                                            .fontWeight(.medium)
                                            .foregroundColor(.gray)
                                            .opacity(0.8)
                                    }
                                }
                            .padding(.vertical, -4)
                            Spacer()
                            Divider()
                                .frame(width: 2)
                                .overlay(ThemeColors.Content.border(isDarkMode))
                                .padding(.vertical, -16)
                            Spacer()
                            HStack (alignment: .center) {
                                    Image(systemName: "medal.star")
                                        .font(.system(size: 26))
                                        .foregroundColor(self.getRankColor(for: currentUserRank))
                                    VStack (alignment: .leading) {
                                        HStack (alignment: .bottom, spacing: 0) {
                                            Text("#")
                                                .font(.custom("Fredoka", size: 18))
                                                .fontWeight(.medium)
                                                .foregroundColor(self.getRankColor(for: currentUserRank))
                                            
                                            Text(currentUserRank != nil ? "\(currentUserRank!)" : "-")
                                                .font(.custom("Fredoka", size: 24))
                                                .fontWeight(.heavy)
                                                .foregroundColor(self.getRankColor(for: currentUserRank))
                                        }

                                        // Helper function to return the color based on the rank
                                        

                                        Text("Your Rank")
                                            .font(.custom("Fredoka", size: 16))
                                            .fontWeight(.medium)
                                            .foregroundColor(.gray)
                                            .opacity(0.8)
                                    }
                                }
                            .padding(.vertical, -4)
                            Spacer()
                        }
                        .padding()
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
                        )
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, -5)
                    .padding(.bottom, 8)
                        
                    Rectangle()
                        .frame(height: 2)
                        .overlay(ThemeColors.Content.border(isDarkMode))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    
                    if leaderboardVM.isLoading {
                        ForEach(0..<5, id: \.self) { index in
                            VStack(spacing: 0) {

                                if index != 0 {
                                    LeaderboardCardSkeleton(isDarkMode: isDarkMode)
                                        .padding(.top, -16)
                                } else {
                                    LeaderboardCardSkeleton(isDarkMode: isDarkMode)
                                }

                                // Separator line (not after last)
                                if index < 4 {
                                    Rectangle()
                                        .frame(height: 2)
                                        .overlay(ThemeColors.Content.border(isDarkMode))
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 20)
                                        .padding(.bottom, -200)
                                }
                            }
                        }
                        .padding(.bottom, 48)

                    } else {
                        ForEach(leaderboardEntries.indices, id: \.self) { rank in
                            let current = leaderboardEntries[rank]
                            VStack (spacing: 0) {
                                if rank != leaderboardEntries.indices.first {
                                    LeaderboardCard(userViewModel: userViewModel, isDarkMode: isDarkMode, rank: rank + 1, user: current)
                                        .padding(.top, -16)
                                } else {
                                    LeaderboardCard(userViewModel: userViewModel, isDarkMode: isDarkMode, rank: rank + 1, user: current)
                                }
                                if rank < leaderboardEntries.indices.last! {
                                    Rectangle()
                                        .frame(height: 2)
                                        .overlay(ThemeColors.Content.border(isDarkMode))
                                        .frame(maxWidth: .infinity)
                                        .padding(.top)
                                        .padding(.bottom, -200)
                                }
                            }
                        }
                        .padding(.bottom, 48)
                    }
                } else {
                    VStack {
                        HStack(spacing: 0) {
                            Spacer()
                            HStack (alignment: .center) {
                                Image(systemName: "clock")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)
                                VStack (alignment: .leading) {
                                    HStack (alignment: .bottom) {
                                        Text("Never!")
                                            .font(.custom("Fredoka", size: 22))
                                            .fontWeight(.heavy)
                                            .foregroundColor(.orange)
                                        
                                    }
                                    Text("Resets In")
                                        .font(.custom("Fredoka", size: 16))
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                        .opacity(0.8)
                                }
                            }
                            .padding(.vertical, -4)
                            Spacer()
                            Divider()
                                .frame(width: 2)
                                .overlay(ThemeColors.Content.border(isDarkMode))
                                .padding(.vertical, -16)
                            Spacer()
                            HStack (alignment: .center) {
                                Image(systemName: "medal.star")
                                    .font(.system(size: 26))
                                    .foregroundColor(self.getRankColor(for: currentUserRank))
                                VStack (alignment: .leading) {
                                    HStack (alignment: .bottom, spacing: 0) {
                                        Text("#")
                                            .font(.custom("Fredoka", size: 18))
                                            .fontWeight(.medium)
                                            .foregroundColor(self.getRankColor(for: currentUserRank))
                                        
                                        Text(currentUserRank != nil ? "\(currentUserRank!)" : "-")
                                            .font(.custom("Fredoka", size: 24))
                                            .fontWeight(.heavy)
                                            .foregroundColor(self.getRankColor(for: currentUserRank))
                                    }

                                    // Helper function to return the color based on the rank
                                
                                    Text("Your Rank")
                                        .font(.custom("Fredoka", size: 16))
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                        .opacity(0.8)
                                }
                            }
                            .padding(.vertical, -4)
                            Spacer()
                        }
                        .padding()
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
                        )
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, -5)
                    .padding(.bottom, 8)
                    
                    Rectangle()
                        .frame(height: 2)
                        .overlay(ThemeColors.Content.border(isDarkMode))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    
                    if leaderboardVM.isLoading {
                        ForEach(0..<5, id: \.self) { index in
                            VStack(spacing: 0) {

                                if index != 0 {
                                    LeaderboardCardSkeleton(isDarkMode: isDarkMode)
                                        .padding(.top, -16)
                                } else {
                                    LeaderboardCardSkeleton(isDarkMode: isDarkMode)
                                }

                                // Separator line (not after last)
                                if index < 4 {
                                    Rectangle()
                                        .frame(height: 2)
                                        .overlay(ThemeColors.Content.border(isDarkMode))
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 20)
                                        .padding(.bottom, -200)
                                }
                            }
                        }
                        .padding(.bottom, 48)

                    } else {
                        ForEach(leaderboardEntries.indices, id: \.self) { rank in
                            let current = leaderboardEntries[rank]
                            VStack (spacing: 0) {
                                if rank != leaderboardEntries.indices.first {
                                    LeaderboardCardAllTime(userViewModel: userViewModel, isDarkMode: isDarkMode, rank: rank + 1, user: current)
                                        .padding(.top, -16)
                                } else {
                                    LeaderboardCardAllTime(userViewModel: userViewModel, isDarkMode: isDarkMode, rank: rank + 1, user: current)
                                }
                                if rank < leaderboardEntries.indices.last! { // Avoid line after the last card
                                    Rectangle()
                                        .frame(height: 2)
                                        .overlay(ThemeColors.Content.border(isDarkMode))
                                        .frame(maxWidth: .infinity)
                                        .padding(.top)
                                        .padding(.bottom, -200)
                                    
                                }
                            }
                            
                        }
                        .padding(.bottom, 48)
                    }
                }
        }
        .onAppear {
            updateCountdown()
            startTimer()
            
            // Perform async operation in a Task
            Task {
                await leaderboardVM.fetchLeaderboard()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            updateCountdown()
        }
    }
    
    private func updateCountdown() {
        let calendar = Calendar.current
        let now = Date()
        let midnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime)!
        
        let timeInterval = midnight.timeIntervalSince(now)
        let hours = Int(timeInterval) / 3600
        
        countdown = String(format: "%02d", hours) // Update countdown string
    }
}

struct LeaderboardCard: View {
    @ObservedObject var userViewModel: UserViewModel
    let isDarkMode: Bool
    var rank: Int
    var user: LeaderboardEntry

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            if rank <= 3 {
                Image(systemName: "medal.fill")
                    .font(.custom("Fredoka", size: 24))
                    .fontWeight(.semibold)
                    .foregroundColor(medalColor)
            } else {
                Text("\(rank)")
                    .font(.custom("Fredoka", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
            }
            
            // Profile Image Circle
            Circle()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .opacity(0.8)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                )

            
            // Username
            Text(user.displayName)
                .font(.custom("Fredoka", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.Text.primary(isDarkMode))
            
            Spacer()
            
            // Level Text
            Text("\(user.dailyPoints) pts")
                .font(.custom("Fredoka", size: 18))
                .fontWeight(.regular)
                .foregroundColor(ThemeColors.Text.primary(isDarkMode))
        }
        .padding([.horizontal])
    }
    
    private var medalColor: Color {
            switch rank {
            case 1: return .yellow
            case 2: return .gray
            case 3: return .brown
            default: return .clear
            }
        }
}

struct LeaderboardCardAllTime: View {
    @ObservedObject var userViewModel: UserViewModel
    let isDarkMode: Bool
    var rank: Int
    var user: LeaderboardEntry

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            if rank <= 3 {
                Image(systemName: "medal.fill")
                    .font(.custom("Fredoka", size: 24))
                    .fontWeight(.semibold)
                    .foregroundColor(medalColor)
            } else {
                Text("\(rank)")
                    .font(.custom("Fredoka", size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
            }
            
            // Profile Image Circle
            Circle()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .opacity(0.8)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                )

            
            // Username
            Text(user.displayName)
                .font(.custom("Fredoka", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.Text.primary(isDarkMode))
            
            Spacer()
            
            // Level Text
            Text("\(user.allTimePoints) pts")
                .font(.custom("Fredoka", size: 18))
                .fontWeight(.regular)
                .foregroundColor(ThemeColors.Text.primary(isDarkMode))
        }
        .padding([.horizontal])
    }
    
    private var medalColor: Color {
            switch rank {
            case 1: return .yellow
            case 2: return .gray
            case 3: return .brown
            default: return .clear
            }
        }
}
