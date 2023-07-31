# FZSwiftUtils

Swift Foundation extensions and useful Classes & utilities.

**For a full documentation take a look at the included documentation accessible via Xcodes documentation browser.**

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
