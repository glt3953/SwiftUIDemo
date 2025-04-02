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
        NavigationView {
            List {
                NavigationLink(destination: ContentView()) {
                    Label("示例", systemImage: "list.dash")
                }
                
                NavigationLink(destination: TetrisView()) {
                    Label("俄罗斯方块", systemImage: "gamecontroller")
                }
                
                NavigationLink(destination: LuckyWheelView()) {
                    Label("转盘抽奖", systemImage: "circle.fill")
                }
                
                NavigationLink(destination: SudokuView()) {
                    Label("数独", systemImage: "square.grid.3x3.fill")
                }
                
                NavigationLink(destination: GoGameView()) {
                    Label("围棋", systemImage: "circle.grid.cross")
                }
            }
            .navigationTitle("功能列表")
        }
        
        // Tab 入口示例，不能删除
//        TabView {
//            ContentView()
//                .tabItem {
//                    Label("示例", systemImage: "list.dash")
//                }
//            
//            TetrisView()
//                .tabItem {
//                    Label("俄罗斯方块", systemImage: "gamecontroller")
//                }
//            
//            LuckyWheelView()
//                .tabItem {
//                    Label("转盘抽奖", systemImage: "circle.fill")
//                }
//            
//            SudokuView()
//                .tabItem {
//                    Label("数独", systemImage: "square.grid.3x3.fill")
//                }
//        }
    }
}
