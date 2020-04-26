import XCTest
import PromiseLite

private typealias Promise = PromiseLite

private func async(after timeInterval: TimeInterval, execute: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval, execute: execute)
}

class PromiseLiteTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func test_executor_is_called_during_promise_initialization() {
    // given
    var isExecutorCalled = false

    // when
    _ = Promise<Void> { _ in isExecutorCalled = true }

    // then
    XCTAssertTrue(isExecutorCalled)
  }

  func test_completion_handler_is_called_when_executor_is_sync() {
    // given
    let executor: ((Int) -> Void) -> Void = { resolve in
      resolve(5)
    }
    var result = 0

    // when
    let promise = Promise<Int>(executor)

    promise.then() { integer in
      result += integer
    }

    // then
    XCTAssertEqual(result, 5)
  }

  func test_completion_handler_is_called_when_executor_is_async() {
    // given
    let expectation = XCTestExpectation()
    let executor: (@escaping (Int) -> Void) -> Void = { resolve in
      async(after: 0.1) {
        resolve(7)
      }
    }
    var result = 0

    // when
    let promise = Promise<Int>(executor)

    promise.then() { string in
      result += string
      expectation.fulfill()
    }

    // then
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(result, 7)
  }

  func test_sync_promise_supports_many_completion_handlers() {
    // given
    let promise = Promise<Int> { resolve in
      resolve(3)
    }
    var result1 = 0
    var result2 = 0

    // when
    promise.then { result in
      result1 += result
    }

    promise.then { result in
      result2 += result
    }

    // then
    XCTAssertEqual(result1, 3)
    XCTAssertEqual(result2, 3)
  }

  func test_async_promise_supports_many_completion_handlers() {
    // given
    let expectation1 = XCTestExpectation()
    let expectation2 = XCTestExpectation()
    let promise = Promise<Int> { resolve in
      async(after: 0.1) {
        resolve(3)
      }
    }
    var result1 = 0
    var result2 = 0

    // when
    promise.then { result in
      result1 += result
      expectation1.fulfill()
    }

    promise.then { result in
      result2 += result
      expectation2.fulfill()
    }

    // then
    wait(for: [expectation1, expectation2], timeout: 1)
    XCTAssertEqual(result1, 3)
    XCTAssertEqual(result2, 3)
  }

  func test_completion_handlers_can_be_chained() {
    // given
    let expectation = XCTestExpectation()
    let promise = Promise<Int> { resolve in
      async(after: 0.1) {
        resolve(3)
      }
    }
    var result = ""

    // when
    promise
      .then { res in
        return Promise<String> { resolve in
          async(after: 0.1) {
            resolve("foo \(res)")
          }
        }}
      .then { res in
        result += res
        expectation.fulfill() }

    // then
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(result, "foo 3")
  }

  func test_completion_handler_can_return_value() {
    // given
    var result = ""

    // when
    Promise<Int> { resolve in resolve(3) }
      .then { "goo \($0 + 5)" }
      .then { "foo \($0)" }
      .then { result += $0 }

    // then
    XCTAssertEqual(result, "foo goo 8")
  }

  func test_chaining_mixing_async_and_sync() {
    // given
    let expectation = XCTestExpectation()
    var result = ""
    
    let fetchThree: () -> Promise<Int> = {
      Promise<Int> { resolve in
        async(after: 0.1) { resolve(3) }
      }
    }

    let addFiveAsyncTo: (Int) -> Promise<Int> = { integer in
      Promise<Int> { resolve in
        async(after: 0.1) { resolve(integer + 5) }
      }
    }

    let prefixWithGoo: (String) -> Promise<String> = { string in Promise<String> { resolve in resolve("goo \(string)") }}

    let fetchTadamEmoji: (String) -> Promise<String> = { _ in
      Promise<String> { resolve in
        async(after: 0.1) { resolve("🎉") }
      }
    }

    // when
    fetchThree() // resolves 3
      .then { result in addFiveAsyncTo(result) } // resolves 3+5 = 8
      .then { result in prefixWithGoo(String(result)) } // resolves "goo 8"
      .then { result in "foo \(result)" } // resolves "foo goo 8"
      .then { result in
        fetchTadamEmoji(result).then { emoji in "\(result) \(emoji)"}} // resolves "foo goo 8 🎉"
      .then { res in
        result += res
        expectation.fulfill() }

    // then
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(result, "foo goo 8 🎉")
  }
}
