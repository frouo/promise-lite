//
//  FinallyTests.swift
//  PromiseLite-Unit-Tests
//
//  Created by François Rouault on 02/05/2020.
//

import XCTest
import PromiseLite

private typealias Promise = PromiseLite
private typealias Resolve<Value> = (Value) -> Void
private typealias Reject = (Error) -> Void

class FinallyTests: XCTestCase {
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    super.tearDown()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func test_finally_is_called_when_promise_resolves() {
    // given
    let executor: (Resolve<Int>, Reject) throws -> Void = { resolve, _ in
      resolve(3)
    }
    let aPromise = Promise<String> { resolve, _ in resolve("foo") }
    var isCalled = false

    // when
    Promise<Int>(executor)
      .flatFinally { () -> Promise<String> in isCalled = true; return aPromise }

    // then
    XCTAssertTrue(isCalled)
  }

  func test_finally_is_called_when_promise_rejects() {
    // given
    let executor: (Resolve<Int>, Reject) throws -> Void = { _, reject in
      reject(FooError.💥)
    }
    let aPromise = Promise<String> { resolve, _ in resolve("foo") }
    var isCalled = false

    // when
    Promise<Int>(executor)
      .flatFinally { () -> Promise<String> in isCalled = true; return aPromise }

    // then
    XCTAssertTrue(isCalled)
  }

  func test_flatMap_finally_can_be_chained() {
    // given
    let executor: (Resolve<Int>, Reject) throws -> Void = { resolve, _ in
      resolve(3)
    }
    let aPromise = Promise<String> { resolve, _ in resolve("foo") }
    var result: String?

    // when
    Promise<Int>(executor)
      .flatFinally { aPromise }
      .map { string in result = string }

    // then
    XCTAssertEqual(result, "foo")
  }

  func test_map_finally_can_be_chained() {
    // given
    let executor: (Resolve<Int>, Reject) throws -> Void = { resolve, _ in
      resolve(3)
    }
    var result: String?

    // when
    Promise<Int>(executor)
      .finally { "foo" }
      .map { string in result = string }

    // then
    XCTAssertEqual(result, "foo")
  }

  func test_flatMap_finally_can_throw() {
    // given
    let executor: (Resolve<Int>, Reject) throws -> Void = { resolve, _ in
      resolve(3)
    }
    var result: Error?
    var string: String?

    // when
    Promise<Int>(executor)
      .flatFinally { () -> Promise<String> in throw FooError.💥 }
      .map { str in string = str }
      .catch  { error in result = error }

    // then
    XCTAssertNil(string)
    XCTAssertEqual(result as? FooError, FooError.💥)
  }

  func test_map_finally_can_throw() {
    // given
    let executor: (Resolve<Int>, Reject) throws -> Void = { resolve, _ in
      resolve(3)
    }
    var result: Error?
    var string: String?

    // when
    Promise<Int>(executor)
      .finally { throw FooError.💥 }
      .map { str in string = str }
      .catch { error in result = error }

    // then
    XCTAssertNil(string)
    XCTAssertEqual(result as? FooError, FooError.💥)
  }
}
