//
//  CatchTests.swift
//  Pods-PromiseLite_Tests
//
//  Created by François Rouault on 26/04/2020.
//

import XCTest
import PromiseLite

private typealias Promise = PromiseLite

class CatchTests: XCTestCase {
  func test_reject_can_be_catched_then_continue() {
    // given
    var theError: Error?
    var theResult: String?

    // when
    Promise<String>.reject(FooError.💥)
      .flatCatch { error -> Promise<String> in theError = error; return Promise.resolve("error handled") }
      .map { aString in theResult = aString }

    // then
    XCTAssertEqual(theError as? FooError, FooError.💥)
    XCTAssertEqual(theResult, "error handled")
  }

  func test_catch_return_a_value() {
    // given
    var theError: Error?
    var theResult: String?

    // when
    Promise<String>.reject(FooError.💥)
      .catch { error in theError = error; return "error handled" }
      .map { aString in theResult = aString }

    // then
    XCTAssertEqual(theError as? FooError, FooError.💥)
    XCTAssertEqual(theResult, "error handled")
  }

  func test_catch_rejection_block_is_ignored_when_promise_resolves() {
    // given
    let promiseThatResolve = Promise.resolve(7)
    var result: Int?

    // when
    promiseThatResolve
      .catch { _ in 3 }
      .map { result = $0 }

    // then
    XCTAssertEqual(result, 7)
  }

  func test_catch_rejection_block_can_throw() {
    var result: Error?
    
    Promise<Int>.reject(FooError.💥)
      .catch { _ in throw FooError.🧨 }
      .map { _ in XCTFail("Completion must not be called") }
      .catch { error in result = error }

    XCTAssertEqual(result as? FooError, FooError.🧨)
  }
}
