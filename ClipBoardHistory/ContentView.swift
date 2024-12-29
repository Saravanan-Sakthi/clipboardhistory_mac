//
//  ContentView.swift
//  ClipBoardHistory
//
//  Created by Saravanan C on 29/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var dataEngine : DataEngine
    
    var body: some View {
        VStack {
            Text("Clip Board History")
            Text("Clip board history app will preserve the history of your clipboard")
                .padding()
            Text("press Cmd + C to copy to the clipboard (other modes of copy do not work)")
            Text("press V while holding Cmd + Opt to display the history")
            Text("release Cmd and Opt to paste the text").padding()
            Button("Clear History"){
                dataEngine.clearHistory()
            }
            List(dataEngine.getCopiedTexts(), id: \.self) {
                item in
                Text(item)
            }
        }
    }
}
