import SwiftUI
import UIKit

struct HeaderTitleView: View {
    @State private var showSettings = false
    
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
                Image(systemName: "shield")
                    .font(.system(size: 28, weight: .bold))
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
            .frame(height: 550)
            
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
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
                        HStack{
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width:24,height:24)
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("2,450")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Total Points")
                                    .font(.subheadline)
                            }
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
            .padding(.top, 340)
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

struct StreakBadge: View {
    let isDarkMode: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Text("🔥")
            Text("15 Day Streak!")
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.Content.primary(isDarkMode))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(ThemeColors.Card.background(isDarkMode))
        .cornerRadius(20)
        .shadow(color: isDarkMode ? .clear : .black.opacity(0.1), radius: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ThemeColors.Content.border(isDarkMode), lineWidth: 1)
        )
        .offset(y: -20)
    }
}
