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
                    .font(.title)
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
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        // Use totalpoints to create the Level instance
        let points = userViewModel.totalpoints
        let level = Level(totalPoints: points) // Update to use the new Level initialization
        
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
                            Text("Level \(level.levelNum) \(level.levelTitle)")
                                .font(.custom("Fredoka", size: 24))
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        if level.levelNum < 10 {
                            Text("Next: \(level.pointsToNext) pts")
                                .font(.custom("Fredoka", size: 16))
                                .fontWeight(.medium)
                        } else {
                            Text("Max Level")
                                .font(.custom("Fredoka", size: 16))
                                .fontWeight(.medium)
                        }
                    }
                    withAnimation(.spring()) {
                        LevelProgressBar(progress: Double(level.progress))
                    }
                    
                    // Points Display
                    HStack {
                        HStack {
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                            VStack(alignment: .leading) {
                                Text("\(userViewModel.totalpoints)")
                                    .font(.custom("Fredoka", size: 28))
                                    .fontWeight(.bold)
                                Text("Total Points")
                                    .font(.custom("Fredoka", size: 16))
                                    .fontWeight(.medium)
                            }
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("+\(userViewModel.todaypoints)")
                                .font(.custom("Fredoka", size: 24))
                                .fontWeight(.bold)
                            Text("Today's Points")
                                .font(.custom("Fredoka", size: 16))
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(16)
            }
            .padding(.top, 340)
            .padding([.leading, .trailing])
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
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.orange)
            Text("\(userViewModel.streak) Day Streak!")
                .font(.custom("Fredoka", size: 18))
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
