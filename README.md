# Live Player
![Live](banner.png)
![Platform: iOS 13+](https://img.shields.io/badge/platform-iOS%20-blue.svg?style=flat)
[![Language: Swift 5](https://img.shields.io/badge/language-swift%205-f48041.svg?style=flat)](https://developer.apple.com/swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Build status](https://build.appcenter.ms/v0.1/apps/3c45f38a-7b97-4647-9355-e95c6383ce05/branches/main/badge)](https://appcenter.ms)
[![GitHub tag](https://img.shields.io/github/release/pbj-apps/Live-ios-sdk.svg)]()

Stream your Live content from your iOS App.

- [Introduction](#Introduction)
    - [Installation](#Installation)
    - [Initialization](#Initialization)
- [Api](#Api)
    - [Vod](#Vod)
        - [Categories](#Categories)
        - [Playlists](#Playlists)
        - [Videos](#Videos)
        - [Search](#Search)
    - [Live](#Live) 
        - [Episodes](#Episodes) 
- [UI Components](#UI-Components)
    - [Live Player](#Live-Player)
    - [Vod Player](#Vod-Player)
- [Example App](#Example-App)


# Introduction
The Live iOS SDK enables you to display your Live content inside your iOS App.
The live SDK package is separated in two distinct targets:  `Live` which contains all the "core" code and `LiveUI` containing UI elements.

## Installation
In Xcode, select `File` > `Swift packages` > `Add Package Dependency`  
and enter Live SDK github url below:
```swift
https://github.com/pbj-apps/Live-ios-sdk
```

## Initialization
You need to initialize the `Live` SDK with your credentials on App start
A good place to do this is typically the `AppDelegate`.
```swift
import Live

// [...]
Live.shared.initialize(apiKey: "YOUR_API_KEY", environment: .dev, completion: { [weak self] in
    // SDK is initialized.
})
```
`environment` is optional and defaults to `.prod`. Once the completion handler is called, the SDK is initialized and you can start querying your Live data.

The whole `Live` api is accessed via the `Live.shared` object which exposes a classic Combine api returning `AnyPublisher<Result, Error>`

# Api

## VoD

### Categories

Fetch all VoD Categories
```swift
 Live.shared.fetchVodCategories().sink { categories in 
    // categories
 }
 .store(in: &cancellables)
```

Fetch a specific VoD Category

```swift
 Live.shared.fetch(category: category).sink { category in 
    // category
 }
 .store(in: &cancellables)
```

### Playlists
Fetch all playlists
```swift
 Live.shared.fetchVodPlaylists().sink { playlists in 
    // playlists
 }
 .store(in: &cancellables)
```
Fetch a specific playlist
```swift
 Live.shared.fetch(playlist: playlist).sink { playlist in 
    // playlist
 }
 .store(in: &cancellables)
```

### Videos

Fetch all VoD Videos
```swift
 Live.shared.fetchVodVideos().sink { videos in 
    // videos
 }
 .store(in: &cancellables)
 ```

 Fetch a specific VoD Video
 ```swift
 Live.shared.fetch(video: vodVideo).sink { video in 
    // video
 }
 .store(in: &cancellables)
 ```

### Search

Search Vod Videos only
```swift
 Live.shared.searchVodVideos(query: query).sink { videos in 
    // videos
 }
 .store(in: &cancellables)
 ```

 Search Vod Videos & Playlists
```swift
 Live.shared.searchVod(query: query).sink { vodItems in 
    // vodItems (VodVideo & VodPlaylist)
 }
 .store(in: &cancellables)
 ```

## Live

### Episodes

Fetch all episodes
```swift
 Live.shared.fetchEpisodes().sink { episodes in 
    // episodes
 }
 .store(in: &cancellables)
```

Fetch a specific episode
```swift
 Live.shared.fetch(episode: Episode).sink { episode in 
    // episode
 }
 .store(in: &cancellables)
```

# UI Components
In order to have access to UI elements, you will need to import `LiveUI`.

UI components provided are 100% build with SwiftUI. For apps that haven't made the switch yet, we also provide a UIKit compatible api.


## Live Player

SwiftUI
```swift
LivePlayer(episode: episode, close: { }, proxy: proxy)
```

UIKIt
```swift
let livePlayerVC = LivePlayerViewController(showId: showId)
livePlayerVC.delegate = self
present(livePlayerVC, animated: true, completion: nil)
```

Here `showId` is optional and without it, it would play the first live stream found.

## VOD Player

SwiftUI
```swift
VodPlayer(url: vodUrl, close: {})
```

UIKit
```swift
let vodPlayerVC = VodPlayerViewController(url: vodUrl)
vodPlayerVC.delegate = self
present(vodPlayerVC, animated: true, completion: nil)
```


## Example App
Checkout the example App provided in this repository to see a typical integration.
With the test app, you can input your Organization api key and battle test your own environment.

## Got a question? Found an issue? 
Create a github issue and we'll help you from there ❤️

