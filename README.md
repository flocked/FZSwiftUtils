# FZSwiftUtils

Swift Foundation extensions and useful classes & utilities.

**For a full documentation take a look at the included documentation accessible via Xcode's documentation browser.**

## Notable Extensions & Classes

### DataSize
A data size abstraction 
```
let dataSize = DataSize(gigabytes: 1.5)
dataSize.countStyle = .file // Specifies display of file or storage byte counts
dataSize.megabyte // 1500 megabytes
dataSize.terabyte += 1
dataSize.string(includesUnit: true) // 1tb, 1gb, 500mb
dataSize.string(for: .terabyte, includesUnit: false) // 1,15
```

### TimeDuration
A duration/time interval abstraction 
```
let duration = TimeDuration(seconds: 1)
duration.minutes += 2
duration.string(style: .full) // 2 minutes, 1 seconds
duration.string(for: .seconds) =  121 seconds
```

### KeyValueObserver
Observes multiple properties of an object.
```
let textField = NSTextField()
let observer = KeyValueObserver(textField)
observer.add(\.stringValue) { oldStringValue, stringValue in
guard oldStringValue != stringValue else { return }
/// Process stringValue
}  
```
 
### NSObject extensions
- `associatedValue`: Getting and setting associated values of an object.
```
// Set
button.associatedValue["myAssociatedValue"] = "SomeValue"

// get
if let string: String = button.associatedValue["myAssociatedValue"] {

}
```
- `observeChanges<Value>(for: for keyPath: KeyPath<Self, Value>)`: Observes changes for a property.
```
textField.observeChanges(for \.stringValue) { oldStringValue, stringValue in
guard oldStringValue != stringValue else { return }
/// Process stringValue
}  
```

### Progress extensions
- `updateEstimatedTimeRemaining()`: Updates the estimted time remaining and throughput.
- `addFileProgress(url: URL, kind: FileOperationKind = .downloading)`: Shows the file progress in Finder.
```
progress.addFileProgress(url: fileURL, kind: .downloading)
```
- `MutableProgress`: A progress that allows to add and remove children progresses.

### MeasureTime
Meassures the time executing a block.
```
let timeElapsed = MeasureTime.timeElapsed() {
/// The block to measure
}
```

### OSHash
An implementation of the OpenSuptitle hash.
```
let hash = try? OSHash(url: fileURL)
hash?.Value /// The hash value
```
 
### More…
- `AsyncOperation`: An asynchronous, pausable operation.
- `PausableOperationQueue`: A pausable operation queue.
- `SynchronizedArray`/`SynchronizedDictionary`: A synchronized array/dictioanry.
- `Equatable.isEqual(_ other: any Equatable) -> Bool`: Returns a Boolean value indicating whether the value is equatable to another value.
- `Comparable.isLessThan(_ other: any Comparable) -> Bool`: Returns a Boolean value indicating whether the value is less than another value.
