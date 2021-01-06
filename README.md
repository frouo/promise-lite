![chaining](https://cocoricostudio.com/promiselite/readme.png)

# PromiseLite

**Lets chain async and synch functions**

[![CI Status](https://travis-ci.com/frouo/promise-lite.svg?branch=master)](https://travis-ci.com/github/frouo/promise-lite)
[![codecov](https://codecov.io/gh/frouo/promise-lite/branch/master/graph/badge.svg)](https://codecov.io/gh/frouo/promise-lite)
[![Version](https://img.shields.io/cocoapods/v/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)
[![License](https://img.shields.io/cocoapods/l/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)
[![Platform](https://img.shields.io/cocoapods/p/PromiseLite.svg?style=flat)](https://cocoapods.org/pods/PromiseLite)

PromiseLite is an implementation of [Javascript Promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) concept, in Swift.

It is pure Swift, 100% tested, and very lightweight, ~150 lines of code.

## Installation

PromiseLite is available through [CocoaPods](https://cocoapods.org). Add the following line to your Podfile:

```ruby
pod 'PromiseLite'
```

Tip: add the line `typealias Promise = PromiseLite` in your `AppDelegate.swift` (or elsewhere), it's shorter. For the rest of the page, I assume you did that.

## Get started

Start using promises in your code and chain async and sync functions within 5 minutes.

Let's say you have the following function that uses completion block to deal with asynchronous operation. You might be familiar with:

```swift
func fetch(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
  URLSession.shared.dataTask(with: url) { data, response, error in
    if let data = data {
      completion(.success(data))
    } else {
      completion(.failure(AppError.noData))
    }
  }
}
```

To be able to chain calls, you have to get rid of the completion block. Say hello to plromises!

Create another function that returns the promise of retrieving `Data`. In this new function, you can use the previously defined `fetch(url:completion:)` function within the `Promise`'s closure:

```swift
func fetch(url: URL) -> Promise<Data> {
  Promise { resolve, reject in
    fetch(url: url) { result in
      switch result {
      case .success(let data): resolve(data)
      case .failure(let error): reject(error)
      }
    }
  }
}
```

Now you can use `flatMap` to chain promises together, and `map` to chain a promise to a regular function.

```swift
let url = URL(string: "https://your.endpoint.com/user/36")!

fetch(url: url)
  .map     { try JSONDecoder().decode(User.self, from: $0) }
  .map     { $0.age >= 18 ? $0 : try { throw AppError.userIsMinor }() }
  .flatMap { fetchContents(user: $0) }
  .map     { display(contents: $0) }
  .catch   { display(error: $0) }
```

**That's it!** 🎯

Just for comparison, the above chaining is equivalent to the following code using completion blocks 🤯

```swift
// fetch(url: url) { result in
//   switch result {
//   case .success(let data):
//     do {
//       let user = try JSONDecoder().decode(User.self, from: data)
//
//       guard user.age >= 18 else {
//        display(error: AppError.userIsMinor)
//        return
//       }
//
//       fetchContents(user: user) { result2 in
//         switch result2:
//         case .success(let contents): display(contents: contents)
//         case .failure(let error): display(error: error)
//       }
//     } catch {
//       display(error: error)
//     }
//   case .failure(let error):
//     display(error: error)
//   }
// }
```

## Promises

### What is a promise?

A promise represents the eventual result of an operation (async or sync).

Its initialization parameter is called the `executor`. It is a closure that takes two functions as parameters:

- `resolve`: a function that takes a value parameter (the result of the promise)
- `reject`: a funtion that takes an error parameter

For exemple, we can define a promise this way:

```swift
func divide(a: Double, by b: Double) -> Promise<Double> {
  let executor: ((Double) -> Void, (Error) -> Void) -> Void = { resolve, reject in
    b != 0
      ? resolve(a / b)
      : reject(AppError.cannotDivideByZero)
  }
  return Promise<Double>(executor)
}
```

Fortunately Swift offers some syntax shorthand and is able to infer types. The preceding code can therefore be simplified as follows:

```swift
func divide(a: Double, by b: Double) -> Promise<Double> {
  Promise { resolve, reject in
    b != 0
      ? resolve(a / b)
      : reject(AppError.cannotDivideByZero)
  }
}
```

### More exemples...

Here is an example of a sync function that takes an string parameter and returns the promise of an URL.

```swift
func url(from urlStr: String) -> Promise<URL> {
  Promise { resolve, reject in
    if let url = URL(string: urlStr) {
      resolve(url) // ✅ the url string is valid, call `resolve`
    } else {
      reject(AppError.invalidUrl) // ❌ the url string is not valid, call `reject`
    }
  }
}
```

Here is a suggestion for wrapping `dataTask` into a promise that retrieves `Data`:

```swift
func fetch(url: URL) -> Promise<Data> {
  Promise { resolve, reject in
    URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        reject(error) // ❌ an error occured, call `reject` or `throw`
        return
      }

      guard let data = data else {
        throw AppError.noData // ❌ could not retrieve data, call `reject` or `throw`
        return
      }

      resolve(data) // ✅ data retrieved, call `resolve`
    }
  }
}
```

### Helpers

```swift
Promise.resolve("foo") // is equivalent to `Promise { resolve, _ in resolve("foo") }`
```

```swift
Promise<String>.reject(AppError.💥) // is equivalent to `Promise<String> { _, reject in reject(AppError.💥) }`

// Note that, in this situation, you must specify the type `<String>` because there is nothing in the executor that can help Swift guess the type.
```

### Good to know

- The executor function, ie. `{ resolve, reject in ... }` is executed right away by the initializer during the process of initializing the promise object.
- the first `resolve`, `reject` or `throw` that is reached **wins** and any further calls will be **ignored**.

## Chaining

Use `map` and `flatMap` to chain promises.

**Tip**: make functions as small as possible so you can compose easily. Example:

```swift
Promise.resolve("https://your.endpoint.com/user/\(id)")
  .flatMap { url(from: $0) }
  .flatMap { fetch(url: $0) }
  .map     { try JSONDecoder().decode(User.self, from: $0) }
  .map     { $0.age >= 18 }
  .flatMap { $0 ? fetchContents() : Promise.reject(AppError.userIsUnderage) }
  .map     { display(contents: $0) }
```

In the above example, we start with a string `https://your.endpoint.com/user/\(id)`, then we call `url(from:)` to transform the `string` into an `URL`, etc...

## Handling errors

An error does propagate until it is catched with `catch` or `flatCatch`. Once catched, the chaining is restored and continues.

```swift
Promise.resolve("not://a.va|id.url")
  .flatMap { url(from: $0) } // 💥 this promise rejects because the url is invalid
  .flatMap { /* not reached */ }
  .map     { /* not reached */ }
  .map     { /* not reached */ }
  .flatMap { /* not reached */ }
  .map     { /* not reached */ }
  .catch   { /* REACHED! */ }
  .map     { /* REACHED! */ }
  ...
```

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

## Changelog

Visit [CHANGELOG.md](https://github.com/frouo/promise-lite/blob/master/CHANGELOG.md)

## Authors

- François Rouault

Feel free to submit merge request.

## License

PromiseLite is available under the MIT license. See the LICENSE file for more info.
