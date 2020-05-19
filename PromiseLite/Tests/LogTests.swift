//
//  LogTests.swift
//  PromiseLite-Unit-Tests
//
//  Created by François Rouault on 18/05/2020.
//

import XCTest
import PromiseLite

private typealias Promise = PromiseLite

class LogTests: XCTestCase {
  private var debugger: PromiseLiteDebuggerMock?

  override func setUp() {
    super.setUp()
    debugger = PromiseLiteDebuggerMock()
    PromiseLiteConfiguration.debugger = debugger
  }

  override func tearDown() {
    super.tearDown()
    debugger = nil
  }

  func test_initAt_is_triggered_when_promise_with_description_executes() {
    let _ = Promise("foo1") { resolve, _ in resolve(2) }
    XCTAssertEqual(debugger?.initAtIsCalled, "foo1")

    let _ = Promise<Int>("foo2") { _, reject in reject(FooError.💥) }
    XCTAssertEqual(debugger?.initAtIsCalled, "foo2")

    let _ = Promise<Int>("foo3") { _, _ in throw FooError.💥 }
    XCTAssertEqual(debugger?.initAtIsCalled, "foo3")
  }

  func test_initAt_is_triggered_when_promise_without_description_executes() {
    let _ = Promise { resolve, _ in resolve(2) }
    XCTAssertEqual(debugger?.initAtIsCalled, "PromiseLite<Int>")

    let _ = Promise { resolve, _ in resolve(1.23) }
    XCTAssertEqual(debugger?.initAtIsCalled, "PromiseLite<Double>")

    let _ = Promise { resolve, _ in resolve(true) }
    XCTAssertEqual(debugger?.initAtIsCalled, "PromiseLite<Bool>")
  }
}

private class PromiseLiteDebuggerMock: PromiseLiteDebugger {
  var initAtIsCalled: String?

  func promise(description: String, initAt date: Date) {
    initAtIsCalled = description
  }
}
