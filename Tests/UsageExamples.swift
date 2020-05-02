//
//  UsageExamples.swift
//  Pods-PromiseLite_Tests
//
//  Created by François Rouault on 26/04/2020.
//

import XCTest
import PromiseLite

private enum AppError: Error {
  case invalidToken
}

func fetchPodName() -> PromiseLite<String> {
  PromiseLite<String> { resolve, reject in
    async(after: 0.1) {
      resolve("PromiseLite")
    }
  }
}

// Note that synchronous function can be chained to promise using `map`.

func editTwitterMessage(podName: String) -> String {
  "Lets chain async functions with \(podName)!" // ✅ sync returning the twitter message
}

class UsageExamples: XCTestCase {
  func test_example_1() {
    // given
    let expectation = XCTestExpectation()
    var isTweetPosted = false
    func postOnTwitter(message: String) -> PromiseLite<Bool> {
      PromiseLite<Bool> { resolve, reject in
        async(after: 0.1) {
          resolve(true)
        }
      }
    }

    // when
    fetchPodName()
      .map { editTwitterMessage(podName: $0) }
      .flatMap { postOnTwitter(message: $0) }
      .map { isTweetPosted = $0 }
      .map(finally: { expectation.fulfill() })

    // then
    wait(for: [expectation], timeout: 1)
    XCTAssertTrue(isTweetPosted)
  }

  func test_example_2() {
    // given
    let expectation = XCTestExpectation()
    var result: String?

    func postOnTwitter(message: String) -> PromiseLite<Bool> {
      PromiseLite<Bool> { _, reject in
        reject(AppError.invalidToken)
      }
    }

    // when
    fetchPodName()
      .map { editTwitterMessage(podName: $0) }
      .flatMap { postOnTwitter(message: $0) }
      .map({ _ in "👍" }, rejection: { _ in "👎" })
      .map { result = $0 }
      .map(finally: { expectation.fulfill() })

    // then
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(result, "👎")
  }
}
