//
//  ClipBoardHistoryApp.swift
//  ClipBoardHistory
//
//  Created by Saravanan C on 29/12/24.
//

import SwiftUI

@main
struct ClipBoardHistoryApp: App {
    @StateObject var dataEngine:DataEngine = DataEngine()
    var body: some Scene {
        WindowGroup {
            let clipBoardManager:ClipBoardManager = ClipBoardManager()
            
            ContentView()
                .environmentObject(dataEngine)
                .onAppear(){
                    clipBoardManager.setDataEngine(dataEngine: dataEngine)
                    ClipBoardManager.setClipBoardManager(clipBoardManager: clipBoardManager)
                    clipBoardManager.registerGlobalShortcutListener()
                }
                .onDisappear {
                    clipBoardManager.removeEventListener()
                }
        }
    }
}
