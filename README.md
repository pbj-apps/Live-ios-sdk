# Live Player
![Live](banner.png)
![Platform: iOS 13+](https://img.shields.io/badge/platform-iOS%20-blue.svg?style=flat)
[![Language: Swift 5](https://img.shields.io/badge/language-swift%205-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Build status](https://build.appcenter.ms/v0.1/apps/3c45f38a-7b97-4647-9355-e95c6383ce05/branches/main/badge)](https://appcenter.ms)
[![GitHub tag](https://img.shields.io/github/release/pbj-apps/Live-ios-sdk.svg)]()

Stream your Live content from your iOS App.

## Introduction
The Live iOS SDK enables you to display your Live content inside your iOS App.
The live SDK package is separated in two distinct targets:  `Live` which contains all the "core" code, think of it as the data layer. The second one `LivePlayer` contains everything UI-related.

There are two ways to consume the SDK, a basic way, and an advanced one.

## 1. Importing the Live package
In Xcode, select `File` > `Swift packages` > `Add Package Dependency`  
and enter Live SDK github url below:
```swift
https://github.com/pbj-apps/Live-ios-sdk
```

## Basic Api
The basic api is a "black-box" `UIViewController` that you present to quickly add Live capabilites to your app.

## Advanced Api
The advanced api, as the name suggests is for people that want a more fine-grained integration. It enables you to query the Live backend to get
It also provides you UI components to help you build your own UI's around Livestreams.


# Basic Api

## 2. Initialize the LivePlayerSDK with your credentials on App start
A good place to do this is typically the `AppDelegate`.
```swift
import LivePlayer

// [...]

LiveSDK.initialize(apiKey: "YOUR_API_KEY")
```

## 3. (Optional) Check if there is a live episode beforehand
Typical usage is that you have a "Watch live" button that you only want to show if there is an actual episode currently live.
```swift
LiveSDK.isEpisodeLive { isLive, error in			
    // -> isLive is true if there is any episode live.
    // Show player here. (step 4)
}
```

You can also pass your `showID` as a parameter to query live episodes, but this time for a specific show.
You can find your `showId` in your web dashboard. Select the show you want and grab it's id from the browser's url.

This api exists with both **callbacks** and **Combine publishers** so your are free to choose the version that fits best with your app.

## 4. Create a Player
```swift
let livePlayerVC = LivePlayerViewController() // Optionally pass a showId.
livePlayerVC.delegate = self
```
Without a `showId` parameter, the player will display the first live show it finds.

## 5. Present it like you would any UIViewController
```swift
present(livePlayerVC, animated: true, completion: nil)
```

## Example App
Checkout the example App provided in this repository to see a typical integration.
With the test app, you can input your Organization api key and battle test your own environment.

## Got a question? Found an issue? 
Create a github issue and we'll help you from there ❤️



## Extended api.

The simplified api is great to 


# UI Components
UI components provided are 100% build with SwiftUI. For apps that haven't made the switch yet, we also provide a UIKit compatible api.

## Live Player


```swift
// SwiftUI
SDKLivePlayerView(showId: showId, didTapClose: { })

// UIKIt
let livePlayerVC = LivePlayerViewController(showId: showId)
livePlayerVC.delegate = self
present(livePlayerVC, animated: true, completion: nil)
```

Here `showId` is optional and without it, it would play the first live stream found.

## VOD Player

```swift
// SwiftUI
LiveVodPlayer(url: vodUrl, close: {})

// UIKit
let vodPlayerVC = VodPlayerViewController(url: vodUrl)
vodPlayerVC.delegate = self
present(vodPlayerVC, animated: true, completion: nil)
```



Desired
```swift
let liveApi = LiveApi(apiKey: "API KEY")
liveApi.
```