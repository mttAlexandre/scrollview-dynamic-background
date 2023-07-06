//
//  ContentView.swift
//  ScrollViewDynamicBackground
//
//  Created by Alexandre MONTCUIT on 05/07/2023.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        BackgroundedScrollView {
            VStack(alignment: .leading) {
                ForEach(0...50, id:\.self) { item in
                    Text(String(item))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .padding(.vertical, 5)
                        .padding(.horizontal, 25)
                    
                    Divider()
                }
            }
            .frame(maxWidth: .infinity)
        } background: {
            VStack(spacing: 0) {
                Color.green
                    .frame(height: 200)
                    .opacity(0.3)
                Color.yellow
                    .frame(height: 200)
                    .opacity(0.3)
                Color.orange
                    .frame(height: 200)
                    .opacity(0.3)
                Color.red
                    .frame(height: 200)
                    .opacity(0.3)
                Color.purple
                    .frame(height: 200)
                    .opacity(0.3)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
