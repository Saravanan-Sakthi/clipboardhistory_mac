//
//  ClipBoardManager.swift
//  ClipBoardHistory
//
//  Created by Saravanan C on 29/12/24.
//

import Cocoa
import AppKit
import SwiftUI

@objc class ClipBoardManager:NSObject {
    
    public var dataEngine : DataEngine?
    @objc public static var clipBoardManager : ClipBoardManager?
    
    func setDataEngine(dataEngine : DataEngine) {
        self.dataEngine = dataEngine
    }
    
    static func setClipBoardManager(clipBoardManager : ClipBoardManager) {
        ClipBoardManager.clipBoardManager = clipBoardManager
    }
    
    private var keyDownEventMonitor: Any?
    
    private var eventTap: CFMachPort?
    
    private var overlayWindow: NSWindow?
    
    public var searchStarted : Bool = false
    
    func registerGlobalShortcutListener() {
        print("Initializing global key down listener")
        
        keyDownEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handleKeyDown(event: ))
        startListening()
        
        print("listener initialized")
    }
    
    func startListening() {
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: eventTapCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        
        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }
    
    func removeEventListener() {
        if let keyDownEventMonitor = keyDownEventMonitor {
            NSEvent.removeMonitor(keyDownEventMonitor)
            print("Global keydown monitor removed.")
        }
    }
    
    private func handleKeyDown(event : NSEvent) {
        if event.modifierFlags.contains(.command) && (event.keyCode == 8 || event.keyCode == 7) { // 8 = C , 7 = x
            getCopiedText()
            return
        }
    }
    
    private func getCopiedText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 200ms delay
                let pasteboard = NSPasteboard.general
                if let copiedText = pasteboard.string(forType: .string) {
                    self.dataEngine?.addToCopiedTexts(text: String(copiedText))
                }
            }
    }
    
    public func pasteText() {
        hideOverlay()
        searchStarted = false
        if (self.dataEngine?.selectedText != nil) {
            pasteContentToCursor(content: self.dataEngine?.selectedText ?? "")
            self.dataEngine?.resetSelected()
        }
    }
    
    public func clearPasteBoardContents() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
    }
    
    public func pasteContentToClipBoard(content: String) {
        clearPasteBoardContents()
        let pasteboard = NSPasteboard.general
        pasteboard.setString(content, forType: .string)
    }
    
    public func pasteContentToCursor(content: String) {
        
        pasteContentToClipBoard(content: content)
        
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) // Virtual key for 'V'
        let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        
        keyDownEvent?.flags = .maskCommand // Add Command key to the event
        keyDownEvent?.post(tap: .cgAnnotatedSessionEventTap)
        keyUpEvent?.post(tap: .cgAnnotatedSessionEventTap)
    }
    
    public func showOverlay(selectedText: String) {
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


let eventTapCallback: CGEventTapCallBack = { proxy, type, event, refcon in
    let clipBoardManager : ClipBoardManager = ClipBoardManager.clipBoardManager!
    if type == .keyDown {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        
        if event.flags.contains(.maskControl){
            
            var forwardSearch : Bool = false
            var search : Bool = false
            if (keyCode == 9) { // 9 = v
                clipBoardManager.searchStarted = true
                search = true
            }
            if event.flags.contains(.maskShift) {
                search = true
                forwardSearch = true
            }
            if clipBoardManager.searchStarted  && search {
                clipBoardManager.dataEngine?.selectText(forward: forwardSearch)
                clipBoardManager.showOverlay(selectedText : ClipBoardManager.clipBoardManager?.dataEngine?.selectedText ?? "")
                clipBoardManager.clearPasteBoardContents()
                return nil
            }
        }
        
    }
    if (type == .flagsChanged) {
        if (clipBoardManager.searchStarted && !event.flags.contains(.maskControl)){
            clipBoardManager.pasteText()
        }
    }
    return Unmanaged.passUnretained(event)
}
