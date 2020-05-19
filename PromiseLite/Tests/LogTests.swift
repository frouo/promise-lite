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

  func test_static_resolve_helper_description() {
    let _ = Promise.resolve(description: "goo", 2)
    XCTAssertEqual(debugger?.initAtIsCalled, "goo")

    let _ = Promise.resolve(2)
    XCTAssertEqual(debugger?.initAtIsCalled, "PromiseLite<Int>")
  }

  func test_static_reject_helper_description() {
    let _ = Promise<String>.reject(description: "noo", FooError.💥)
    XCTAssertEqual(debugger?.initAtIsCalled, "noo")

    let _ = Promise<String>.reject(FooError.💥)
    XCTAssertEqual(debugger?.initAtIsCalled, "PromiseLite<String>")
  }

  func test_debugger_is_triggered_when_promise_resolves() {
    // when
    Promise.resolve(description: "foo", 3)
      .map { value in true }

    // then
    XCTAssertEqual(debugger?.events, ["foo-init",
                                      "foo-resolves",
                                      "PromiseLite<Bool>-init",
                                      "PromiseLite<Bool>-resolves"])
  }

  func test_debugger_is_triggered_when_promise_rejects() {
    // when
    Promise<Int>.reject(description: "foo", FooError.💥)
      .catch { value in 3 }

    // then
    XCTAssertEqual(debugger?.events, ["foo-init",
                                      "foo-rejects-error[💥]",
                                      "PromiseLite<Int>-init",
                                      "PromiseLite<Int>-resolves"])
  }

  func test_unflatten_scenario() {
    // when
    Promise.resolve(description: "p1", 3)
      .map { value in throw FooError.💥 }
      .map { value -> Bool in throw FooError.🧨 }
      .catch { value in true }
      .catch { value in throw FooError.💥 }
      .map { value in "goo" }
      .map { value in true }
      .finally { throw FooError.🧨 }
      .finally { 42 }

    // then
    XCTAssertEqual(debugger!.events, [
      "p1-init", "p1-resolves",
      "PromiseLite<()>-init", "PromiseLite<()>-rejects-error[💥]",
      "PromiseLite<Bool>-init", "PromiseLite<Bool>-rejects-error[💥]",
      "PromiseLite<Bool>-init", "PromiseLite<Bool>-resolves", // catch
      "PromiseLite<Bool>-init", "PromiseLite<Bool>-resolves", // 2nd catch: it resolves because error has been handled in the first catch!
      "PromiseLite<String>-init", "PromiseLite<String>-resolves",
      "PromiseLite<Bool>-init", "PromiseLite<Bool>-resolves",
      "PromiseLite<()>-init", "PromiseLite<()>-rejects-error[🧨]",
      "PromiseLite<Int>-init", "PromiseLite<Int>-resolves"
    ])
  }

  func test_flat_scenario() {
    // when
    Promise.resolve(description: "p1", 3)
      .flatMap { value -> Promise<Int> in throw FooError.💥 }
      .flatMap { value -> Promise<Bool> in throw FooError.🧨 }
      .flatCatch { error in Promise.resolve(description: "first-catch", true) }
      .flatCatch { error in Promise<Bool>.reject(description: "2nd-catch", FooError.💥) }
      .flatMap { value in Promise.resolve(description: "goo", "goo") }
      .flatMap { value in Promise.resolve(description: "a-bool", true) }
      .flatFinally { Promise<()>.reject(description: "1st-finally", FooError.🧨) }
      .flatFinally { Promise.resolve(description: "2nd-finally", 42) }

    // then
    XCTAssertEqual(debugger!.events, [
      "p1-init", "p1-resolves",
      "PromiseLite<Int>-init", "PromiseLite<Int>-rejects-error[💥]",
      "PromiseLite<Bool>-init", "PromiseLite<Bool>-rejects-error[💥]",
      "first-catch-init", "first-catch-resolves", // catch
      "PromiseLite<Bool>-init", "PromiseLite<Bool>-resolves", // 2nd catch: promise "2nd-catch" is not even initialized because error has been handled above!
      "goo-init", "goo-resolves",
      "a-bool-init", "a-bool-resolves",
      "1st-finally-init", "1st-finally-rejects-error[🧨]",
      "2nd-finally-init", "2nd-finally-resolves"
    ])
  }
}

private class PromiseLiteDebuggerMock: PromiseLiteDebugger {
  var initAtIsCalled: String?
  var events = [String]()

  func promise(description: String, initAt date: Date) {
    initAtIsCalled = description
    events.append(description + "-init")
  }

  func promise(description: String, resolvesAt: Date) {
    events.append(description + "-resolves")
  }

  func promise(description: String, rejectsAt: Date, error: Error) {
    events.append(description + "-rejects-error[\(error)]")
  }
}
