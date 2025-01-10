//
//  ContentView.swift
//  ClipBoardHistory
//
//  Created by Saravanan C on 29/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var dataEngine : DataEngine
    
    @State private var showChangeSizeDialogBox: Bool = false
    @State private var currentSize: Int = -1
    @State private var newSize: Int = -1
    @State private var unmask : Bool = false
    @State private var maskingSwitch : Bool = TextMasker.getIsMaskEnabled()
    
    var body: some View {
        VStack {
            
            Text("press Cmd + (C/X) to copy/cut content to the clipboard (other modes of copy do not work)")
                .font(.caption)
                .multilineTextAlignment(.leading)
            Text("double press and hold Cmd + V to display the history, use V (or) Shift + V to switch content")
                .font(.caption)
                .multilineTextAlignment(.leading)
            Text("release Cmd to paste the content to the cursor")
                .font(.caption)
                .multilineTextAlignment(.leading)
            
            Text("History")
                .bold().font(.headline)
                .padding()
        
            
            List(dataEngine.getCopiedTexts().reversed() , id: \.self) { item in
            
                HStack{
                    @State var textToShow = unmask ? item : TextMasker.getMaskedText(input: item)
                    Text(textToShow).font(.system(size: 18))
                    Button("copy"){
                        ClipBoardManager.clipBoardManager?.pasteContentToClipBoard(content: item)
                        dataEngine.moveToTop(text: item)
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            }
            
            
            
            HStack {
                
                Button("Clear History"){
                    dataEngine.clearHistory()
                }
                .buttonStyle(.borderedProminent)
                
                if (TextMasker.getIsMaskEnabled()) {
                    Button(unmask ? "Mask" : "UnMask") {
                        unmask = !unmask
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button(maskingSwitch ? "Disable Masking" : "Enable Masking") {
                    TextMasker.setIsMaskEnabled(maskEnabled: !maskingSwitch)
                    maskingSwitch = TextMasker.getIsMaskEnabled()
                }
                .buttonStyle(.borderedProminent)
            }
            
            HStack {
                Text("Size of history : \(currentSize)").onAppear{
                    currentSize = dataEngine.getMaxHistoryLimit()
                    newSize = currentSize
                }.padding()
                Button("Change size") {
                    showChangeSizeDialogBox = true
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $showChangeSizeDialogBox) {
                ChangeSizeDialog(newSize: $newSize, onDone: {
                    updateMaxSize()
                    showChangeSizeDialogBox = false
                })
            }
        }
    }
    private func updateMaxSize() {
        if (newSize >= 0) {
            dataEngine.setMaxHistoryLimit(limit: newSize)
            currentSize = newSize
        }
    }
}

struct ChangeSizeDialog: View {
    @Binding var newSize: Int
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter New Value")
                .font(.title2)
                .bold()
            TextField("Enter new size of History", value: $newSize, formatter: NumberFormatter())
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Done") {
                onDone() // Save changes and close
            }
            .foregroundColor(.blue)
            .padding()
        }
        .padding()
    }
}

