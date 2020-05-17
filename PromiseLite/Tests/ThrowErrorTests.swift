//
//  ThrowErrorTests.swift
//  PromiseLite-Unit-Tests
//
//  Created by François Rouault on 01/05/2020.
//

import XCTest
import PromiseLite

private typealias Promise = PromiseLite
private typealias Resolve<Value> = (Value) -> Void
private typealias Reject = (Error) -> Void

class ThrowErrorTests: XCTestCase {
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    super.tearDown()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func test_rejection_handler_is_called_when_executor_throws() {
    // given
    var result: Error?
    var completionIsCalled = false
    let executor: (Resolve<Int>, Reject) throws -> Void = { _, _ in
      throw FooError.💥
    }

    // when
    PromiseLite<Int>(executor)
      .map { _ in completionIsCalled = true }
      .catch { error in result = error }

    // then
    XCTAssertFalse(completionIsCalled)
    XCTAssertEqual(result as? FooError, FooError.💥)
  }

  func test_rejection_handler_is_called_when_flatMap_completion_throws() {
    // given
    var result: Error?
    var completionIsCalled = false
    let executor: (Resolve<Int>, Reject) throws -> Void = { resolve, _ in
      resolve(7)
    }

    // when
    PromiseLite<Int>(executor)
      .flatMap { _ -> Promise<Bool> in throw FooError.💥 }
      .map { _ in completionIsCalled = true }
      .catch { error in result = error }

    // then
    XCTAssertFalse(completionIsCalled)
    XCTAssertEqual(result as? FooError, FooError.💥)
  }

  func test_rejection_handler_is_called_when_map_completion_throws() {
    // given
    var result: Error?
    var completionIsCalled = false
    let executor: (Resolve<Int>, Reject) throws -> Void = { resolve, _ in
      resolve(7)
    }

    // when
    PromiseLite<Int>(executor)
      .map { _ in throw FooError.💥 }
      .map { _ in completionIsCalled = true }
      .catch { error in result = error }

    // then
    XCTAssertFalse(completionIsCalled)
    XCTAssertEqual(result as? FooError, FooError.💥)
  }

  func test_rejection_handler_is_called_when_flatMap_rejection_throws() {
    // given
    var result: Error?
    var completionIsCalled = false
    let executor: (Resolve<Int>, Reject) throws -> Void = { _, reject in
      reject(FooError.💥)
    }
    let aPromise = Promise<Int>(executor)

    // when
    PromiseLite<Int>(executor)
      .flatMap { _ -> Promise<Int> in aPromise }
      .flatCatch { _ -> Promise<Int> in throw FooError.🧨 }
      .flatMap { _ -> Promise<Int> in
          completionIsCalled = true
          return aPromise }
      .flatCatch { error -> Promise<Int> in
          result = error
          return aPromise }

    // then
    XCTAssertFalse(completionIsCalled)
    XCTAssertEqual(result as? FooError, FooError.🧨)
  }

  func test_rejection_handler_is_called_when_map_rejection_throws() {
    // given
    var result: Error?
    var completionIsCalled = false
    let executor: (Resolve<Int>, Reject) throws -> Void = { _, reject in
      reject(FooError.💥)
    }

    // when
    PromiseLite<Int>(executor)
      .map { _ in }
      .catch { _ in throw FooError.🧨 }
      .map { _ in completionIsCalled = true }
      .catch { error in result = error }

    // then
    XCTAssertFalse(completionIsCalled)
    XCTAssertEqual(result as? FooError, FooError.🧨)
  }
}
