#  README

I have create a component to give a scrolling backgound to a SwiftUI ScrollView.

The background will scroll proportionaly to the ScrollView content position, so it does not require to have the same height.

Feel free to try it by modifying the ScrollView content and background view.

## Usage

```swift
BackgroundedScrollView() {
  // ScrollView content
} background: {
  // background view
}
```
It is also possible to modify parameters of the ScrollView.

```swift
BackgroundedScrollView(axes: .horizontal, showsIndicators: false) {
  // ScrollView content
} background: {
  // background view
}
```

## Examples

Few examples are available in **BackgroundedScrollView.swift** previews.


### Image as background

```swift
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
```

![Simulator Screen Recording - iPhone 14 Pro - 2023-07-06 at 14 38 55](https://github.com/mttAlexandre/scrollview-dynamic-background/assets/44088470/dca3a160-c731-41eb-a74d-30a237ef27e1)

### Custom View as background

```swift
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
```

![Simulator Screen Recording - iPhone 14 Pro - 2023-07-06 at 14 34 58](https://github.com/mttAlexandre/scrollview-dynamic-background/assets/44088470/0d7b5b00-bb92-432d-acea-2565ed6f1d51)


# Ressources

- [PreferenceKey explained](https://www.youtube.com/watch?v=GhIP98ht7Bk)
- [How to detect device rotation](https://www.hackingwithswift.com/quick-start/swiftui/how-to-detect-device-rotation)

