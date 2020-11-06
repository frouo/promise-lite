![chaining](https://cocoricostudio.com/promiselite/readme.png)

# PromiseLite

[![CI Status](https://travis-ci.com/frouo/promise-lite.svg?branch=master)](https://travis-ci.com/github/frouo/promise-lite)
[![codecov](https://codecov.io/gh/frouo/promise-lite/branch/master/graph/badge.svg)](https://codecov.io/gh/frouo/promise-lite)
[![Version](https://img.shields.io/cocoapods/v/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)
[![License](https://img.shields.io/cocoapods/l/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)
[![Platform](https://img.shields.io/cocoapods/p/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)

Lets chain asynchronous functions.

`PromiseLite` is an implementation of [Javascript Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) in Swift.

It is pure Swift, 100% tested, and very lightweight, ~150 lines of code 🌱

## Installation

PromiseLite is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'PromiseLite'
```

## Usage

### Chain promises

```swift
fetchUser(id: "123")
  .map     { addUsername(user: $0) }
  .flatMap { saveInDatabase(user: $0) }
  .map     { isSuccess in isSuccess ? "👍" : "👎" }
  .map     { thumbs in label.text = thumbs }
  .finally { isLoading = false }
```

### Throw error

All chaining functions support error throwing.

```swift
fetchUser(id: "123")
  .map { addUsername(user: $0) }
  .map { /* ... */ throw AppError.somethingWentWrong }
  .map { /* not reached */ }
  .map { /* not reached */ }
  ...
```

### Catch error

Use `catch` to deal with rejected cases.

```swift
fetchUser(id: "123")
  .map   { addUsername(user: $0) }
  .map   { /* ... */ throw AppError.somethingWentWrong }
  .map   { /* not reached */ }
  .map   { /* not reached */ }
  .map   { /* not reached */ }
  .catch { err in "👎" /*reached!*/ }
  .map   { /* reached! */ }
  ...
```

Error does propagate until it is catched using `catch`, then the chaining is restored and continues.

In other words:

- a `map` or `flatMap` completion block is reached if **all** of the above promises **resolve**
- a `catch` or `flatCatch` rejection block is reached if **one** of the promises above **rejects** or **throws**
- once the error is catched, the chaining is restored

In other other words, considering the above example, lets say that `fetchUser` calls **reject** or **throw**, the following `map` completion blocks **are not** called but the first `catch` completion block, ie. `{ _ in "👎" }`, **is**. Because the error in `fetchUser` is now intercepted, the chaining is restored and can continue to the next `map` completion block and so on.

### Create promises

A promise represents the eventual result of asynchronous operation. Even synchronous indeed.

```swift
func fetchUser(id: String) -> PromiseLite<User> {
  PromiseLite<User> { resolve, reject in
    URLSession.shared.dataTask(with: Api.fetchUser(id).asRequest()) { data, response, error in
      if let error = error {
        reject(error) // ❌ an error occured, call `reject`
        return
      }

      guard let data = data else {
        reject(ApiError.dataNotFound) // ❌ could not retrieve data, call `reject` with an error
        return
      }

      let user = try JSONDecoder().decode(User.self, from: data) // ❓ executor can throw so call `try` peacefully, no need to call `reject`
      resolve(user) // ✅ fetched user with success, call `resolve`
    }
  }
}

// Note that synchronous function can be chained to promise using `map`.

func addUsername(user: User) -> User {
  user.username = "\(user.firstname) \(user.lastname)"
  return user // ✅
}

// Some helpers

let aPromiseThatResolves = PromiseLite.resolve("foo")
let aPromiseThatRejects = PromiseLite<String>.reject(FooError.💥)
```

**Note:**

- The executor function, ie. `{ resolve, reject in ... }` is executed right away by the initializer during the process of initializing the promise object.
- a Promise can `throw`. It is equivalent to calling `do { try myFunctionThatThrows() } catch { reject(error) }`.
- the first `resolve`, `reject` or `throw` that is reached **wins** and any further calls will be **ignored**.

## How to debug a chaining?

Watch promise lifecycle by setting `PromiseLiteConfiguration.debugger` instance. This instance is called when a promise starts and when it resolves or rejects. `PromiseLite` provides a default implementation of the `PromiseLiteDebugger` protocol: `DefaultPromiseLiteDebugger(output:)`.

```swift
// Do the following to print default debugger output in the console.
PromiseLiteConfiguration.debugger = DefaultPromiseLiteDebugger { print($0) }
```

In addition, a promise can be initialized with a description so it is easier to understand which promise is currently being executed. By default, the description of a promise is `PromiseLite<TheType>`.

```swift
func fetchUser(id: String) -> PromiseLite<User> {
  PromiseLite<User>("fetch user") { resolve, reject in
    ...
  }
}

func saveInDatabase(user: User) -> PromiseLite<Bool> {
  PromiseLite<Bool>("save in db") { resolve, reject in
    ...
  }
}

fetchUser(id: "123")
  .flatMap { saveInDatabase(user: $0) }
  .map { [weak self] _ in self?.updateUI() }
  .catch { [weak self] err in self?.updateUI(error: err) }

// The above chaining will result in the following logs in the console:
// 🔗 | fetch user resolves ✅ in 1.36 sec
// 🔗 | save in db resolves ✅ in 0.72 sec
// 🔗 | PromiseLite<()> resolves ✅ in 0.00 sec
// 🔗 | PromiseLite<()> resolves ✅ in 0.00 sec
// Note that `map` and `catch` implicitly creates a promise with the default description. Since `updateUI` is a function that returns void, the type's value of the implicity created promise is `()`.
// Note that `catch` actually resolves because it implicitly creates a promise that resolves regardless of whether the previous promise resolved or rejected.

// In case, `fetchUser(id:)` would reject, the above chaining would result in the following logs in the console:
// 🔗 | fetch user rejects ❌ in 1.36 sec
// 🔗 | save in db rejects ❌ in 0.00 sec
// 🔗 | PromiseLite<()> rejects ❌ in 0.00 sec
// 🔗 | PromiseLite<()> resolves ✅ in 0.00 sec
// Note that rejection does propagate until `catch` handle the error returning a promise that resolves.
```

## Authors

- François Rouault

Feel free to submit merge request.

## License

PromiseLite is available under the MIT license. See the LICENSE file for more info.
