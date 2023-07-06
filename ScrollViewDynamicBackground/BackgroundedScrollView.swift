//
//  BackgroundedScrollView.swift
//  ScrollViewDynamicBackground
//
//  Created by Alexandre MONTCUIT on 05/07/2023.
//

import SwiftUI

struct BackgroundedScrollView<Content: View>: View {
    
    private let backgroundImage: Image
    private let content: Content
    
    init(backgroundImage: Image, @ViewBuilder content: @escaping () -> Content) {
        self.backgroundImage = backgroundImage
        self.content = content()
    }
    
    // height of the scrollview in the screen
    @State private var scrollViewHeight: CGFloat = 0
    
    // height of all the scrollview content, even if it is out of the screen
    @State private var scrollViewContentHeight: CGFloat = 0
    
    // maximum offet of the scrollview content
    // this is the value we get when we reach the bottom of the content
    // = scrollViewContentHeight - scrollViewHeight
    @State private var scrollViewMaxOffset: CGFloat = 0
    
    // height of the entire image, even if it exceeds the screen limits
    @State private var backgroundImageContentHeight: CGFloat = 0
    
    // maximum offet of the background image
    // we should reach this value when we reach the end of the scrollview content
    // = backgroundImageContentHeight - scrollViewHeight
    @State private var backgroundImageMaxOffset: CGFloat = 0
    
    // current offset (position) in the scroll content
    @State private var scrollViewOffset: CGFloat = 0
    
    var body: some View {
        ScrollView {
            ZStack {
                content
            }
            .background(
                // Read the scrollViewContentHeight and compute scrollViewMaxOffset
                GeometryReader { proxy in
                    
                    // Read the scrollview current offset (position)
                    // https://developer.apple.com/forums/thread/650312
                    let offset = proxy.frame(in: .named("scroll")).minY
                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                    
                    Color.clear.onAppear {
                        scrollViewContentHeight = proxy.size.height
                        print("scrollViewContentHeight : \(scrollViewContentHeight)")
                        
                        scrollViewMaxOffset = scrollViewContentHeight - scrollViewHeight
                        print("scrollViewMaxOffset : \(scrollViewMaxOffset)")
                    }
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            print(value)
            scrollViewOffset = value
        }
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    scrollViewHeight = proxy.size.height
                    print("scrollViewHeight : \(scrollViewHeight)")
                    
                    backgroundImageMaxOffset = backgroundImageContentHeight - scrollViewHeight
                    print("backgroundImageMaxOffset \(backgroundImageMaxOffset)")
                }
            }
        )
        .background {
            backgroundImage
            // resize image to fill all scrollview background
                .resizable()
                .scaledToFill()
                .frame(maxHeight: .infinity, alignment: .top)
                .offset(y: getImageOffset())
                .background(
                    // Read the backgroundImageContentHeight
                    GeometryReader { proxy in
                        Color.clear.onAppear {
                            backgroundImageContentHeight = proxy.size.height
                            print("backgroundImageContentHeight \(backgroundImageContentHeight)")
                        }
                    }
                )
        }
    }
    
    /// Compute the scroll offset to apply to the background image to match the scrollview content position.
    /// - Returns: the offset to apply the the background image
    private func getImageOffset() -> CGFloat {
        // the image is vertically centered in the background
        // so we should had the offset to start at the top
        let centerOffset = (backgroundImageContentHeight - scrollViewHeight) / 2
        
        // avoid bounce of the background image when we reach scroll limit
        if scrollViewOffset > 0 { return centerOffset }
        if scrollViewOffset < -scrollViewMaxOffset { return -backgroundImageMaxOffset + centerOffset }
        
        return (scrollViewOffset * backgroundImageMaxOffset / scrollViewMaxOffset) + centerOffset
    }
}

private struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct BackgroundedScrollView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundedScrollView(backgroundImage: Image("background")) {
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
        }
    }
}
