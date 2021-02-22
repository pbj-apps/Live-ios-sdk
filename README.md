# Live Player
![Live](banner.png)
![Platform: iOS 13+](https://img.shields.io/badge/platform-iOS%20-blue.svg?style=flat)
[![Language: Swift 5](https://img.shields.io/badge/language-swift%205-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Build status](https://build.appcenter.ms/v0.1/apps/3c45f38a-7b97-4647-9355-e95c6383ce05/branches/main/badge)](https://appcenter.ms)
[![GitHub tag](https://img.shields.io/github/release/pbj-apps/Live-ios-sdk.svg)]()

Stream your PBJ.live content from your iOS App.

# Installation

## 1. Import the Live-ios-sdk package
`Xcode` > `File` > `Swift packages` > `Add Package Dependency`  
```swift
https://github.com/pbj-apps/Live-ios-sdk
```

## 2. Initialize the LivePlayerSDK with your credentials on App start
A good place to do this is typically the `AppDelegate`.
```swift
import Live

// [...]

LiveSDK.initialize(apiKey: "YOUR_API_KEY")
```

## 3. Create a LivePlayerViewController
```swift
let livePlayerVC = LivePlayerViewController() // Optionally pass a showId.
livePlayerVC.delegate = self
```

## 4. Present it like you would any `UIViewController
```swift
present(livePlayerVC, animated: true, completion: nil)
```


## Example App
Checkout the example App provided in this repository to see a typical integration.

## Got a question? Found an issue? 
Create a github issue and we'll help you from there ❤️
