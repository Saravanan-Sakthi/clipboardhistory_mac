//
//  OverlayView.swift
//  ClipBoardHistory
//
//  Created by Saravanan C on 29/12/24.
//

import SwiftUI

struct OverlayView: View {
    @State var selectedText:String?

    var body: some View {
        GeometryReader { geometry in
                    ZStack {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)

                        VStack {
                            Text(selectedText ?? "")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                        }
                        .frame(width: 300, height: 150) 
                        .background(Color.clear)
                        .cornerRadius(15)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
    }
}
