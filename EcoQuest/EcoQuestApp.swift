//
//  EcoQuestApp.swift
//  EcoQuest
//
//  Created by Brayden Watt on 10/21/24.
//

import SwiftUI
import Combine
import Foundation

struct Level: Identifiable, Codable {
    let id = UUID()
    let title: String
    let num: Int
    let progressToNext: Float
    let pointsToNext: Int
    
    static let levelTitles = [
        1: "Novice",
        2: "Adept",
        3: "Fighter",
        4: "Champion",
        5: "Defender",
        6: "Guardian",
        7: "Warrior",
        8: "Hero",
        9: "Sage",
        10: "Legend"        
    ]
    
    static let pointsPerLevel = [
        1: 100,    // 0-100 points
        2: 250,    // 101-350 points
        3: 500,    // 351-850 points
        4: 750,    // 851-1600 points
        5: 1000,   // 1601-2600 points
        6: 1500,   // 2601-4100 points
        7: 2000,   // 4101-6100 points
        8: 2500,   // 6101-8600 points
        9: 3000,   // 8601-11600 points
        10: 4000   // 11601+ points
    ]
    
    static func calculateLevel(from totalPoints: Int) -> Level {
        var currentLevel = 1
        var pointsRequired = 0
        
        // Find current level
        for level in 1...10 {
            let nextLevelPoints = (1...level).reduce(0) { $0 + (pointsPerLevel[$1] ?? 0) }
            if totalPoints < nextLevelPoints {
                currentLevel = level
                pointsRequired = nextLevelPoints
                break
            }
            if level == 10 && totalPoints >= nextLevelPoints {
                currentLevel = 10
                pointsRequired = nextLevelPoints
            }
        }
        
        // Calculate progress to next level
        let previousLevelPoints = (1..<currentLevel).reduce(0) { $0 + (pointsPerLevel[$1] ?? 0) }
        let currentLevelTotalPoints = pointsRequired
        let progressPoints = Float(totalPoints - previousLevelPoints)
        let pointsForCurrentLevel = Float(currentLevelTotalPoints - previousLevelPoints)
        let progress = min(progressPoints / pointsForCurrentLevel, 1.0)
        
        // Calculate points needed for next level
        let pointsToNext = currentLevel < 10 ?
            pointsRequired - totalPoints :
            0  // At max level
        
        return Level(
            title: levelTitles[currentLevel] ?? "Unknown",
            num: currentLevel,
            progressToNext: progress,
            pointsToNext: pointsToNext
        )
    }
    
    static func defaultLevel() -> Level {
        Level(title: "Seedling", num: 1, progressToNext: 0.0, pointsToNext: 100)
    }
}

struct EnvironmentalMetrics: Codable {
    var co2Saved: Double // in kilograms
    var energySaved: Double // in kilowatt-hours
    var waterSaved: Double // in liters
    var wastePrevented: Double // in kilograms
    
    static let defaultValues = EnvironmentalMetrics(
        co2Saved: 0.0,
        energySaved: 0.0,
        waterSaved: 0.0,
        wastePrevented: 0.0
    )
}

@main
struct EcoQuestApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
