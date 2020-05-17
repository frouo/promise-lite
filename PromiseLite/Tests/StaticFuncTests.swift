//
//  StaticFuncTests.swift
//  PromiseLite-Unit-Tests
//
//  Created by François Rouault on 02/05/2020.
//

import XCTest
import PromiseLite

private typealias Promise = PromiseLite

class StaticFuncTests: XCTestCase {
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    super.tearDown()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func test_static_func_resolve_does_resolve() {
    // given
    var result: Int?

    // when
    Promise.resolve(3)
      .map { result = $0 }
      .catch { _ in XCTFail("Static func 'resolve' must resolve") }

    // then
    XCTAssertEqual(result, 3)
  }

  func test_static_func_reject_does_reject() {
    // given
    var result: Error?

    // when
    Promise<Int>.reject(FooError.💥)
      .map { _ in XCTFail("Static func 'reject' must reject") }
      .catch { error in result = error }

    // then
    XCTAssertEqual(result as? FooError, FooError.💥)
  }
}
