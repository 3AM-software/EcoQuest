import SwiftUI
import Foundation
import UIKit
import AVFoundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import CoreHaptics
import AVFoundation

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
    
    struct Text {
        static func primary(_ isDark: Bool) -> Color {
            isDark ? Color.white : Color(red: 51/255, green: 51/255, blue: 51/255)
        }
    }
}

class UserViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    private var uid: String? {
        return Auth.auth().currentUser?.uid
    }

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
            UserDefaults.standard.set(highStreak, forKey: "highStreak")
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
    @Published var showDevMenu: Bool = false {
        didSet {
            UserDefaults.standard.set(showDevMenu, forKey: "showDevMenu")
        }
    }
    

    init() {
        self.totalpoints = UserDefaults.standard.integer(forKey: "totalPoints")
        self.todaypoints = UserDefaults.standard.integer(forKey: "todayPoints")
        self.streak = UserDefaults.standard.integer(forKey: "streak")
        self.highStreak = UserDefaults.standard.integer(forKey: "highStreak")
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
        self.showDevMenu = UserDefaults.standard.bool(forKey: "showDevMenu")
    }
    
    func checkAndUpdateStreak() {
        print("Checking Streak")
        let calendar = Calendar.current
        if calendar.isDateInYesterday(lastActionDate) || totalpoints == 0 {
            // If the last action date was yesterday or the user has no total points, continue the streak
            incrementStreak()
            if streak > highStreak {
                setHighestStreak(streak)
                dateOfHighestStreak = Date()
            }
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
        
        updateLeaderboardInFirestore()
    }
    
    private func updateLeaderboardInFirestore() {
        guard let uid = uid else { return }
        
        let leaderboardRef = db.collection("leaderboard").document(uid)
        
        leaderboardRef.setData([
            "uid": uid,
            "displayName": Auth.auth().currentUser?.displayName ?? "Unknown",
            "dailyPoints": todaypoints,
            "allTimePoints": totalpoints
        ], merge: true) { error in
            if let error = error {
                print("Error updating leaderboard: \(error.localizedDescription)")
            } else {
                print("Leaderboard successfully updated.")
            }
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
        
        checkAndUpdateStreak()
        
        lastActionDate = Date()
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
        resetStreak()
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
        addPoints(0)
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
                    .font(.custom("Fredoka", size: 24))
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                    .fontWeight(.bold)
                
                // Message
                Text("You have unlocked the \(awards[awardNum].text) award!")
                    .font(.custom("Fredoka", size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
                
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
                        .font(.custom("Fredoka", size: 20))
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
                    .foregroundColor(ThemeColors.Text.primary(isDarkMode))
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

struct DeveloperToolbarView: View {
    @Binding var showDevMenu: Bool
    @StateObject private var authViewModel = UserAuthViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var engine: CHHapticEngine?
    
    // Animation states for buttons
    @State private var logoutScale: CGFloat = 1
    @State private var resetScale: CGFloat = 1
    @State private var closeScale: CGFloat = 1
    
    var body: some View {
        VStack(alignment: .trailing) {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    // Force Log Out Button
                    DevMenuButton(
                        title: "Force Log Out",
                        icon: "lock.open",
                        color: Color.red,
                        buttonScale: $logoutScale,
                        action: {
                            triggerHaptic(.heavy)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                logoutScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    logoutScale = 1
                                }
                                authViewModel.logOut()
                            }
                        }
                    )
                    
                    // Reset All Button
                    DevMenuButton(
                        title: "Reset All Data",
                        icon: "arrow.triangle.2.circlepath",
                        color: Color.blue,
                        buttonScale: $resetScale,
                        action: {
                            triggerHaptic(.medium)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                resetScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    resetScale = 1
                                }
                                userViewModel.resetAll()
                            }
                        }
                    )
                    
                    // Close Button
                    DevMenuButton(
                        title: "Close Menu",
                        icon: "xmark.circle",
                        color: Color.gray.opacity(0.3),
                        textColor: Color.primary,
                        buttonScale: $closeScale,
                        action: {
                            triggerHaptic(.light)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                closeScale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    closeScale = 1
                                }
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showDevMenu = false
                                }
                            }
                        }
                    )
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
                .background(
                    ZStack {
                        Color.black.opacity(0.7)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    }
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
                .padding()
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showDevMenu)
        .onAppear(perform: prepareHaptics)
    }
    
    // Setup haptic engine
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the haptic engine: \(error.localizedDescription)")
        }
    }
    
    // Different haptic feedback styles
    enum HapticStyle {
        case light, medium, heavy
    }
    
    // Function to trigger haptic feedback
    func triggerHaptic(_ style: HapticStyle) {
        // Fallback haptic for devices without CHHapticEngine
        let generator: UIImpactFeedbackGenerator
        switch style {
        case .light:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .medium:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            generator = UIImpactFeedbackGenerator(style: .heavy)
        }
        generator.impactOccurred()
        
        // Advanced haptics for supported devices
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        var events = [CHHapticEvent]()
        let intensity: Float
        let sharpness: Float
        
        switch style {
        case .light:
            intensity = 0.5
            sharpness = 0.5
        case .medium:
            intensity = 0.8
            sharpness = 0.4
        case .heavy:
            intensity = 1.0
            sharpness = 0.3
        }
        
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }
}

