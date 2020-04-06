# TZIndicatorProgressView

Progress bar with indicator and labels to track down the progress.

### Installation
Use Swift Package Manager.

### Usage
 In your xib file or Storyboard, click on the UIView, go to the Identity Inspector and change the Custom Class to **TZIndicatorProgressView**.
 In your ViewController, set the config/theme of the collection view
```swift
var theme = TZIndicatorThemeConfig()
theme.lineWidth = 5
theme.indicatorRadius = 10
self.progressView.theme = theme
```
set the labels
```swift
self.progressView.labels = ["Hello", "How", "Are", "YOU"]
```

Use either of the methods to update the progress
```swift
self.progressView.move(to: 0)
// goes to next index
self.progressView.nextIndex()
```

# License
Free to use



