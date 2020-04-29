//
//  UsageExamples.swift
//  Pods-PromiseLite_Tests
//
//  Created by François Rouault on 26/04/2020.
//

import XCTest
import PromiseLite

private func async(after timeInterval: TimeInterval, execute: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval, execute: execute)
}

class UsageExamples: XCTestCase {
  func test_example_with_thens() {
    let expectation = XCTestExpectation()
    var isTweetPosted = false

    func fetchPodName() -> PromiseLite<String> {
      PromiseLite<String> { resolve, _ in
        async(after: 0.1) {
          resolve("PromiseLite") // 💎 retrieved pod name "PromiseLite" (async)
        }
      }
    }

    func createMyTwitterMessage(podName: String) -> String {
      "\(podName) is out 🎉." // 📝 my twitter message (sync)
    }

    func postOnTwitter(message: String) -> PromiseLite<Bool> {
      PromiseLite<Bool> { resolve, _ in
        async(after: 0.1) {
          resolve(true) // 🐦 message posted on twitter (async)
        }
      }
    }

    fetchPodName()
      .map { createMyTwitterMessage(podName: $0) }
      .flatMap { postOnTwitter(message: $0) }
      .map { success in
        isTweetPosted = success
        expectation.fulfill() }

    wait(for: [expectation], timeout: 1)
    XCTAssertTrue(isTweetPosted)
  }
}
