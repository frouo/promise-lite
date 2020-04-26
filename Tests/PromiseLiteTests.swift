import XCTest
import PromiseLite

typealias Promise = PromiseLite

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
}
