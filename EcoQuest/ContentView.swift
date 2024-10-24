import SwiftUI
import Foundation
import UIKit
import AVFoundation
import Combine
import ConfettiSwiftUI

#if targetEnvironment(simulator)
import MockImagePicker
typealias UIImagePickerController = MockImagePicker
typealias UIImagePickerControllerDelegate = MockImagePickerDelegate
#endif



struct ThemeColors {
    static let primary = Color(red: 22/255, green: 162/255, blue: 74/255)
    static let primaryGradient = [
        Color(red: 22/255, green: 162/255, blue: 74/255),
        Color(red: 17/255, green: 185/255, blue: 129/255)
    ]
    
    struct Background {
        static func primary(_ isDark: Bool) -> Color {
            isDark ? Color(red: 20/255, green: 31/255, blue: 37/255) : Color.white
        }
    }
    
    struct Content {
        static func primary(_ isDark: Bool) -> Color {
            isDark ? Color.white : Color.black
        }
        
        static func border(_ isDark: Bool) -> Color {
            isDark ? Color(red: 56/255, green: 70/255, blue: 80/255) : Color(red: 229/255, green: 229/255, blue: 229/255)
        }
    }
    
    struct Card {
        static func background(_ isDark: Bool) -> Color {
            isDark ? Color(red: 20/255, green: 31/255, blue: 37/255) : Color.white
        }
    }
}

class UserViewModel: ObservableObject {
    @Published var showAwardPopup = false
    @Published var awardNum = 0

    @Published var totalpoints: Int {
        didSet {
            UserDefaults.standard.set(totalpoints, forKey: "totalPoints")
        }
    }
    
    @Published var todaypoints: Int {
        didSet {
            UserDefaults.standard.set(todaypoints, forKey: "todayPoints")
        }
    }

    @Published var streak: Int {
        didSet {
            UserDefaults.standard.set(streak, forKey: "streak")
        }
    }
    
    @Published var highStreak: Int {
        didSet {
            UserDefaults.standard.set(highStreak, forKey: "hStreak")
        }
    }
    
    @Published var lastActionDate: Date {
        didSet {
            UserDefaults.standard.set(lastActionDate, forKey: "lastActionDate")
        }
    }
    
    @Published var co2: Int {
        didSet {
            UserDefaults.standard.set(co2, forKey: "co2")
        }
    }

    @Published var energy: Int {
        didSet {
            UserDefaults.standard.set(energy, forKey: "energy")
        }
    }

    @Published var bottles: Int {
        didSet {
            UserDefaults.standard.set(bottles, forKey: "bottles")
        }
    }
    
    @Published var waste: Float {
        didSet {
            UserDefaults.standard.set(waste, forKey: "waste")
        }
    }
    
    @Published var trips: Int {
        didSet {
            UserDefaults.standard.set(trips, forKey: "trips")
        }
    }
    
    @Published var trees: Int {
        didSet {
            UserDefaults.standard.set(trees, forKey: "trees")
        }
    }

    @Published var highestWeeklyQuests: Int {
        didSet {
            UserDefaults.standard.set(highestWeeklyQuests, forKey: "hQuests")
        }
    }
    
    @Published var highestDailyPoints: Int {
        didSet {
            UserDefaults.standard.set(highestDailyPoints, forKey: "hPoints")
        }
    }
    
    @Published var dateOfHighestDailyPoints: Date? {
        didSet {
            UserDefaults.standard.set(dateOfHighestDailyPoints, forKey: "dateOfHighestDailyPoints")
        }
    }
    
    @Published var dateOfHighestStreak: Date? {
        didSet {
            UserDefaults.standard.set(dateOfHighestStreak, forKey: "dateOfHighestStreak")
        }
    }
    
    @Published var bottleActions: Int {
        didSet {
            UserDefaults.standard.set(bottleActions, forKey: "reusableBottle")
        }
    }
    
    @Published var recycleActions: Int {
        didSet {
            UserDefaults.standard.set(recycleActions, forKey: "recyclableItem")
        }
    }
    
    @Published var transportAction: Int {
        didSet {
            UserDefaults.standard.set(transportAction, forKey: "publicTransport")
        }
    }
    