// Reusable button component for the dev menu
struct DevMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let textColor: Color
    let action: () -> Void
    @Binding var buttonScale: CGFloat
    
    init(title: String, icon: String, color: Color, textColor: Color = .white, buttonScale: Binding<CGFloat>, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.textColor = textColor
        self.action = action
        self._buttonScale = buttonScale
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textColor)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(textColor.opacity(0.7))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(buttonScale)
        }
        .buttonStyle(PlainButtonStyle())
    }
}



struct ContentView: View {
    @State private var isLoading = true
    @StateObject private var authViewModel = UserAuthViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var showMainApp: Bool
    
    init() {
        _showMainApp = State(initialValue: UserAuthViewModel().isLoggedIn)
    }

    var body: some View {
        Group {
            if isLoading {
                LoadingScreen()
            } else {
                if authViewModel.isLoggedIn {
                    ZStack {
                        if showMainApp {
                            MainApp()
                                .transition(.move(edge: .trailing)) // This animates the main app entering from the right
                        }
                        
                        if userViewModel.showDevMenu {
                            DeveloperToolbarView(showDevMenu: $userViewModel.showDevMenu)
                        }
                    }
                    .onAppear {
                        // Start the animation when the login view is completed and the app is logged in
                        withAnimation(.easeInOut(duration: 1)) {
                            showMainApp = true
                        }
                    }
                } else {
                    LoginView(authViewModel: authViewModel)
                        .background(Color(red: 123/255, green: 182/255, blue: 92/255))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(edges: .top)
                        .onAppear {
                            // Reset the main app view visibility when showing login
                            showMainApp = false
                        }
                }
            }
        }
        .background(Color(red: 123/255, green: 182/255, blue: 92/255))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        }
        .onTapGesture(count: 3) {
            userViewModel.showDevMenu.toggle()
        }
    }
}


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authViewModel: UserAuthViewModel
    @State private var username = ""

    var body: some View {
        ZStack {
            Color(red:123/255, green:182/255, blue:92/255)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            VStack(alignment: .center, spacing: 20) {
                Text("EcoQuest")
                    .font(.custom("Fredoka", size: 28))
                    .tracking(-0.5)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding(.top, 64)
                Spacer()
                TextField("", text: $username, prompt: Text("Username").foregroundColor(Color(red: 229/255, green: 229/255, blue: 229/255)))
                    .autocapitalization(.none)
                    .padding()
                    .frame(height: 55)
                    .foregroundColor(Color.gray)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color(red: 229/255, green: 229/255, blue: 229/255), lineWidth: 3)
                    )
                    .cornerRadius(100)
                    .padding(.horizontal)
                TextField("", text: $email, prompt: Text("Email").foregroundColor(Color(red: 229/255, green: 229/255, blue: 229/255)))
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .frame(height: 55)
                    .foregroundColor(Color.gray)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color(red: 229/255, green: 229/255, blue: 229/255), lineWidth: 3)
                    )
                    .cornerRadius(100)
                    .padding(.horizontal)
                SecureField("", text: $password, prompt: Text("Password").foregroundColor(Color(red: 229/255, green: 229/255, blue: 229/255)) )
                    .padding()
                    .frame(height: 55)
                    .background(Color.white)
                    .foregroundColor(Color.gray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color(red: 229/255, green: 229/255, blue: 229/255), lineWidth: 3)
                    )
                    .cornerRadius(100)
                    .padding(.horizontal)
                Button(action: {
                    authViewModel.logIn(email: email, password: password)
                }) {
                    Text("Log In")
                        .foregroundColor(Color(red:123/255, green:182/255, blue:92/255))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                }
                .padding(.horizontal)
                Button(action: {
                    authViewModel.signUp(email: email, password: password, displayName: username)
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .underline()
                }
                .padding(.bottom, 8)

                if let error = authViewModel.authError {
                    Text(error).foregroundColor(.red)
                }
            }
        }
        .padding()
    }
}

