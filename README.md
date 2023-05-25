# FZSwiftUtils

Swift Foundation extensions and useful Classes & utilities.

## Notable Extensions & Classes

### ContentConfiguration
Configurate several aspects of views, windows, etc. Examples:
- VisualEffect
```
window.visualEffect = .darkAqua
```
- Shadow
```
let view = NSView()
let shadowConfiguration = ContentConfiguration.Shadow(opacity: 0.5, radius: 2.0)
            view.configurate(using: shadowConfiguration)
```
- Border
```
let borderConfiguration = ContentConfiguration.Border(color: .black, width: 1.0)
view.configurate(using: borderConfiguration)
```
- Text
```
let textField = NSTextField()
let textConfiguration = ContentConfiguration.Text(font: .ystemFont(ofSize: 12), textColor: .red, numberOfLines: 1)
textField.configurate(using: textConfiguration)
```

### DataSize
A data size abstraction 
```
let dataSize = DataSize(gigabytes: 1.5)
dataSize.countStyle = .file // Specifies display of file or storage byte counts
dataSize.megabyte // 1500 megabytes
dataSize.terabyte += 1
dataSize.string(includesUnit: true) // 1tb, 500mb
dataSize.string(for: .terabyte, includesUnit: false) // 1500
```

### TimeDuration
A duration/time interval abstraction 
```
let duration = TimeDuration(seconds: 1)
duration.minutes += 2
duration.string(style: .full) // 2 minutes, 1 seconds
duration.string(for: .seconds) =  121 seconds
```



     See ``ViewAnimator`` for a list of supported animatable properties on `UIView`.