    @Published var treeAction: Int {
        didSet {
            UserDefaults.standard.set(treeAction, forKey: "plantTree")
        }
    }
    
    @Published var lightAction: Int {
        didSet {
            UserDefaults.standard.set(lightAction, forKey: "switchLight")
        }
    }
    
    @Published var numQuests: Int {
        didSet {
            UserDefaults.standard.set(numQuests, forKey: "numQuests")
        }
    }
    
    @Published var dateOfNumQuests: Date? {
        didSet {
            UserDefaults.standard.set(dateOfNumQuests, forKey: "dateOfNumQuests")
        }
    }
    @Published var firstAwardUnlocked: Bool = false {
            didSet {
                UserDefaults.standard.set(firstAwardUnlocked, forKey: "firstAwardUnlocked")
            }
        }

    init() {
        self.totalpoints = UserDefaults.standard.integer(forKey: "totalPoints")
        self.todaypoints = UserDefaults.standard.integer(forKey: "todayPoints")
        self.streak = UserDefaults.standard.integer(forKey: "streak")
        self.highStreak = UserDefaults.standard.integer(forKey: "hStreak")
        self.lastActionDate = UserDefaults.standard.object(forKey: "lastActionDate") as? Date ?? Date()
        self.co2 = UserDefaults.standard.integer(forKey: "co2")
        self.firstAwardUnlocked = UserDefaults.standard.bool(forKey: "firstAwardUnlocked")
        self.energy = UserDefaults.standard.integer(forKey: "energy")
        self.waste = UserDefaults.standard.float(forKey: "waste")
        self.bottles = UserDefaults.standard.integer(forKey: "bottles")
        self.bottleActions = UserDefaults.standard.integer(forKey: "reusableBottle")
        self.recycleActions = UserDefaults.standard.integer(forKey: "recyclableItem")
        self.transportAction = UserDefaults.standard.integer(forKey: "publicTransport")
        self.treeAction = UserDefaults.standard.integer(forKey: "plantTree")
        self.lightAction = UserDefaults.standard.integer(forKey: "switchLight")
        self.highestWeeklyQuests = UserDefaults.standard.integer(forKey: "hQuests")
        self.highestDailyPoints = UserDefaults.standard.integer(forKey: "hPoints")
        self.dateOfHighestDailyPoints = UserDefaults.standard.object(forKey: "dateOfHighestDailyPoints") as? Date
        self.dateOfHighestStreak = UserDefaults.standard.object(forKey: "dateOfHighestStreak") as? Date
        self.dateOfNumQuests = UserDefaults.standard.object(forKey: "dateOfNumQuests") as? Date
        self.numQuests = UserDefaults.standard.integer(forKey: "numQuests")
        self.trees = UserDefaults.standard.integer(forKey: "trees")
        self.trips = UserDefaults.standard.integer(forKey: "trips")
    }
    
    func checkAndUpdateStreak() {
        let calendar = Calendar.current
        if calendar.isDateInYesterday(lastActionDate) {
            // If the last action date was yesterday, continue the streak
            incrementStreak()
            if streak > highStreak {
                setHighestStreak(streak)
                dateOfHighestStreak = Date()
            }
        } else if !calendar.isDateInToday(lastActionDate) {
            // If the last action date wasn't today or yesterday, reset the streak
            resetStreak()
        }
    }

    func setHighestStreak(_ high: Int) {
        highStreak = high
    }

    func setHighestDailyPoints(_ high: Int) {
        highestDailyPoints = high
    }

    func addPoints(_ pointsToAdd: Int) {
        
        totalpoints += pointsToAdd
        todaypoints += pointsToAdd
        if todaypoints > highestDailyPoints {
            setHighestDailyPoints(todaypoints)
            dateOfHighestDailyPoints = Date()
        }
        numQuests += 1
        dateOfNumQuests = Date()
        if !firstAwardUnlocked && totalpoints >= 1 {
            firstAwardUnlocked = true
            withAnimation {
                showAwardPopupWithDelay()
            }
            awardNum = 0
        }
    }
    
