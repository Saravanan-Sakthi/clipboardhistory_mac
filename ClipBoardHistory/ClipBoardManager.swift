//
//  ClipBoardManager.swift
//  ClipBoardHistory
//
//  Created by Saravanan C on 29/12/24.
//

import Cocoa
import AppKit
import SwiftUI

class ClipBoardManager:ObservableObject {
    
    private var dataEngine : DataEngine?
    
    func setDataEngine(dataEngine : DataEngine) {
        self.dataEngine = dataEngine
    }
    
    private var keyDownEventMonitor: Any?
    private var flagChangeEventMonitor: Any?
    
    private var overlayWindow: NSWindow?
    
    private var searchStarted : Bool = false
    
    func registerGlobalShortcutListener() {
        print("Initializing global key down listener")
        
        keyDownEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handleKeyDown(event: ))
        
        
        print("listener initialized")
    }
    
    func removeEventListener() {
        if let keyDownEventMonitor = keyDownEventMonitor {
            NSEvent.removeMonitor(keyDownEventMonitor)
            print("Global keydown monitor removed.")
        }
    }
    
    private func handleFlagsChange(event : NSEvent) {
        if event.modifierFlags.contains(.command) && event.modifierFlags.contains(.option) {
            return
        }
        pasteText()
    }
    
    private func handleKeyDown(event : NSEvent) {
        if event.modifierFlags.contains(.command) && event.keyCode == 8 { // 8 = C
            getCopiedText()
        }
        if event.modifierFlags.contains(.command) && event.modifierFlags.contains(.option){
            var forwardSearch : Bool = false
            var search : Bool = false
            if (event.keyCode == 9) { // 9 = v
                searchStarted = true
                search = true
                if ((flagChangeEventMonitor == nil)) {
                    flagChangeEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged, handler: handleFlagsChange(event:))
                }
            }
            if (event.keyCode == 124) {
                search = true
                forwardSearch = true
            }
            if (event.keyCode == 123) {
                search = true
            }
            if searchStarted && search {
                self.dataEngine?.selectText(forward: forwardSearch)
                showOverlay(selectedText : self.dataEngine?.selectedText ?? "")
            }
        }
    }
    
    private func getCopiedText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 100ms delay
                let pasteboard = NSPasteboard.general
                if let copiedText = pasteboard.string(forType: .string) {
                    self.dataEngine?.addToCopiedTexts(text: String(copiedText))
                }
            }
    }
    
    private func pasteText() {
        print("pasteText called")
        hideOverlay()
        searchStarted = false
        if (self.dataEngine?.selectedText != nil) {
            pasteContentToCursor(content: self.dataEngine?.selectedText ?? "")
            self.dataEngine?.resetSelected()
        }
        if let eventMonitor = flagChangeEventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        flagChangeEventMonitor = nil
    }
    
    private func pasteContentToCursor(content: String) {
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        
        
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) // Virtual key for 'V'
        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        
        keyDownEvent?.flags = .maskCommand // Add Command key to the event
        keyDownEvent?.post(tap: .cgAnnotatedSessionEventTap)
        keyUpEvent?.post(tap: .cgAnnotatedSessionEventTap)
    }
    
    private func showOverlay(selectedText: String) {
        let overlayView = OverlayView(selectedText: selectedText)
        if (overlayWindow != nil) {
            overlayWindow?.contentView = NSHostingView(rootView: overlayView)
        } else {
            // Create an NSWindow
            let window = NSWindow(
                contentRect: NSScreen.main?.frame ?? NSRect.zero,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            window.isOpaque = false
            window.backgroundColor = .clear
            window.level = .floating
            window.isMovableByWindowBackground = false
            window.makeKeyAndOrderFront(nil)
            window.contentView = NSHostingView(rootView: overlayView)

            overlayWindow = window
        }
        }
    
    private func hideOverlay() {
        overlayWindow?.orderOut(nil)
            overlayWindow = nil
        }
    
}
