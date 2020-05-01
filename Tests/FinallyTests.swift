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
    var isCalled = false

    // when
    Promise<Int>(executor)
      .finally { isCalled = true }

    // then
    XCTAssertTrue(isCalled)
  }

  func test_finally_is_called_when_promise_rejects() {
    // given
    let executor: (Resolve<Int>, Reject) throws -> Void = { _, reject in
      reject(FooError.💥)
    }
    var isCalled = false

    // when
    Promise<Int>(executor)
      .finally { isCalled = true }

    // then
    XCTAssertTrue(isCalled)
  }
}
