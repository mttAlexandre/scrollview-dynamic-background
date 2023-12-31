//
//  BackgroundedScrollView.swift
//  ScrollViewDynamicBackground
//
//  Created by Alexandre MONTCUIT on 05/07/2023.
//

import SwiftUI

struct BackgroundedScrollView<Content: View, Background: View>: View {
    
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let content: Content
    private let background: Background
    
    /// A scrollable view with a scrolling background corresponding to the scroll position in the content.
    /// - Parameters:
    ///   - axes: axes of the ScrollView
    ///   - showsIndicators: showsIndicators in the ScrollView
    ///   - content: the content of the ScrollView
    ///   - background: a view to scroll in the background of the ScrollView.
    init(axes: Axis.Set = .vertical,
         showsIndicators: Bool = true,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder background: @escaping () -> Background) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
        self.background = background()
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
    
    // id used to redraw some view when device rotation changes
    // it helps to refresh some height/offset states value which gets initiated in 'onAppear'
    // modifier. Because 'onAppear' is not recalled after orientation change.
    @State private var rotationId = UUID()
    
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            ZStack {
                content
            }
            .background(
                // Read the scrollViewContentHeight and compute scrollViewMaxOffset
                GeometryReader { proxy in
                    
                    // Read the scrollview current offset (position)
                    // https://developer.apple.com/forums/thread/650312
                    let offset = proxy.frame(in: .named("scroll")).minY
                    
                    Color.clear
                        .preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        .onAppear {
                            scrollViewContentHeight = proxy.size.height
                            scrollViewMaxOffset = scrollViewContentHeight - scrollViewHeight
                        }
                        .id(rotationId)
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .background(
            GeometryReader { proxy in
                ZStack {
                    Color.clear
                        .onAppear {
                            scrollViewHeight = proxy.size.height
                            backgroundImageMaxOffset = backgroundImageContentHeight - scrollViewHeight
                        }
                    
                    background
                        .offset(y: getImageOffset())
                        .background(
                            // Read the backgroundImageContentHeight
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        backgroundImageContentHeight = proxy.size.height
                                    }
                            }
                        )
                }
                .id(rotationId)
            }
        )
        .onRotate { _ in
            rotationId = UUID()
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { newValue in
            scrollViewOffset = newValue
        }
    }
    
    /// Compute the scroll offset to apply to the background image to match the scrollview content position.
    /// - Returns: the offset to apply the the background image
    private func getImageOffset() -> CGFloat {
        // avoid bounce of the background image when we reach scroll limit
        if scrollViewOffset > 0 { return 0 }
        if scrollViewOffset < -scrollViewMaxOffset { return -backgroundImageMaxOffset }
        
        return scrollViewOffset * backgroundImageMaxOffset / scrollViewMaxOffset
    }
}

struct BackgroundedScrollView_Previews: PreviewProvider {
    static var previews: some View {
        
        // the preview seems broken for this example
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
            Image("background")
                .resizable()
                .scaledToFill()
        }
        
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
            LinearGradient(
                gradient: Gradient(colors: [.green, .yellow, .orange, .red, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 5000)
        }
    }
}