    func showAwardPopupWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showAwardPopup = true
        }
    }

    func resetPoints() {
        todaypoints = 0
    }

    func addActions(_ action: String) {
        // Your existing code to increment actions
        if action == "reusableBottle" {
            bottleActions += 1
            bottles += 2
        } else if action == "recyclableItem" {
            recycleActions += 1
            waste += 0.15
        } else if action == "publicTransport" {
            transportAction += 1
            co2 += 9
            trips += 1
        } else if action == "plantTree" {
            treeAction += 1
            co2 += 1
            trees += 1
        } else if action == "switchLight" {
            lightAction += 1
            energy += 1
        }
        
        // Update the streak after performing an action
        let today = Date()
        let calendar = Calendar.current
        
        if !calendar.isDateInToday(lastActionDate) {
            if calendar.isDateInYesterday(lastActionDate) {
                incrementStreak()
            } else {
                resetStreak()
            }
        }
        
        // Update the last action date
        lastActionDate = today
    }
    
    func resetActions() {
        bottleActions = 0
        recycleActions = 0
        transportAction = 0
        treeAction = 0
        lightAction = 0
    }
    
    func resetAll() {
        totalpoints = 0
        todaypoints = 0
        streak = 0
        highStreak = 0
        co2 = 0
        trees = 0
        energy = 0
        trips = 0
        waste = 0
        bottles = 0
        resetActions()
        dateOfHighestDailyPoints = nil
        dateOfHighestStreak = nil
        dateOfNumQuests = nil
        numQuests = 0
    }

    func incrementStreak() {
        streak += 1
    }

    func resetStreak() {
        streak = 0
    }
}

struct AwardPopupView: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let awardNum: Int
    let isDarkMode: Bool
    
    var body: some View {
        
        let awards = [
            (icon: "star.fill", text: "First Steps", color: Color.yellow),
            (icon: "flame.fill", text: "On Fire", color: Color.orange),
            (icon: "shield.fill", text: "Warrior", color: Color.blue),
            (icon: "leaf.arrow.circlepath", text: "Dedicated", color: Color.red),
            (icon: "leaf.fill", text: "Nature Friend", color: Color.green),
            (icon: "crown.fill", text: "Champion", color: Color.purple)
        ]
        
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // Popup content
            VStack(spacing: 20) {
                // Trophy image
                ZStack {
                    // Background rectangle
                    RoundedRectangle(cornerRadius: 8)
                        .fill(awards[awardNum].color.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(awards[awardNum].color, lineWidth: 2)
                        )
                        .frame(width: 65, height: 65)
                        .rotationEffect(.degrees(45))
                    
                    // Icon
                    Image(systemName: awards[awardNum].icon)
                        .font(.system(size: 24))
                        .foregroundColor(awards[awardNum].color)
                }
                .frame(width: 80, height: 80) // Larger frame to accommodate rotation
                .padding(.bottom,4)
                
                // Title
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Message
                Text("You have unlocked the \(awards[awardNum].text) award!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                // Celebration effects
                HStack(spacing: 15) {
                    Image(systemName: "star.fill")
                        .foregroundColor(awards[awardNum].color)
                    Image(systemName: "star.fill")
                        .foregroundColor(awards[awardNum].color)
                    Image(systemName: "star.fill")
                        .foregroundColor(awards[awardNum].color)
                }
                
                // Close button
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ThemeColors.Card.background(isDarkMode))
                    .shadow(radius: 10)
            )
            .padding(40)
            .transition(.scale)
        }
    }
}

struct LoadingOverlay: View {
    let isDarkMode: Bool
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea(.all)
            
            // Overlay content
            VStack(spacing: 20) {
                // Circular loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.5)
                    .padding()
                
                // Loading message
                Text("Processing Quest")
                    .foregroundColor(isDarkMode ? .white : .black)
                    .font(.custom("Fredoka", size: 20))
                    .fontWeight(.semibold)
                    .padding(.top, 8)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ThemeColors.Card.background(isDarkMode)) // Dark background with some transparency
                    .shadow(radius: 10)
            )
            .padding(40)
            .transition(.scale)
        }
    }
}
struct ErrorOverlay: View {
    let isDarkMode: Bool
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .ignoresSafeArea(.all)
            
            // Overlay content
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 24))
                
                Text("You didn't meet the quest requirement!")
                    .foregroundColor(.red)
                    .font(.custom("Fredoka", size: 20))
                    .fontWeight(.semibold)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ThemeColors.Card.background(isDarkMode)) // Dark background with some transparency
                    .shadow(radius: 10)
            )
            .padding(40)
            .transition(.scale)
        }
    }
}


