//
//  lifeportal_2App.swift
//  lifeportal.2
//
//  Created by pat on 19/4/2025.
//

import SwiftUI

@main
struct lifeportal_2App: App {
    @StateObject private var particleStore = ParticleStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(particleStore)
        }
    }
}
