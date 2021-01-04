# Change Log

All notable changes to this project will be documented in this file.
`PromiseLite` adheres to [Semantic Versioning](https://semver.org/).

---

## 2.0.0

- Remove deprecated methods
- Generate docs using [Jazzy](https://github.com/realm/jazzy)

## 1.5.0

- Debug promises by setting `PromiseLiteConfiguration.debugger` variable
- Introduce `DefaultPromiseLiteDebugger`, a simple implementation of `PromiseLiteDebugger`

## 1.4.0

- Deal with rejected cases using `catch` or `flatCatch` functions
- Deal with settled cases, i.e either fulfilled or rejected, using `finally` or `flatFinally` functions
- `map(_:, rejection:)` and `flatMap(_:, rejection:)` are deprecated
- `map(finally:)` and `flatMap(finally:)` are deprecated

## 1.3.0

- Provide `resolve` and `reject` static helper functions

## 1.2.1

- Add support for iOS 9, tvOS 9, OS X 10.9, watchOS 2

## 1.2.0

- Add support to `throw` error within Promise, `map` and `flapMap` functions
- Add `finally` handler to a promise. The handler is called when the promise is settled, whether fulfilled or rejected

## 1.1.0

- Fix: the first `resolve` or `reject` that is reached wins and any further calls will be ignored

## 1.0.0

- A promise represents the eventual result of an asynchronous operation. The primary way of interacting with a promise is through its `map` or `flatMap` methods, which registers callbacks to receive either a promise’s eventual value or the reason why the promise cannot be fulfilled
