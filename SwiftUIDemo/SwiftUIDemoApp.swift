//
//  SwiftUIDemoApp.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2025/4/1.
//

import SwiftUI
import CoreData

@main
struct SwiftUIDemoApp: App {
    // 使用持久化控制器
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
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
            
            SudokuView()
                .tabItem {
                    Label("数独", systemImage: "square.grid.3x3.fill")
                }
        }
    }
}
