//
//  SwiftUIDemoApp.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2025/4/1.
//

import SwiftUI
import SwiftData

@main
struct SwiftUIDemoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// 主标签视图
struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("示例", systemImage: "list.dash")
                }
            
            TetrisView()
                .tabItem {
                    Label("俄罗斯方块", systemImage: "gamecontroller")
                }
            
            LuckyWheelView()
                .tabItem {
                    Label("转盘抽奖", systemImage: "circle.fill")
                }
        }
    }
}
