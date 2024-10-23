//
//  EcoQuestApp.swift
//  EcoQuest
//
//  Created by Brayden Watt on 10/21/24.
//

import SwiftUI

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
