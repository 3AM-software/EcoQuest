import SwiftUI
import SVGKit

struct ContentView: View {
    // State to keep track of the selected tab
    @State private var selectedTab: String = "Leaf"
    
    var body: some View {
        ZStack {
            Color(red: 249/255,green: 250/255,blue:251/255)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderTitleView()
                ScrollView {
                    VStack(alignment: .center) {
                        ProfileInfoView()
                            .padding(.top, -70)
                        StreakBadge()
                        // Switch view based on selected tab
                        if selectedTab == "Leaf" {
                            QuestsView()
                                .padding(.bottom, 10)
                            ImpactView()
                        } else if selectedTab == "Awards" {
                            AwardsView()
                        } else if selectedTab == "Users" {
                            UserProfile()
                                .padding(.bottom, 10)
                            UserOverview()
                                .padding(.bottom, 10)
                            ShareAppView()
                                .padding(.bottom, 10)
                        }
                    }
                }
                bottomNavBar
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var bottomNavBar: some View {
        HStack {
            ForEach(["Leaf", "Awards", "Users"], id: \.self) { icon in
                VStack(spacing: 4) {
                    Image(systemName: getSystemImage(for: icon))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    Text(tabTitle(for: icon))
                        .font(.caption)
                        .fontWeight(/*@START_MENU_TOKEN@*/.regular/*@END_MENU_TOKEN@*/)
                }
                .foregroundColor(selectedTab == icon ? .green : .gray)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedTab = icon
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2)),
            alignment: .top
        )
    }
    
    // Helper function for tab titles
    func tabTitle(for icon: String) -> String {
        switch icon {
        case "Leaf": return "Home"
        case "Awards": return "Awards"
        case "Users": return "User"
        default: return ""
        }
    }
    
    // Helper function for system icons
    func getSystemImage(for icon: String) -> String {
        switch icon {
        case "Leaf": return "leaf"
        case "Awards": return "medal"
        case "Users": return "person"
        default: return "leaf"
        }
    }
}

struct AwardsView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Completed Quests")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("2 Completed Quests")
                    .foregroundColor(.green)
                    .font(.subheadline)
            }
            ForEach(completedQuests.filter { $0.isCompleted }, id: \.title) { quest in
                QuestView(quest: quest)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 1)
    }
}

struct QuestsView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Challenges")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("1/2 Completed")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            ForEach(dailyQuests, id: \.title) { quest in
                QuestView(quest: quest)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 1)
    }
}

struct QuestView: View {
    let quest: Quest
    @Namespace private var animationNamespace
    var body: some View {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: quest.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(quest.isCompleted ? .green : .blue)
                        
                        VStack(alignment: .leading) {
                            Text(quest.title)
                            if let completionTime = quest.completionTime {
                                Text("Completed \(completionTime)")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            } else {
                                Text(String(format: "%.0f%% Completed", quest.progress * 100))
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                        }
                        
                        Spacer()
                        
                        Text("+\(quest.points)pts")
                            .fontWeight(quest.isCompleted ? .bold : .medium)
                            .foregroundColor(quest.isCompleted ? .green : .blue)
                    }
                    
                    if !quest.isCompleted {
                        ProgressBar(progress: quest.progress)
                    }
                }
                .padding()
                .background(
                    quest.isCompleted
                    ? Color.green.opacity(0.1)
                    : Color.blue.opacity(0.1)
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.4), lineWidth: quest.isCompleted ? 0 : 1.5))
                .matchedGeometryEffect(id: quest.id, in: animationNamespace)
                
                if quest.isCompleted {
                    Image(systemName: "trophy.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }
            .animation(.easeInOut, value: quest.isCompleted)
        }
}

struct ProgressBar: View {
    let progress: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: CGFloat(progress) * geometry.size.width, height: 8)
                    .cornerRadius(4)
            }
        }
        .frame(height: 8)
    }
}

struct Quest: Identifiable {
    let id = UUID()
    let title: String
    let points: Int
    let icon: String
    let progress: Float
    let isCompleted: Bool
    let completionTime: String?
}

let dailyQuests: [Quest] = [
    Quest(title: "Use a reusable water bottle", points: 50, icon: "leaf", progress: 1.0, isCompleted: true, completionTime: "at 8:30 AM"),
    Quest(title: "Recycle 3 items", points: 30, icon: "arrow.3.trianglepath", progress: 0.66, isCompleted: false, completionTime: nil),
]

