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

private func fetchPodName() -> PromiseLite<String> {
  PromiseLite<String> { resolve, _ in
    async(after: 0.1) {
      resolve("PromiseLite") // 💎 retrieved pod name "PromiseLite" (async)
    }
  }
}

private func editTwitterMessage(podName: String) -> String {
  "Lets chain sync and async functions with \(podName)!" // 📝 returns the twitter message (sync)
}

private func postOnTwitter(message: String) -> PromiseLite<Bool> {
  PromiseLite<Bool> { resolve, _ in
    async(after: 0.1) {
      resolve(true) // 🐦 message posted on twitter (async)
      // reject(AppError.invalidToken) // if anything went wrong, call `reject`.
    }
  }
}

class UsageExamples: XCTestCase {
  func test_example_1() {
    let expectation = XCTestExpectation()
    var isTweetPosted = false

    fetchPodName()
      .map { editTwitterMessage(podName: $0) }
      .flatMap { postOnTwitter(message: $0) }
      .map { success in
        isTweetPosted = success
        expectation.fulfill() }

    wait(for: [expectation], timeout: 1)
    XCTAssertTrue(isTweetPosted)
  }

  func test_example_2() {
    let expectation = XCTestExpectation()
    var result: String?

    func postOnTwitter(message: String) -> PromiseLite<Bool> {
      PromiseLite<Bool> { _, reject in
        reject(AppError.invalidToken)
      }
    }

    fetchPodName()
      .map { editTwitterMessage(podName: $0) }
      .flatMap { postOnTwitter(message: $0) }
      .map({ _ in "👍" }, rejection: { _ in "👎" })
      .map { postSentStatus in
        result = postSentStatus
        expectation.fulfill() }

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(result, "👎")
  }
}
