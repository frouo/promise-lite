# Change Log
All notable changes to this project will be documented in this file.
`PromiseLite` adheres to [Semantic Versioning](https://semver.org/).

---

## [1.4.0](https://github.com/frouo/promise-lite/releases/tag/1.4.0)

* Deal with rejected cases using `catch` or `flatCatch` functions
* `map(_:, rejection:)` and `flatMap(_:, rejection:)` are deprecated
* Deal with settled cases, i.e either fulfilled or rejected, using `finally` or `flatFinally` functions
* `map(finally:)` and `flatMap(finally:)` are deprecated

## [1.3.0](https://github.com/frouo/promise-lite/releases/tag/1.3.0)

* Provide `resolve` and `reject` static helper functions

## [1.2.1](https://github.com/frouo/promise-lite/releases/tag/1.2.1)

* Add support for iOS 9, tvOS 9, OS X 10.9, watchOS 2

## [1.2.0](https://github.com/frouo/promise-lite/releases/tag/1.2.0)

* Add support to `throw` error within Promise, `map` and `flapMap` functions
* Add `finally` handler to a promise. The handler is called when the promise is settled, whether fulfilled or rejected

## [1.1.0](https://github.com/frouo/promise-lite/releases/tag/1.1.0)

* Fix: the first `resolve` or `reject` that is reached wins and any further calls will be ignored

## [1.0.0](https://github.com/frouo/promise-lite/releases/tag/1.0.0)

* A promise represents the eventual result of an asynchronous operation. The primary way of interacting with a promise is through its `map` or `flatMap` methods, which registers callbacks to receive either a promise’s eventual value or the reason why the promise cannot be fulfilled
