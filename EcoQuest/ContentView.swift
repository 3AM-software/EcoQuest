import SwiftUI
import Foundation
import UIKit
import AVFoundation

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


struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                LoadingScreen() // Your loading screen view
            } else {
                MainApp() // Your main app view
            }
        }
        .onAppear {
            // Simulate loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        }
    }
}

struct MainApp: View {
    @State private var showSettings = false
    @State private var selectedTab: String = "Leaf"
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var selectedDetent: PresentationDetent = .height(700)
    
    var body: some View {
        ZStack {
            ThemeColors.Background.primary(isDarkMode)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderTitleView()
                
                ScrollView {
                    VStack(alignment: .center) {
                        if selectedTab == "Leaf" {
                            VStack {
                                ProfileInfoView()
                                    .edgesIgnoringSafeArea(.top)
                                    .padding(.top, -370)
                                    .transition(.opacity)
                                StreakBadge(isDarkMode: isDarkMode)
                                    .transition(.opacity)
                                
                                HStack {
                                    Text("Daily Quests")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Image(systemName: "clock")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.orange)
                                        
                                    Text("24 hours")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal)
                                .padding(.top,-10)
                                
                                NewQuestView(isDarkMode: isDarkMode)
                                    .transition(.opacity)
                                    .padding(.bottom, 10)
                                
                                HStack {
                                    Text("Your Impact")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(isDarkMode ? .white : .black)
                                    Spacer()
                                    Menu {
                                        Button("This Month", action: {})
                                        Button("Last Month", action: {})
                                        Button("This Year", action: {})
                                    } label: {
                                        Text("This Month")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .fontWeight(.medium)
                                    }
                                }
                                .padding(.horizontal)
                                
                                ImpactView(isDarkMode: isDarkMode)
                                    .transition(.opacity)
                                    
                            }
                        } else if selectedTab == "Awards" {
                            HStack {
                                Text("Completed Quests")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                Spacer()
                                Text("2 Completed Quests")
                                    .foregroundColor(.green)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                            AwardsView()
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
                
                bottomNavBar
            }
            .edgesIgnoringSafeArea(.all)
        }
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

struct UserOverview: View {
    var totalPoints: Int = 1200 // Example value
    var streak: Int = 5 // Example value
    let isDarkMode: Bool
    
    init(isDarkMode: Bool){
        self.isDarkMode = isDarkMode
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                        .stroke(Color(red:229/255, green:229/255, blue:229/255), lineWidth:2))
                Spacer()
            }
        }
        .padding()
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct UserProfile: View {
    @State private var showSettings = false
    let isDarkMode: Bool
    
    init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }
    
    var body: some View {
        VStack(alignment: .leading){
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Arco23")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkMode ? .white : .black)
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
            .background(ThemeColors.Card.background(isDarkMode))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 1)
            )
            .padding(.horizontal)
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
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Bamboo grows up to 35 inches per day, making it one of the most sustainable building materials on Earth. Using bamboo products helps reduce deforestation!")
                        .font(.subheadline)
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
                    .font(.subheadline)
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

#Preview {
    ContentView()
}
