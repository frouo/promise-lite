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

  func test_rejection_handler_is_called_when_promise_rejects_sync() {
    // given
    var isFlatMapCompletionCalled = false
    var resultFlatMap: Error?
    var isMapCompletionCalled = false
    var resultMap: Error?
    let executor: (Resolve<String>, Reject) -> Void = { resolve, reject in
      reject(FooError.💥)
    }
    func foo() -> Promise<String> {
      Promise<String> { resolve, _ in
        resolve("foo")
      }
    }

    // when
    let promise = Promise<String>(executor)
    promise.flatMap({ _ -> Promise<String> in isFlatMapCompletionCalled = true; return foo() },
                    rejection: { error in resultFlatMap = error; return foo() })

    promise.map({ _ -> String in isMapCompletionCalled = true; return "foo"},
                rejection: { error -> String in resultMap = error; return "foo" })

    // then
    XCTAssertFalse(isFlatMapCompletionCalled)
    XCTAssertEqual(resultFlatMap as? FooError, FooError.💥)
    XCTAssertFalse(isMapCompletionCalled)
    XCTAssertEqual(resultMap as? FooError, FooError.💥)
  }

  func test_rejection_handler_is_called_when_promise_rejects_async() {
    // given
    let expectationFlatMap = XCTestExpectation()
    var isFlatMapCompletionCalled = false
    var resultFlatMap: Error?
    let expectationMap = XCTestExpectation()
    var isMapCompletionCalled = false
    var resultMap: Error?
    let executor: (Resolve<String>, @escaping Reject) -> Void = { resolve, reject in
      async(after: 0.1) {
        reject(FooError.💥)
      }
    }
    func foo() -> Promise<String> {
      Promise<String> { resolve, _ in
        resolve("foo")
      }
    }

    // when
    let promise = Promise<String>(executor)
    promise.flatMap({ _ -> Promise<String> in isFlatMapCompletionCalled = true; return foo() },
                    rejection: { error in resultFlatMap = error; expectationFlatMap.fulfill(); return foo() })

    promise.map({ _ -> String in isMapCompletionCalled = true; return "foo"},
                rejection: { error -> String in resultMap = error; expectationMap.fulfill(); return "foo" })

    // then
    wait(for: [expectationMap, expectationFlatMap], timeout: 1)
    XCTAssertFalse(isFlatMapCompletionCalled)
    XCTAssertEqual(resultFlatMap as? FooError, FooError.💥)
    XCTAssertFalse(isMapCompletionCalled)
    XCTAssertEqual(resultMap as? FooError, FooError.💥)
  }
}
