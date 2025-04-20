//
//  EcoQuestApp.swift
//  EcoQuest
//
//  Created by Brayden Watt on 10/21/24.
//

import SwiftUI
import Combine
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct Level: Identifiable, Codable {
    static let levelTitles: [Int: String] = [
            1: "Novice",
            2: "Adept",
            3: "Fighter",
            4: "Defender",
            5: "Guardian",
            6: "Warrior",
            7: "Hero",
            8: "Sage",
            9: "Legend",
            10: "Champion"
        ]
        
        static let pointsPerLevel: [Int: Int] = [
            1: 100,   // 0-100 points
            2: 250,   // 101-350 points
            3: 500,   // 351-850 points
            4: 750,   // 851-1600 points
            5: 1000,  // 1601-2600 points
            6: 1500,  // 2601-4100 points
            7: 2000,  // 4101-6100 points
            8: 2500,  // 6101-8600 points
            9: 3000,  // 8601-11600 points
            10: 4000  // 11601+ points
        ]
    
    let id = UUID()
    let totalPoints: Int
    
    var levelNum: Int {
        var accumulatedPoints = 0
        
        for i in 1...10 {
            accumulatedPoints += Level.pointsPerLevel[i] ?? 0
            if totalPoints < accumulatedPoints {
                return i
            }
        }
        return 10 // Max level
    }
    
    var levelTitle: String {
        Level.levelTitles[levelNum] ?? "Unknown"
    }
    
    var pointsToNext: Int {
        guard levelNum < 10 else { return 0 } // At max level
        
        var pointsNeededForNextLevel = 0
        for i in 1...levelNum {
            pointsNeededForNextLevel += Level.pointsPerLevel[i] ?? 0
        }
        
        return max(0, pointsNeededForNextLevel - totalPoints)
    }
    
    var progress: Float {
        // Check if at max level
        guard levelNum < 10 else { return 1.0 }

        // Calculate the progress percentage
        let progressPercentage = Float(totalPoints) / Float(totalPoints + pointsToNext)
        
        // Ensure the value doesn't exceed 1.0 (100%)
        return min(max(progressPercentage, 0.0), 1.0)
    }

}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
    return true
  }
}

@main
struct EcoQuestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
   
    
    var body: some Scene {
        WindowGroup {
            
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
