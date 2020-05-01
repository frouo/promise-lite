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

  func test_executor_can_throw() {
    // given
    let executor: (Resolve<Int>, Reject) throws -> Void = { _, _ in
      throw FooError.💥
    }

    // when
    _ = PromiseLite<Int>(executor)

    // then
    XCTAssert(true)
  }
}
