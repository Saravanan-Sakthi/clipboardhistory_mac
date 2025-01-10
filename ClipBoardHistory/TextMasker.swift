//
//  TextMasker.swift
//  ClipBoardHistory
//
//  Created by Saravanan C on 06/01/25.
//


import Cocoa
class TextMasker {
    
    private static var maskEnabled : Bool = UserDefaults.standard.bool(forKey: "maskEnabled")
    
    public static func setIsMaskEnabled(maskEnabled : Bool) {
        TextMasker.maskEnabled = maskEnabled
        UserDefaults.standard.setValue(maskEnabled, forKey: "maskEnabled")
    }
    
    public static func getIsMaskEnabled() -> Bool {
        return maskEnabled
    }
    
    public static func getMaskedText(input : String) -> String {
        
        if (!maskEnabled) {
            return input
        }
        
        let maskPercentage: Double = 0.6
        let maskCharacter: Character = "*"
        
        guard !input.isEmpty else { return input }
            
            let length = input.count
            let maskCount = Int(Double(length) * maskPercentage)
            let unmaskedCount = length - maskCount
            
            // Ensure at least 1 character is left unmasked on both ends, if possible
            let unmaskedStart = max(1, unmaskedCount / 2)
            let unmaskedEnd = max(1, unmaskedCount - unmaskedStart)
            
            let startIndex = input.startIndex
            let endIndex = input.index(input.startIndex, offsetBy: unmaskedStart)
            let maskedStart = input.index(input.endIndex, offsetBy: -unmaskedEnd)
            
            let visibleStart = input[startIndex..<endIndex]
            let visibleEnd = input[maskedStart..<input.endIndex]
            
            let mask = String(repeating: maskCharacter, count: maskCount)
            
            return visibleStart + mask + visibleEnd
    }
    
}
