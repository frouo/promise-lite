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

  /// Tells the debugger that a promise resolves.
  /// - Parameters:
  ///   - description: A short text that describes the promise, cf. `init`.
  ///   - date: The date when the promise's `resolve` gets called.
  func promise(description: String, resolvesAt date: Date)

  /// Tells the debugger that a promise rejects.
  /// - Parameters:
  ///   - description: A short text that describes the promise, cf. `init`.
  ///   - date: The date when the promise's `reject` gets called.
  ///   - error: The reason why the promise rejects.
  func promise(description: String, rejectsAt date: Date, error: Error)
}

/// A default implementation of `PromiseLiteDebugger`.
///
/// To enable logging promises just set `PromiseLiteConfig.debugger` variable, like `PromiseLiteConfig.debugger = DefaultPromiseLiteDebugger { print($0) }`.
///
/// # Example
/// Given the following chaining:
/// ```
/// Promise.resolve(3)
///   .map { _ in throw FooError.💥 }
///   .map { _ in "foo" }
///   .catch { _ in return "goo" }
///   .map { $0 }
/// ```
/// Logs using `print` the follwing outputs:
/// ```
/// 🔗 | PromiseLite<Int> resolves ✅ in 0.00 sec
/// 🔗 | PromiseLite<()> rejects ❌ in 0.00 sec with error: 💥
/// 🔗 | PromiseLite<String> rejects ❌ in 0.00 sec with error: 💥
/// 🔗 | PromiseLite<String> resolves ✅ in 0.00 sec
/// 🔗 | PromiseLite<String> resolves ✅ in 0.00 sec
/// ```
public final class DefaultPromiseLiteDebugger: PromiseLiteDebugger {
  private let output: (String) -> Void
  private var startDate: Date?

  public init(_ output: @escaping (String) -> Void) {
    self.output = output
  }

  public func promise(description: String, initAt date: Date) {
    startDate = date
  }

  public func promise(description: String, resolvesAt date: Date) {
    startDate.map { output("🔗 | \(description) resolves ✅ in \(String(format: "%.2f", date.timeIntervalSince($0))) sec") }
  }

  public func promise(description: String, rejectsAt date: Date, error: Error) {
    startDate.map { output("🔗 | \(description) rejects ❌ in \(String(format: "%.2f", date.timeIntervalSince($0))) sec with error: \(error)") }
  }
}
