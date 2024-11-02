//
//  Home.swift
//  AppleMusicPlayer
//
//  Created by Riley Brookins on 10/30/24.
//

import SwiftUI

struct Home: View {
    @State private var showMiniPlayer: Bool = false
    var body: some View {
        // Dummy tab view
        TabView {
            Tab.init("Home", systemImage: "house") {
                NavigationStack {
                    List {
                        ForEach(0..<100) {_ in
                            Button("hi") {
                                showMiniPlayer.toggle()
                            }
                        }
                    }
                        .navigationTitle("Home")
                }
            }
            
            Tab.init("Search", systemImage: "magnifyingglass") {
                Text("Search")
            }
            
            Tab.init("Notifications", systemImage: "bell") {
                Text("Notifications")
            }
            
            Tab.init("Settings", systemImage: "gearshape") {
                Text("Settings")
            }
        }
        .universalOverlay(show: $showMiniPlayer) {
            ExpandableMusicPlayer()
        }
        .onAppear {
            showMiniPlayer = true
        }
    }
    
}

#Preview {
    RootView {
        Home()
    }
}
