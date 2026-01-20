//
//  Array+EAT.swift
//  StudyDemos
//
//  Created by 怦然心动-LM on 2022/8/25.
//

import Foundation

// MARK: - Safe Index
extension Array {

    public subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
