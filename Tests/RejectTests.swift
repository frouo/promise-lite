//
//  RejectTests.swift
//  PromiseLite-Unit-Tests
//
//  Created by François Rouault on 27/04/2020.
//

import XCTest
import PromiseLite

private typealias Promise = PromiseLite
private typealias Resolve<Value> = (Value) -> Void
private typealias Reject = (Error) -> Void

class RejectTests: XCTestCase {
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    super.tearDown()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func test_executor_can_call_reject() {
    // given
    var isThenCalled = false
    let executor: (Resolve<String>, Reject) -> Void = { resolve, reject in
      reject(FooError.💥)
    }

    // when
    let promise = Promise<String>(executor)
    promise.map { _ in isThenCalled = true }

    // then
    XCTAssertFalse(isThenCalled)
  }
}
