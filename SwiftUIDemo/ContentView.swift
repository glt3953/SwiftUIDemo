//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2025/4/1.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // 日期格式化器
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(dateFormatter.string(from: item.timestamp))")
                            .font(.system(size: 30, weight: .medium))
                    } label: {
                        Text(dateFormatter.string(from: item.timestamp))
                            .font(.system(size: 20, weight: .medium))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("项目列表")
            
            // 详情视图的默认内容
            Text("选择一个项目查看详情")
                .font(.title)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func addItem() {
        withAnimation {
            _ = Item.createWith(timestamp: Date(), in: viewContext)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("保存失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("删除失败: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// UI 热加载
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController(inMemory: true).container.viewContext)
    }
}
