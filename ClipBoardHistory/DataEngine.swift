//
//  DataEngine.swift
//  ClipBoardHistory
//
//  Created by Saravanan C on 29/12/24.
//

import Cocoa
import SwiftUI

class DataEngine : ObservableObject {
    private var maxHistoryLimit: Int = 10
    
    func getMaxHistoryLimit() -> Int {
        return maxHistoryLimit
    }
    
    func setMaxHistoryLimit(limit : Int) {
        maxHistoryLimit = limit
    }
    
    @Published private var copiedTexts: [String] = []
    
    var selectedText : String? = nil
    var selectedIndex = -1
    
    func getCopiedTexts() -> [String] {
        return copiedTexts
    }
    
    func addToCopiedTexts(text : String) {
        if (copiedTexts.contains(text)) {
            return
        }
        if copiedTexts.count == maxHistoryLimit {
            copiedTexts.removeFirst()
        }
        copiedTexts.append(text)
    }
    
    func selectText(forward : Bool) {
        if (forward) {
            selectedIndex = selectedIndex + 1
        } else {
            selectedIndex = selectedIndex-1
        }
        
        if (selectedIndex < 0) {
            selectedIndex = copiedTexts.count-1
        }
        if (selectedIndex >= copiedTexts.count) {
            selectedIndex = 0
        }
        if (selectedIndex < 0 || selectedIndex >= copiedTexts.count) {
            selectedText = nil
            return
        }
        selectedText = copiedTexts[selectedIndex];
    }
    
    func resetSelected() {
        selectedIndex = -1
        selectedText = nil
    }
    
    func clearHistory() {
        copiedTexts = []
    }
    
}