let completedQuests: [Quest] = [
    Quest(title: "Use a reusable water bottle", points: 50, icon: "leaf", progress: 1.0, isCompleted: true, completionTime: "on Oct. 21, 2024"),
    Quest(title: "Recycle 3 items", points: 30, icon: "arrow.3.trianglepath", progress: 1, isCompleted: true, completionTime: "on Oct. 21, 2024"),
]

struct ImpactView: View {
    // MARK: - Properties
    let carbonSaved: Int = 2450
    let energySaved: Int = 384
    let waterSaved: Int = 1280
    let wasteReduced: Int = 86
    
    let co2String: String
    let energyString: String
    let waterString: String
    let wasteString: String
    
    // Animation states
    @State private var showCards = false
    @State private var selectedCard: Int? = nil
    @Namespace private var namespace
    
    // MARK: - Initialization
    init() {
        self.co2String = String(carbonSaved)
        self.energyString = String(energySaved)
        self.waterString = String(waterSaved)
        self.wasteString = String(wasteReduced)
    }
    
    // Card data
    let cards = [
        ImpactCardData(
            gradient: [Color(red: 16/255, green: 185/255, blue: 129/255),
                      Color(red: 5/255, green: 150/255, blue: 105/255)],
            icon: "leaf.fill",
            title: "CO₂ Saved",
            detail: """
            Your carbon savings are making a real difference:
            • Equivalent to 100 car trips avoided
            • Equal to planting 40 trees
            • Offset of 3 months of energy use
            
            Keep up the great work! Your daily choices are helping combat climate change.
            """
        ),
        ImpactCardData(
            gradient: [Color(red: 245/255, green: 158/255, blue: 11/255),
                      Color(red: 234/255, green: 138/255, blue: 0/255)],
            icon: "bolt.fill",
            title: "Energy Saved",
            detail: """
            Your energy conservation efforts:
            • Powered 38 homes for a day
            • Saved 384 kWh of electricity
            • Reduced peak grid demand
            
            These savings help reduce strain on power plants and promote sustainability.
            """
        ),
        ImpactCardData(
            gradient: [Color(red: 59/255, green: 130/255, blue: 246/255),
                      Color(red: 37/255, green: 99/255, blue: 235/255)],
            icon: "drop.fill",
            title: "Water Saved",
            detail: """
            Your water conservation impact:
            • Saved 6,400 glasses of water
            • Equivalent to 32 full bathtubs
            • Protected vital water resources
            
            Every drop counts in preserving our planet's most precious resource.
            """
        ),
        ImpactCardData(
            gradient: [Color(red: 139/255, green: 92/255, blue: 246/255),
                      Color(red: 124/255, green: 58/255, blue: 237/255)],
            icon: "arrow.3.trianglepath",
            title: "Waste Reduced",
            detail: """
            Your waste reduction achievements:
            • Prevented 430 plastic bags from landfills
            • Recycled 86 kg of materials
            • Saved valuable landfill space
            
            Your efforts help create a cleaner, more sustainable future.
            """
        )
    ]
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Your Impact")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    
                    Menu {
                        Button("This Month", action: {})
                        Button("Last Month", action: {})
                        Button("This Year", action: {})
                    } label: {
                        Text("This Month")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(Array(zip(cards.indices, cards)), id: \.0) { index, card in
                        CompactCardView(
                            card: card,
                            value: getValue(for: index),
                            unit: getUnit(for: index),
                            show: showCards
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedCard = index
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
            .shadow(radius: 1)
            
            // Full screen expanded card
            if let selected = selectedCard {
                ExpandedCardView(
                    card: cards[selected],
                    value: getValue(for: selected),
                    unit: getUnit(for: selected),
                    onClose: {
                        withAnimation(.easeInOut) {
                            selectedCard = nil
                        }
                    }
                )
                .zIndex(1)
                .transition(.move(edge: .bottom))
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures full screen fill
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            showCards = true // Show cards immediately without animation
        }
    }
    
    private func getValue(for index: Int) -> String {
        switch index {
        case 0: return co2String
        case 1: return energyString
        case 2: return waterString
        case 3: return wasteString
        default: return ""
        }
    }
    
    private func getUnit(for index: Int) -> String {
        switch index {
        case 0: return "kg"
        case 1: return "kWh"
        case 2: return "L"
        case 3: return "kg"
        default: return ""
        }
    }
}

// MARK: - Supporting Types
struct ImpactCardData {
    let gradient: [Color]
    let icon: String
    let title: String
    let detail: String
}

// MARK: - Compact Card View
struct CompactCardView: View {
    let card: ImpactCardData
    let value: String
    let unit: String
    let show: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: card.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: card.icon)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack {
                    Text(value)
                        .font(.system(size: 28))
                        .tracking(-0.5)
                        .fontWeight(.heavy)
                    Text(unit)
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                
                Text(card.title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
            .padding(.leading, -15)
        }
        .frame(height: 140)
        .opacity(show ? 1 : 0) // Always show compact cards
    }
}

// MARK: - Expanded Card View
struct ExpandedCardView: View {
    let card: ImpactCardData
    let value: String
    let unit: String
    let onClose: () -> Void // Close action closure

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: card.icon)
                    .font(.title)
                    .foregroundColor(.white)
                Text(card.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: onClose) { // Close button
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(size: 48))
                    .fontWeight(.heavy)
                Text(unit)
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            
            
