# PromiseLite

[![CI Status](https://travis-ci.com/frouo/promise-lite.svg?branch=master)](https://travis-ci.com/github/frouo/promise-lite)
[![codecov](https://codecov.io/gh/frouo/promise-lite/branch/master/graph/badge.svg)](https://codecov.io/gh/frouo/promise-lite)
[![Version](https://img.shields.io/cocoapods/v/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)
[![License](https://img.shields.io/cocoapods/l/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)
[![Platform](https://img.shields.io/cocoapods/p/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)

Lets chain asynchronous functions.

`PromiseLite` is an implementation of [Javascript Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) in Swift. 

It is pure Swift, 100% tested, and very lightweight, ~100 lines of code 🌱

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
  .map     { isSuccess in isSuccess ? "👍" : "👎" }
  .map     { thumbs in label.text = thumbs }
  .finally { isLoading = false }
```

### Throw error

All chaining functions support error throwing.

```swift
fetchPodName()
  .map { editTwitterMessage(podName: $0) }
  .map { /* ... */ throw AppError.somethingWentWrong }
  .map { /* not reached */ }
  .map { /* not reached */ }
  ...
```

### Catch error

Use `catch` to deal with rejected cases. Once dealt with, the chaining continues.

```swift
fetchPodName()
  .map   { editTwitterMessage(podName: $0) }
  .map   { /* ... */ throw AppError.somethingWentWrong }
  .map   { /* not reached */ }
  .map   { /* not reached */ }
  .map   { /* not reached */ }
  .catch { err in "👎" /*reached!*/ }
  .map   { /* reached! */ }
  ...
```

Error does propagate until it is catched using `catch`, then the chain is restored and continues.

In other words:
* a `map` or `flatMap` completion block is reached if __all__ of the above promises __resolve__
* a `catch` or `flatCatch` rejection block is reached if __one__ of the promises above __rejects__ or __throws__
* once the error is catched, the chain is restored

In other other words, considering the above example, lets say that `fetchPodName` calls __reject__ or __throw__, the following `map` completion blocks __are not__ called but the first `catch` completion block, ie. `{ _ in "👎" }`, __is__. Because the error in `fetchPodName` is now intercepted, the chain is restored and can continue to the next `map` completion block and so on.

### Create promises

A promise represents the eventual result of asynchronous operation. Even synchronous indeed.

```swift
func fetchPodName() -> PromiseLite<String> {
  PromiseLite<String> { resolve, reject in
    async(after: 0.1) {
      resolve("PromiseLite") // ✅ async retrieving pod name "PromiseLite" is a success, call `resolve`
      // if anything goes wrong, call `reject` or `throw`
    }
  }
}

func postOnTwitter(message: String) -> PromiseLite<Bool> {
  PromiseLite<Bool> { resolve, reject in
    async(after: 0.1) {
      reject(AppError.invalidToken) // ❌ async posting message on twitter fails, call `reject` or `throw`
      // if it is a success, call `resolve`
    }
  }
}

// Note that synchronous function can be chained to promise using `map`.

func editTwitterMessage(podName: String) -> String {
  "Lets chain async functions with \(podName)!" // ✅ sync returning the twitter message
}

// Some helpers

let aPromiseThatResolves = PromiseLite.resolve("foo")
let aPromiseThatRejects = PromiseLite<String>.reject(FooError.💥)
```

**Note:**
* a Promise can `throw`. It is equivalent to calling `do { try myFunctionThatThrows() } catch { reject(error) }`.
* the first `resolve`, `reject` or `throw` that is reached __wins__ and any further calls will be __ignored__.  

## Authors

- François Rouault

Feel free to submit merge request.

## License

PromiseLite is available under the MIT license. See the LICENSE file for more info.