struct MainApp: View {
    @ObservedObject var globalState = GlobalState.shared // Keep this
    @State private var showSettings = false
    @State private var selectedTab: String = "Home"
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedDetent: PresentationDetent = .height(700)
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var authViewModel = UserAuthViewModel()
    
    @State private var lastRunDate: Date = Date.distantPast
    @State private var countdown: String = "24:00" // To hold the countdown string
    @State private var hourString: String = "24"
    @State private var timer: Timer?
    @State private var popupOpacity = 0.0
    @State private var popupScale = 0.8
    
    @State private var communityTab = "Leaderboard"


    var body: some View {
        ZStack {
            ThemeColors.Background.primary(isDarkMode)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                HeaderTitleView()
                if selectedTab == "Impact"{
                    Text("Your Impact")
                        .font(.custom("Fredoka", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.bottom, 8) // Add top padding if needed
                        .padding(.top, -4)
                        .frame(maxWidth: .infinity) // Makes the text occupy full width
                        .multilineTextAlignment(.center) // Center-align the text
                        .background(Color(red:123/255, green:182/255, blue:92/255))
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.black.opacity(0.1))
                        .padding(.top, -2)
                }
                
                VStack(alignment: .center) {
                    if selectedTab == "Impact" {
                        ScrollView {
                            ZStack (alignment: .bottom) {
                                ImpactView(userViewModel: userViewModel, isDarkMode: isDarkMode)
                                    .transition(.opacity)
                                CompactImpactBarView(
                                    userViewModel: userViewModel,
                                    isDarkMode: isDarkMode
                                )
                                .transition(.opacity) // Combines opacity and scale transitions
                                .animation(.easeInOut(duration: 0.3), value: selectedTab) // Applies smooth animation
                                .background(.clear)
                            }
                            .transition(.opacity)
                        }
                    }
                    else if selectedTab == "Home" {
                        ScrollView {
                            ZStack {
                                // Green background
                                Color(red:123/255, green:182/255, blue:92/255)

                                VStack(spacing: 0) {
                                    // Top section (green background)
                                    ProfileInfoView(userViewModel: userViewModel)
                                        .edgesIgnoringSafeArea(.top)
                                        .padding(.top, -370)
                                        .transition(.opacity)

                                    StreakBadge(isDarkMode: isDarkMode, userViewModel: userViewModel)
                                        .transition(.opacity)

                                    // Bottom section (brown background)
                                    VStack(spacing: 0) {
                                        HStack {
                                            Text("Daily Quests")
                                                .font(.custom("Fredoka", size: 24))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "clock")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(countdown)
                                                .font(.custom("Fredoka", size: 16))
                                                .foregroundColor(.white)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.vertical)

                                        NewQuestView(isDarkMode: isDarkMode, userViewModel: userViewModel)
                                            .transition(.opacity)
                                            .padding(.bottom, 10)
                                    }
                                    .background(Color(red: 227/255, green: 179/255, blue:113/255))
                                    .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                                    .transition(.opacity)
                                }
                            }

                        }
                    } else if selectedTab == "Awards" {
                        ScrollView {
                            ZStack {
                                Color(red:149/255, green:86/255, blue:14/255)
                                VStack {
                                    HStack {
                                        Text("Personal Records")
                                            .font(.custom("Fredoka", size: 24))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red:119/255, green:60/255, blue:0/255))

                                
                                    RecordsView(userViewModel: userViewModel, isDarkMode: isDarkMode)
                                        .transition(.opacity)
                                    
                                        
                                    HStack {
                                        Text("Awards")
                                            .font(.custom("Fredoka", size: 24))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Spacer()
                                        
                                    }
                                    .padding()
                                    .background(Color(red:119/255, green:60/255, blue:0/255))

                                    AwardsView(userViewModel: userViewModel, isDarkMode: isDarkMode)
                                        .transition(.opacity)
                                        .padding(.vertical)
                                }
                            }
                        }
                    } else if selectedTab == "Friends" {
                        ScrollView {
                            Community(userViewModel: userViewModel, authViewModel: authViewModel, isDarkMode: isDarkMode, communityTab: communityTab)
                                .transition(.opacity)
                                .padding(.bottom)
                        }
                    } else if selectedTab == "Profile" {
                        ScrollView {
                            
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                bottomNavBar
            }
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
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
        hourString = String(format: "%02d", hours)
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
        userViewModel.resetActions()
        userViewModel.resetPoints()
        let calendar = Calendar.current
        if !calendar.isDateInToday(userViewModel.lastActionDate) {
            // If the last action date wasn't today or yesterday, reset the streak
            userViewModel.resetStreak()
        }
    }
    
    var bottomNavBar: some View {
        HStack {
            ForEach(["Impact", "Awards", "Home", "Friends", "Settings"], id: \.self) { icon in
                ZStack {
                    if selectedTab == icon {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 52, height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white, lineWidth: 2)
                            )
                    }
                    
                    getCustomTabIcon(for: icon, isSelected: selectedTab == icon)
                }
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
                        .presentationDetents([.height(700)])
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 22)
        .padding(.bottom, 36)
        .background(getNavBarBackgroundColor(for: selectedTab))
        .overlay(
            Rectangle()
                .frame(height: 3)
                .foregroundColor(.black.opacity(0.15))
                .padding(.bottom, -2),
            alignment: .top
        )
    }

