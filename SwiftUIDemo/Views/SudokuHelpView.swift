//
//  SudokuHelpView.swift
//  SwiftUIDemo
//
//  Created by 宁侠 on 2024/4/1.
//

import SwiftUI

// 数独帮助视图
struct SudokuHelpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("数独游戏规则")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                        
                        Text("数独（Sudoku）是一种逻辑性数字填充游戏。游戏目标是在9×9的网格中填入1到9的数字，使得每行、每列和每个3×3的小九宫格内都包含1到9的所有数字，且每个数字只出现一次。")
                        
                        Text("基本规则")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("1. 每一行必须包含1-9的所有数字，不能重复")
                        Text("2. 每一列必须包含1-9的所有数字，不能重复")
                        Text("3. 每个3×3小九宫格必须包含1-9的所有数字，不能重复")
                        Text("4. 游戏开始时，部分格子已填入数字（不可修改），玩家需要推理出其余格子的数字")
                    }
                    
                    Group {
                        Text("游戏操作说明")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("• 点击空白格子选择要填入数字的位置")
                        Text("• 在数字键盘中选择要填入的数字（1-9）")
                        Text("• 使用\"清除\"按钮清除已填入的数字")
                        Text("• 使用\"新游戏\"按钮开始新的游戏")
                        Text("• 使用\"提示\"按钮获取下一步可能的填充位置")
                        Text("• 使用\"验证\"按钮检查当前填写是否正确")
                    }
                    
                    Group {
                        Text("解题技巧")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("1. 排除法：通过排除已出现在同行、同列或同九宫格的数字，缩小可能的数字范围")
                        Text("2. 唯一候选数法：如果某个位置只有唯一一个可能的数字，那么这个位置必须填入该数字")
                        Text("3. 行列区块互相作用法：利用行、列和小九宫格的交叉区域进行推理")
                        Text("4. 隐性数对：当两个格子只能填入相同的两个数字时，这两个数字在该行、列或九宫格中的其他位置都不能出现")
                        
                        Text("记住：数独是一个逻辑游戏，每个有效的数独谜题都只有一个唯一解。通过仔细观察和逻辑推理，每个谜题都可以被解开！")
                            .padding(.top, 4)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .navigationTitle("数独玩法介绍")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
} 