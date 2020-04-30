# PromiseLite

[![CI Status](https://travis-ci.com/frouo/promise-lite.svg?branch=master)](https://travis-ci.com/github/frouo/promise-lite)
[![codecov](https://codecov.io/gh/frouo/promise-lite/branch/master/graph/badge.svg)](https://codecov.io/gh/frouo/promise-lite)
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

### Chain promises

```swift
fetchPodName()
  .map     { editTwitterMessage(podName: $0) }
  .flatMap { postOnTwitter(message: $0) }
  .map     { success in print("👍") }
```

### Catch errors

```swift
fetchPodName()
  .map     { editTwitterMessage(podName: $0) }
  .flatMap { postOnTwitter(message: $0) }
  .map    ({ _ in "👍" }, rejection: { _ in "👎" })
  .map     { postSentStatus in print(postSentStatus) }
```

**Note:** error does propagate until it is catched in a `rejection` handler. Then the chain is restored and continues. In the above example, if `fetchPodName` calls __reject__, both `editTwitterMessage` and `postOnTwitter` __will not__ be called but `rejection: { _ in "👎" }` __will__, the chain is now restored, the next `map` completion is called and so on. 

### Create promises

```swift
func fetchPodName() -> PromiseLite<String> {
  PromiseLite<String> { resolve, reject in
    async(after: 0.1) {
      resolve("PromiseLite") // 💎 async retrieving pod name "PromiseLite" is a success, call `resolve`
      // if anything goes wrong, call `reject`
    }
  }
}

func postOnTwitter(message: String) -> PromiseLite<Bool> {
  PromiseLite<Bool> { resolve, reject in
    async(after: 0.1) {
      resolve(true) // 🐦 async posting message on twitter is a success, call `resolve`
      // if anything goes wrong, call `reject`
    }
  }
}

// Note that synchronous function can be chained to promise using `map`.

func editTwitterMessage(podName: String) -> String {
  "Lets chain async functions with \(podName)!" // 📝 returns the twitter message (sync)
}
```

## Authors

- François Rouault

Feel free to submit merge request.

## License

PromiseLite is available under the MIT license. See the LICENSE file for more info.