    // Function to return custom views for each tab icon
    func getCustomTabIcon(for icon: String, isSelected: Bool) -> AnyView {
        switch icon {
        case "Impact":
            return AnyView (
                ZStack {
                Circle()
                    .frame(width: 36, height:30)
                    .foregroundColor(.cyan)
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundColor(.green)
                Image(systemName: "globe.americas")
                        .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
            }
                )
        case "Awards":
            return AnyView (ZStack {
                Image(systemName: "checkmark.seal.fill")
                    .symbolRenderingMode(.palette)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Color(red: 0.72, green: 0.55, blue: 0.11), Color(red: 1.0, green: 0.8, blue: 0.267))
                    .scaledToFit()
                Image(systemName: "seal")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(.white)
                
            }
                            )
        case "Home":
            return AnyView (ZStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 32, weight: .ultraLight))
                    .foregroundColor(.red)
                Image(systemName: "house")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.white)
            })
        case "Friends":
            return AnyView(ZStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(Color(red: 206/255, green:137/255, blue:70/255))
                Image(systemName: "trophy")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            })
        case "Settings":
            return AnyView(ZStack {
                // Rotating gear effect when selected
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundColor(Color.gray)
                Image(systemName: "gearshape")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            })
        default:
            return AnyView(Image(systemName: "leaf")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(.white)
                           )
        }
    }

    // Function to return background colors for the whole navigation bar
    func getNavBarBackgroundColor(for selectedTab: String) -> Color {
        switch selectedTab {
        case "Impact":
            return Color(red:123/255, green:182/255, blue:92/255)
        case "Awards":
            return Color(red:149/255, green:86/255, blue:14/255)
        case "Home":
            return Color(red: 227/255, green: 179/255, blue:113/255)
        case "Friends":
            return Color(red:123/255, green:182/255, blue:92/255)
        default:
            return Color(red:123/255, green:182/255, blue:92/255)
        }
    }
}

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var authViewModel = UserAuthViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
         
                ThemeColors.Background.primary(isDarkMode)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Settings")
                                .font(.custom("Fredoka", size: 28))
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.Content.primary(isDarkMode))
                            Spacer()
                            Button(action: { dismiss() }) {
                                Text("Done")
                                    .font(.custom("Fredoka", size: 18))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(ThemeColors.Content.border(isDarkMode))
                    }
                    .background(ThemeColors.Background.primary(isDarkMode))
                    
                   
                    VStack(spacing: 16) {
                        
                    
                        HStack {
                            Text("Profile")
                                .font(.custom("Fredoka", size: 16))
                                .textCase(nil)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                            Spacer()
                        }
                        VStack {
                            
                            HStack {
                                Text("Display Name")
                                    .font(.custom("Fredoka", size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(authViewModel.displayName)")
                                    .font(.custom("Fredoka", size: 16))
                                    .foregroundColor(ThemeColors.Content.primary(isDarkMode))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            
                            Rectangle()
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(ThemeColors.Content.border(isDarkMode))
                            
                            HStack {
                                Text("Email")
                                    .font(.custom("Fredoka", size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(authViewModel.email ?? "Not available")
                                    .font(.custom("Fredoka", size: 16))
                                    .foregroundColor(ThemeColors.Content.primary(isDarkMode))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
                        )
                        
                        HStack {
                            Text("Appearance")
                                .font(.custom("Fredoka", size: 16))
                                .textCase(nil)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Toggle(isOn: $isDarkMode) {
                                HStack(spacing: 12) {
                                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                        .foregroundColor(isDarkMode ? .blue : .yellow)
                                        .font(.system(size: 20))
                                    
                                    Text(isDarkMode ? "Dark Mode" : "Light Mode")
                                        .font(.custom("Fredoka", size: 16))
                                }
                            }
                            .tint(Color.green)
                            .padding(.horizontal, 8)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 2)
                        )
                    }
                    .padding()
                    .background(ThemeColors.Background.primary(isDarkMode))
                    Spacer()
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationBarHidden(true)
        }
    }
}

struct LoadingScreen: View {
    @State private var progress: CGFloat = 0
    @State private var isAnimating = false
    @State private var loadingMessage = ""
    @State private var ecoTip = ""

    
    let loadingMessages = [
        "Loading your eco journey...",
        "Sprouting some green ideas...",
        "Nurturing your sustainability path...",
        "Composting unnecessary emissions...",
        "Recycling bits and bytes...",
        "Charging your solar panels...",
        "Planting seeds of change..."
    ]

    let ecoTips = [
        "Bamboo grows up to 35 inches per day, making it one of the most sustainable building materials on Earth. Using bamboo products helps reduce deforestation!",
        "Turning off lights when you leave a room can save up to 10% on your energy bill—and it's better for the planet.",
        "Recycling one aluminum can saves enough energy to power a TV for three hours!",
        "A single reusable water bottle can save an average of 167 plastic bottles per year.",
        "Composting food scraps reduces landfill waste and helps enrich the soil naturally.",
        "Unplugging electronics when not in use prevents 'phantom' energy drain.",
        "Switching to LED lightbulbs uses up to 80% less energy than traditional bulbs.",
        "Eating just one vegetarian meal a week can significantly reduce your carbon footprint."
    ]


    var body: some View {
        ZStack {
            // Background gradient
            Color(red:123/255, green:182/255, blue:92/255)
            .ignoresSafeArea()

            VStack {
                // Logo Animation
                VStack(spacing: -10) {
                    Image(systemName: "leaf.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                        .onAppear {
                            self.isAnimating = true
                        }
                }
                .padding(.bottom, 20)

                Text("EcoQuest")
                    .font(.custom("Fredoka", size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // Eco Tip Card
                VStack {
                    Text("🌿 Did You Know?")
                        .font(.custom("Fredoka", size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text(ecoTip)
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
                        .fill(Color(red: 1.0, green: 0.8, blue: 0.267))
                        .frame(width: progress * 200 / 100, height: 10)
                        .animation(.linear(duration: 0.5), value: progress)
                        .padding(.top, -18)
                }
                .padding(.bottom, 10)

                Text(loadingMessage)
                    .font(.custom("Fredoka", size: 18))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .onAppear {
            self.ecoTip = ecoTips.randomElement() ?? ""
            self.loadingMessage = loadingMessages.randomElement() ?? "Loading..."

            // Sound will also be triggered here
            playSound()
        
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

var player: AVAudioPlayer?

func playSound() {
    guard let url = Bundle.main.url(forResource: "leaf-chime", withExtension: "mp3") else { return }

    do {
        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
    } catch {
        print("Error playing sound: \(error.localizedDescription)")
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
