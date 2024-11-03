import SwiftUI

// Sample data model for a friend
struct User: Identifiable {
    let id = UUID()
    let username: String
    let color: Color
    let points: Int
}

// Sample data for friends (mockup data)
struct Community: View {
    @ObservedObject var userViewModel: UserViewModel
    let isDarkMode: Bool
    let communityTab: String
    
    init(userViewModel: UserViewModel, isDarkMode: Bool, communityTab: String) {
        self.userViewModel = userViewModel
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
                    LeaderboardView(userViewModel: userViewModel, isDarkMode: isDarkMode)
                        .padding(.top, -420)
                        .padding(.bottom, -32)
                } else {
                    
                }
            }
        }
    }
}

struct LeaderboardView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var countdown: String = "24" // To hold the countdown string
    @State private var timer: Timer?
    let isDarkMode: Bool
    @State private var selectedTab: String = "Daily"

    let sampleFriends = [
        User(username: "Joshua Luo", color: Color.blue, points: 1275),
        User(username: "Michael Johnson", color: Color.yellow, points: 620),
        User(username: "Liam O'Connor", color: Color.green, points: 785),
        User(username: "Sofia Martinez", color: Color.purple, points: 350),
        User(username: "Emily Chen", color: Color.orange, points: 430),
        User(username: "Mia Thompson", color: Color.indigo, points: 1125),
        User(username: "David Smith", color: Color.gray, points: 890),
        User(username: "Ava Patel", color: Color.pink, points: 220),
        User(username: "Brayden Watt", color: Color.teal, points: 190),
        User(username: "Enpeng Jiang", color: Color.red, points: 50)
    ]

    var body: some View {
        ScrollView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 22/255, green: 162/255, blue: 74/255),
                        Color(red: 17/255, green: 185/255, blue: 129/255)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 550)
                VStack(alignment: .center, spacing: 16) {
                    Text("Leaderboard")
                        .font(.custom("Fredoka", size: 24))
                        .fontWeight(.semibold)
                    HStack(spacing: 12) {
                        ZStack {
                            Text("Daily")
                                .font(.custom("Fredoka", size: 18))
                                .fontWeight(selectedTab == "Daily" ? .medium : .medium)
                                .foregroundColor(selectedTab == "Daily" ? .white : .white)
                            Rectangle()
                                .cornerRadius(16)
                                .foregroundColor(selectedTab == "Daily" ? Color.white.opacity(0.2) : .clear)
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            withAnimation {
                                selectedTab = "Daily"
                            }
                        }
                        ZStack {
                            Text("All Time")
                                .font(.custom("Fredoka", size: 18))
                                .fontWeight(selectedTab == "All Time" ? .medium : .medium)
                                .foregroundColor(selectedTab == "All Time" ? .white : .white)
                            Rectangle()
                                .cornerRadius(16)
                                .foregroundColor(selectedTab == "All Time" ? Color.white.opacity(0.2) : .clear)
                        }
                        .frame(height: 40)
                        .onTapGesture {
                            withAnimation {
                                selectedTab = "All Time"
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(20)
                }
                .padding(.top, 380)
                .padding([.leading, .trailing])
                .padding(.bottom, -32)
            }
            .foregroundColor(.white)
                if selectedTab == "Daily" {
                    VStack {
                        HStack(spacing: 16) {
                            Spacer()
                            VStack (spacing: 8) {
                                Text("Resets In")
                                    .font(.custom("Fredoka", size: 18))
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 18))
                                        .foregroundColor(.orange)
                                    Text("\(countdown) hours")
                                        .font(.custom("Fredoka", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(.vertical, -4)
                            Spacer()
                            Divider()
                                .frame(width: 2)
                                .overlay(ThemeColors.Content.border(isDarkMode))
                                .padding(.vertical, -16)
                            Spacer()
                            VStack (spacing: 8) {
                                Text("Your Rank")
                                    .font(.custom("Fredoka", size: 18))
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                                HStack {
                                    Image(systemName: "medal.star")
                                        .font(.system(size: 18))
                                        .foregroundColor(.yellow)
                                    Text("#1")
                                        .font(.custom("Fredoka", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.yellow)
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
                    .padding(.vertical, 8)
                        
                    Rectangle()
                        .frame(height: 2)
                        .overlay(ThemeColors.Content.border(isDarkMode))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    
                    ForEach(sampleFriends.indices, id: \.self) { rank in
                        let current = sampleFriends[rank]
                        LeaderboardCard(userViewModel: userViewModel, isDarkMode: isDarkMode, rank: rank + 1, user: current)
                    }
                    .padding(.bottom, 48)
                } else {
                    VStack {
                        HStack(spacing: 16) {
                            Spacer()
                            VStack (spacing: 8) {
                                Text("Resets In")
                                    .font(.custom("Fredoka", size: 18))
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.system(size: 18))
                                        .foregroundColor(.orange)
                                    Text("Never!")
                                        .font(.custom("Fredoka", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(.vertical, -4)
                            Spacer()
                            Divider()
                                .frame(width: 2)
                                .overlay(ThemeColors.Content.border(isDarkMode))
                                .padding(.vertical, -16)
                            Spacer()
                            VStack (spacing: 8) {
                                Text("Your Rank")
                                    .font(.custom("Fredoka", size: 18))
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                                HStack {
                                    Image(systemName: "medal.star")
                                        .font(.system(size: 18))
                                        .foregroundColor(.yellow)
                                    Text("#1")
                                        .font(.custom("Fredoka", size: 18))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.yellow)
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
                    .padding(.vertical, 8)
                    
                    Rectangle()
                        .frame(height: 2)
                        .overlay(ThemeColors.Content.border(isDarkMode))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    
                    ForEach(sampleFriends.indices, id: \.self) { rank in
                        let current = sampleFriends[rank]
                        LeaderboardCard(userViewModel: userViewModel, isDarkMode: isDarkMode, rank: rank + 1, user: current)
                    }
                    .padding(.bottom, 48)
                }
        }
        .onAppear {
            updateCountdown()
            startTimer()
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
    var user: User

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
            Text(user.username)
                .font(.custom("Fredoka", size: 18))
                .fontWeight(.medium)
                .foregroundColor(ThemeColors.Text.primary(isDarkMode))
            
            Spacer()
            
            // Level Text
            Text("\(user.points)pts")
                .font(.custom("Fredoka", size: 18))
                .fontWeight(.regular)
                .foregroundColor(.gray)
        }
        .padding([.horizontal])
        .padding(.vertical, -8)
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
