# FZSwiftUtils

Swift Foundation extensions and useful classes & utilities.

**For a full documentation take a look at the included documentation located at */Documentation*. Opening the file launches Xcode's documentation browser.**

## Notable Extensions & Classes

### DataSize

A data size abstraction.

```swift
var dataSize = DataSize(gigabytes: 1.5)
dataSize.megabyte // 1500 megabytes
dataSize.terabyte += 1
dataSize.string(includesUnit: true) // "1tb, 1gb, 500mb"
dataSize.string(for: .terabyte, includesUnit: false) // "1,15"
```

### TimeDuration

A duration/time interval abstraction.

```swift
var duration = TimeDuration(seconds: 1)
duration.minutes += 2
duration.string(style: .full) // "2 minutes, 1 seconds"
duration.string(for: .seconds) =  "121 seconds"

// Duration between two dates.
let dateDuration = TimeDuration(from: date1, to: date2)
```

### NSObject property observation

- Observe KVO properties of a `NSObject` using `observeChanges(for:)`:

```swift
let textField = NSTextField()

let stringObservation = textField.observeChanges(for \.stringValue) { oldStringValue, stringValue in
    /// stringValue changed
}

let fontObservation = textField.observeChanges(for \.font) { oldFont, font in
    /// font changed
}
```

- Observe multiple properties using `KeyValueObserver`:

```swift
let textFieldObserver = KeyValueObserver(textField)
textFieldObserver.add(\.stringValue) { oldStringValue, stringValue in
    /// stringValue changed
}
textFieldObserver.add(\.font) { oldFont, font in
    /// font changed
}
textFieldObserver.add(\.textColor) { oldTextColor, textColor in
    /// textColor changed
}
```

### NSObject Associated Values

Associated Values allows you to add additional properties to a `NSObject`.

```swift
// Set
view.associatedValue["backgroundColor"] = NSColor.black

// get
if let backgroundColor: NSColor = view.associatedValue["backgroundColor"] {

}

// Or easily extend objects:
extension NSView {
    var backgroundColor: NSColor? {
        get { associatedValue["backgroundColor"] }
        set { 
            associatedValue["backgroundColor"] = newValue
            …
        }
    }
}
```

### Iterate directories & files

Addition `URL` methods for iterating the content of file system directories.

 - Iterate sub directories
 
 ```swift
 for subDirectoryURL in downloadsDirectory.iterateDirectories() {
     
 }
 ```
 
 - Iterate files
 
 ```swift
 for fileURL in downloadsDirectory.iterateFiles() {
     
 }
 ```
 
 - Iterate files recursively (including the files of sub folders) and include hidden files.
 
  ```swift
 for fileURL in downloadsDirectory.iterateFiles().recursive.includingHidden {
     
 }
 ```
 
 - Iterate files by file extensions, file types or by predicate.
 
 ```swift
 // Iterate multimedia files
 for multimediaFileURL in downloadsDirectory.iterateFiles(types: [.video, .image, .gif]) {
 
 }
 
  // Iterates files with .txt extension
 for txtFileURL in downloadsDirectory.iterateFiles(extensions: ["txt"]) {

 }
 
 // Iterates video files with file names that contain "vid_"
 for fileURL in downloadsDirectory.iterate(predicate: { file in
     return file.fileType == .video && file.lastPathComponent.contains("vid_")
 }).recursive.includingHidden {
     
 }
 ```

### MeasureTime

Meassures the time executing a block.

```swift
MeasureTime.printTimeElapsed() {
/// The block to measure
}
```

### Progress extensions

- `updateEstimatedTimeRemaining()`: Updates the estimted time remaining and throughput.
- `addFileProgress(url: URL, kind: FileOperationKind = .downloading)`: Shows the file progress in Finder.

```swift
progress.addFileProgress(url: fileURL, kind: .downloading)
```

- `MutableProgress`: A progress that allows to add and remove children progresses.

#### NSObject Class Reflection

Reflects all properties, methods and ivars of a NSObject class including hidden ones.

```swift
/// All properties, methods and ivars of `NSView`:
Swift.print(NSView.classReflection())

/// All class properties of `UIView`:
Swift.print(UIView.classReflection().classProperties)
```

### OSHash

An implementation of the OpenSuptitle hash.

```swift
let hash = try? OSHash(url: fileURL)
hash?.Value /// The hash value
```

### More…

- `AsyncOperation`: An asynchronous, pausable operation.
- `PausableOperationQueue`: A pausable operation queue.
- `SynchronizedArray`/`SynchronizedDictionary`: A synchronized array/dictioanry.
- `Equatable.isEqual(_ other: any Equatable) -> Bool`: Returns a Boolean value indicating whether the value is equatable to another value.
- `Comparable.isLessThan(_ other: any Comparable) -> Bool`: Returns a Boolean value indicating whether the value is less than another value.
