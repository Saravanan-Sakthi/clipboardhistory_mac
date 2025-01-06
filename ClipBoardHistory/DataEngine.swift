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
    private var defaultDoubleCmdPressTime : Float = 0.3
    
    init() {
        maxHistoryLimit = UserDefaults.standard.integer(forKey: "maxHistoryLimit")
        let idleCmdPressTime = UserDefaults.standard.float(forKey: "idleDoubleCmdPressTime")
        defaultDoubleCmdPressTime = idleCmdPressTime <= 0 ? 0.3 : idleCmdPressTime
    }
    
func getDefaultDoubleCmdPressTime() -> Float{
        return defaultDoubleCmdPressTime
    }
    
    func getMaxHistoryLimit() -> Int {
        return maxHistoryLimit
    }
    
    func setMaxHistoryLimit(limit : Int) {
        maxHistoryLimit = limit
        UserDefaults.standard.set(maxHistoryLimit, forKey: "maxHistoryLimit")
    }
    
    @Published private var copiedTexts: [String] = []
    
    var selectedText : String? = nil
    var selectedIndex = -1
    
    func getCopiedTexts() -> [String] {
        return copiedTexts
    }
    
    func moveToTop(text : String) {
        if (copiedTexts.contains(text) && copiedTexts.last != text) {
            copiedTexts.removeAll(where: {
                textItr in
                textItr == text
            })
            copiedTexts.append(text)
        }
    }
    
    func addToCopiedTexts(text : String) {
        if (maxHistoryLimit <= 0) {
            return;
        }
        if (copiedTexts.contains(text)) {
            moveToTop(text : text)
            return
        }
        if (copiedTexts.count == maxHistoryLimit) {
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
