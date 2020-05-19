//
//  LogTests.swift
//  PromiseLite-Unit-Tests
//
//  Created by François Rouault on 18/05/2020.
//

import XCTest
@testable import PromiseLite

private typealias Promise = PromiseLite

class LogTests: XCTestCase {
  func test_promise_can_init_with_a_debug_description() {
    // given
    let description = "foo"

    // when
    let promise = Promise(description) { resolve, _ in resolve(2) }

    // then
    XCTAssertEqual(promise.description, "foo")
  }

  func test_promise_default_description() {
    // when
    let promise = Promise { resolve, _ in resolve(2) }

    // then
    XCTAssertEqual(promise.description, "PromiseLite<Int>")
  }
}
