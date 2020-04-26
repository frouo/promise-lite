import XCTest
import PromiseLite

typealias Promise = PromiseLite

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
    _ = Promise { isExecutorCalled = true }

    // then
    XCTAssertTrue(isExecutorCalled)
  }
}