struct ContentView: View {
    @State private var isLoading = true
    var body: some View {
        Group {
            if isLoading {
                LoadingScreen()
            } else {
                MainApp()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        }
    }
}

struct MainApp: View {
    @ObservedObject var globalState = GlobalState.shared
    @State private var showSettings = false
    @State private var selectedTab: String = "Leaf"
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedDetent: PresentationDetent = .height(700)
    @StateObject private var userViewModel = UserViewModel()
    
    @State private var lastRunDate: Date = Date.distantPast
    @State private var countdown: String = "24:00" // To hold the countdown string
    @State private var timer: Timer?
    @State private var popupOpacity = 0.0
    @State private var popupScale = 0.8


    var body: some View {
        @State var counter: Int = globalState.counter
        ZStack {
            ThemeColors.Background.primary(isDarkMode)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderTitleView()
                
                ScrollView {
                    VStack(alignment: .center) {
                        if selectedTab == "Leaf" {
                            VStack {
                                ProfileInfoView(userViewModel: userViewModel)
                                    .edgesIgnoringSafeArea(.top)
                                    .padding(.top, -370)
                                    .transition(.opacity)
                                StreakBadge(isDarkMode: isDarkMode, userViewModel: userViewModel)
                                    .transition(.opacity)
                                
                                HStack {
                                    Text("Daily Quests")
                                        .font(.custom("Fredoka", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Image(systemName: "clock")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.orange)
                                    
                                    Text(countdown)
                                        .font(.custom("Fredoka",size:16))
                                        .foregroundColor(.orange)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal)
                                .padding(.top,-10)
                                
                                NewQuestView(isDarkMode: isDarkMode, userViewModel: userViewModel)
                                    .transition(.opacity)
                                    .padding(.bottom, 10)
                                
                                HStack {
                                    Text("Your Impact")
                                        .font(.custom("Fredoka", size: 24))
                                        .fontWeight(.semibold)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Menu {
                                        Button("This Month", action: {})
                                        Button("Last Month", action: {})
                                        Button("This Year", action: {})
                                    } label: {
                                        Text("This Month")
                                            .font(.custom("Fredoka",size:16))
                                            .foregroundColor(.gray)
                                            .fontWeight(.medium)
                                    }
                                }
                                .padding(.horizontal)
                                
                                ImpactView(userViewModel: userViewModel, isDarkMode: isDarkMode)
                                    .transition(.opacity)
                            }
                        } else if selectedTab == "Awards" {
                            HStack {
                                Text("Personal Records")
                                    .font(.custom("Fredoka", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                Spacer()
                                
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            RecordsView(userViewModel: userViewModel, isDarkMode: isDarkMode)
                                .transition(.opacity)
                                .padding(0)
                            HStack {
                                Text("Awards")
                                    .font(.custom("Fredoka", size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                Spacer()
                                
                            }
                            .padding(.horizontal)
                            AwardsView(userViewModel: userViewModel, isDarkMode: isDarkMode)
                                .transition(.opacity)
                                .padding(.bottom)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
                bottomNavBar
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                //userViewModel.resetAll()
                updateCountdown()
                checkAndPerformDailyTask()
                startTimer()
                startChecker()
            }
            .onDisappear {
                timer?.invalidate() // Stop the timer when the view disappears
            }
            if userViewModel.showAwardPopup {
                AwardPopupView(isPresented: $userViewModel.showAwardPopup,
                               title: "Congratulations!",
                               message: "You unlocked an award!",
                               awardNum: userViewModel.awardNum,
                               isDarkMode: isDarkMode)
                    .opacity(popupOpacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5)) {
                            popupOpacity = 1.0
                        }
                    }
                    .onDisappear {
                        // Reset values if needed
                        popupOpacity = 0.0
                        popupScale = 0.8
                    }
            }
            if globalState.processingImage {
                LoadingOverlay(isDarkMode: isDarkMode)
                    .opacity(popupOpacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5)) {
                            popupOpacity = 1.0
                        }
                    }
                    .onDisappear {
                        // Reset values if needed
                        popupOpacity = 0.0
                        popupScale = 0.8
                    }
            }
            if globalState.showErrorMessage {
                ErrorOverlay(isDarkMode: isDarkMode)
                    .opacity(popupOpacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5)) {
                            popupOpacity = 1.0
                        }
                    }
                    .onDisappear {
                        // Reset values if needed
                        popupOpacity = 0.0
                        popupScale = 0.8
                    }
            }
        }
        .confettiCannon(counter: $counter)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            updateCountdown()
        }
    }
    
    private func startChecker() {
        timer = Timer.scheduledTimer(withTimeInterval: 60*60, repeats: true) { _ in
            checkAndPerformDailyTask()
        }
    }
    private func updateCountdown() {
        let calendar = Calendar.current
        let now = Date()
        let midnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime)!
        
        let timeInterval = midnight.timeIntervalSince(now)
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        countdown = String(format: "%02d:%02d", hours, minutes) // Update countdown string
    }
    private func checkAndPerformDailyTask() {
        let userDefaults = UserDefaults.standard
        let currentDate = Date()
        
        // Retrieve last run date from UserDefaults
        if let savedDate = userDefaults.object(forKey: "lastPointsResetDate") as? Date {
            lastRunDate = savedDate
        }
        // Compare current date with last run date
        let calendar = Calendar.current
        if !calendar.isDate(lastRunDate, inSameDayAs: currentDate) {
            performDailyFunction()  // Call your function here
            userDefaults.set(currentDate, forKey: "lastPointsResetDate")  // Update last run date
        }
    }
    private func performDailyFunction() {
        // Your logic to reset points or other daily tasks
        userViewModel.resetActions()
        userViewModel.resetPoints()
    }
    
