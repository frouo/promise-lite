//
//  PromiseLiteDebugger.swift
//  PromiseLite
//
//  Created by François Rouault on 18/05/2020.
//

/// Methods you can implement to observe promise lifecycle.
public protocol PromiseLiteDebugger {
  /// Tells the debugger that a promise gets initialized.
  /// - Parameters:
  ///   - description: A short text that describes the promise, cf. `init`.
  ///   - date: The date when the promise's `init` has been called.
  func promise(description: String, initAt date: Date)
}
