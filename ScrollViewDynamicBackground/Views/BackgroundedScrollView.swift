//
//  BackgroundedScrollView.swift
//  ScrollViewDynamicBackground
//
//  Created by Alexandre MONTCUIT on 05/07/2023.
//

import SwiftUI

struct BackgroundedScrollView<Content: View>: View {
    
    private let backgroundImage: Image
    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let content: Content
    
    /// A scrollable view with a scrolling background corresponding to the scroll position in the content.
    /// - Parameters:
    ///   - backgroundImage: the image to scroll in the background of the ScrollView.
    ///   - content: the content of the ScrollView
    init(backgroundImage: Image,
         axes: Axis.Set = .vertical,
         showsIndicators: Bool = true,
         @ViewBuilder content: @escaping () -> Content) {
        self.backgroundImage = backgroundImage
        self.axes = axes
        self.showsIndicators = showsIndicators
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
                    
                    backgroundImage
                    // resize image to fill all scrollview background
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: .infinity, alignment: .top)
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