    var bottomNavBar: some View {
        HStack {
            ForEach(["Leaf", "Awards", "Settings"], id: \.self) { icon in
                ZStack {
                    if selectedTab == icon {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.green, lineWidth: 2)
                            )
                    }
                    
                    Image(systemName: getSystemImage(for: icon))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                .foregroundColor(selectedTab == icon ? Color.green : .gray)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    if icon == "Settings" {
                        showSettings.toggle()
                    } else {
                        selectedTab = icon
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .presentationDetents([.medium, .fraction(0.75), .height(700)], selection: $selectedDetent)
                }
            }
        }
        .padding(.horizontal, 64)
        .padding(.top, 12)
        .padding(.bottom, 32)
        .background(Color.gray.opacity(0.1))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.2)),
            alignment: .top
        )
    }
    
    // Helper function for system icons
    func getSystemImage(for icon: String) -> String {
        switch icon {
        case "Leaf": return "leaf.fill"
        case "Awards": return "medal.fill"
        case "Settings": return "gearshape.fill"
        default: return "leaf"
        }
    }
}

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(isDarkMode ? .blue : .yellow)
                            Text(isDarkMode ? "Dark Mode" : "Light Mode")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .preferredColorScheme(isDarkMode ? .dark : .light)
            
        }
    }
}

struct LoadingScreen: View {
    @State private var progress: CGFloat = 0
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 22/255, green: 163/255, blue: 74/255),
                    Color(red: 21/255, green: 128/255, blue: 61/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                // Logo Animation
                VStack(spacing: -10) {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimating)
                        .onAppear {
                            self.isAnimating = true
                        }
                }
                .padding(.bottom, 20)

                Text("EcoQuest")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // Eco Tip Card
                VStack {
                    Text("🌿 Did You Know?")
                        .font(.custom("Fredoka", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("Bamboo grows up to 35 inches per day, making it one of the most sustainable building materials on Earth. Using bamboo products helps reduce deforestation!")
                        .font(.custom("Fredoka", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(10)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.bottom, 20)

                // Loading Bar
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 200, height: 10)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red:134/255,green:239/255,blue:172/255))
                        .frame(width: progress * 200 / 100, height: 10)
                        .animation(.linear(duration: 0.5), value: progress)
                        .padding(.top, -18)
                }
                .padding(.bottom, 10)

                Text("Loading your eco journey...")
                    .font(.custom("Fredoka", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .onAppear {
            // Simulate loading progress
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if self.progress < 100 {
                    self.progress += 20
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}