            Text(card.detail)
                .font(.body)
                .foregroundColor(.white)

                .multilineTextAlignment(.leading)
                .padding(.vertical)
        
            Spacer()
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: card.gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.bottom)
        .transition(.move(edge: .bottom))
        .cornerRadius(16)
    }
}

    // MARK: - Preview Provider
struct ImpactView_Previews: PreviewProvider {
    static var previews: some View {
        ImpactView()
    }
}

struct HeaderTitleView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 22/255, green: 162/255, blue: 74/255),
                    Color(red: 17/255, green: 185/255, blue: 129/255)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 100)
            HStack {
                Text("EcoQuest")
                    .font(.system(size: 26))
                    .tracking(-0.5)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                Spacer()
                Image("Shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.white)
            }
            .padding([.leading, .trailing], 20.0)
            .padding(.top, 35)
        }
    }
}

struct ProfileInfoView: View {
    @State private var levelProgress: Double = 0.7
    let user: String = "Eco Warrior"
    let level: Int = 7
    let points: Int = 1250
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 22/255, green: 162/255, blue: 74/255),
                    Color(red: 17/255, green: 185/255, blue: 129/255)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 250)
            .cornerRadius(25)
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.yellow)
                            Text("Level 12 Warrior")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Text("Next: 550 pts")
                            .font(.subheadline)
                    }
                    
                    LevelProgressBar(progress: levelProgress)
                    
                    // Points Display
                    HStack {
                        VStack(alignment: .leading) {
                            Text("2,450")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Total Points")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("+125")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Today's Points")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(16)
            }
            .padding(.top, 40)
            .padding([.leading,.trailing])
        }
        .foregroundColor(.white)
    }
    
    
}

struct LevelProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.yellow)
                    .frame(width: geometry.size.width * progress, height: 12)
            }
        }
        .frame(height: 12)
    }
}

struct StreakBadge: View{
    var body: some View {
        HStack(spacing: 8) {
            Text("🔥")
            Text("15 Day Streak!")
                .fontWeight(.bold)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 4)
        .offset(y: -20)
    }
}

struct UserOverview: View {
    var totalPoints: Int = 1200 // Example value
    var streak: Int = 5 // Example value
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Overview")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
            }
            HStack {
                // Rectangle for Total Points
                VStack(alignment: .center) {
                    Text("Graph Coming Soon")
                        .font(.headline)
                        .padding(.bottom, 2)
                }
                .frame(width: 150, height: 100) // Set your desired size
                .background(Color.white)
                .cornerRadius(10)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth:1.5))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 1)
    }
}

struct UserProfile: View {
    @State private var showSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Arco23")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showSettings.toggle() // Show settings when the gear icon is tapped
                }) {
                    HStack {
                        Image(systemName: "gearshape")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .presentationDetents([.medium, .fraction(0.75),.height(700)])
                }
            }
            
            HStack {
                Text("@Arco23")
                    .font(.body)
                    .foregroundColor(.gray)
                Spacer()
                Text("Joined October 2024")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 1)
    }
}

struct SettingsView: View {
    @State private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            Form {
                Toggle("Dark Mode", isOn: $isDarkMode)
                // Additional settings options can be added here
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                dismissSettingsView()
            })
        }
    }
    
    private func dismissSettingsView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

struct ShareAppView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Share This App")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Share icon
                Button(action: {
                    // Action to share the app goes here
                    shareApp()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .foregroundColor(.blue)
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            Text("Help us spread the word! Share this app with your friends and family.")
                .font(.body)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 1)
    }
    
    func shareApp() {
        // Implement sharing functionality here
        // For example, using UIActivityViewController in UIKit
        print("Sharing the app...")
    }
}

#Preview {
    ContentView()
}
