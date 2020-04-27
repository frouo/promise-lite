# PromiseLite

[![CI Status](https://travis-ci.com/frouo/promise-lite.svg?branch=master)](https://travis-ci.com/github/frouo/promise-lite)
[![Version](https://img.shields.io/cocoapods/v/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)
[![License](https://img.shields.io/cocoapods/l/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)
[![Platform](https://img.shields.io/cocoapods/p/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)

Lets chain asynchronous functions.

## Installation

PromiseLite is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'PromiseLite'
```

## Usage

```swift
fetchPodName()
  .then { createMyTwitterMessage(podName: $0) }
  .then { postOnTwitter(message: $0) }
  .then { success in print("👍") }
 
// MARK: Promises

func fetchPodName() -> PromiseLite<String> {
  PromiseLite<String> { resolve in
    async(after: 0.1) {
      resolve("PromiseLite") // 💎 retrieved pod name "PromiseLite" (async)
    }
  }
}

func createMyTwitterMessage(podName: String) -> String {
  "\(podName) is out 🎉." // 📝 my twitter message (sync)
}

func postOnTwitter(message: String) -> PromiseLite<Bool> {
  PromiseLite<Bool> { resolve in
    async(after: 0.1) {
      resolve(true) // 🐦 message posted on twitter (async)
    }
  }
}
```

## Author

François Rouault, francois.rouault@cocoricostudio.com

Feel free to submit merge request.

## License

PromiseLite is available under the MIT license. See the LICENSE file for more info.
