//
//  PromiseLite.swift
//  PromiseLite
//
//  Created by François Rouault on 25/04/2020.
//

/// An object that represents the eventual completion or failure of an asynchronous operation, and its resulting value.
public class PromiseLite<Value> {
  private enum State {
    case pending
    case fulfilled(Value)
    case rejected(Error)
  }

  private var state: State = .pending
  private lazy var completions = [((Value) -> Void, (Error) -> Void)]()

  /// Creates a promise and executes the given executor.
  /// - Parameter executor: The function to be executed by the constructor, during the process of constructing the promise.
  public init(_ executor: (_ resolve: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void) {
    do {
      try executor(resolve, reject)
    } catch {
      reject(error: error)
    }
  }

  private func resolve(value: Value) {
    guard case .pending = state else { return }
    state = .fulfilled(value)
    completions.forEach { $0.0(value) }
  }

  private func reject(error: Error) {
    guard case .pending = state else { return }
    state = .rejected(error)
    completions.forEach { $0.1(error) }
  }

  private func then(completion: @escaping (Value) -> Void, rejection: @escaping (Error) -> Void) {
    if case let State.fulfilled(value) = state {
      completion(value)
    } else if case let State.rejected(error) = state {
      rejection(error)
    } else {
      completions.append((completion, rejection))
    }
  }

  /// Returns a promise.
  /// - Parameter completion: A completion block that is called if the promise fulfilled.
  @discardableResult
  public func flatMap<NewValue>(_ completion: @escaping (Value) throws -> PromiseLite<NewValue>) -> PromiseLite<NewValue> {
    flatMap(completion,
            rejection: { error in PromiseLite<NewValue> { _, rejectWith in rejectWith(error) }})
  }

  /// Returns a promise.
  /// - Parameter completion: A completion block that is called if the promise fulfilled.
  /// - Parameter rejection: A completion block that is called if the promise rejected.
  @discardableResult
  public func flatMap<NewValue>(_ completion: @escaping (Value) throws -> PromiseLite<NewValue>, rejection: @escaping (Error) -> PromiseLite<NewValue>) -> PromiseLite<NewValue> {
    return PromiseLite<NewValue> { [weak self] resolveWith, rejectWith in
      self?.then(
        completion: { value in
          let promise = try? completion(value)
          promise?.then(completion: { newValue in resolveWith(newValue) },
                       rejection: { rejectWith($0) }) },
        rejection: { error in
          let promise = rejection(error)
          promise.then(completion: { resolveWith($0) },
                       rejection: { rejectWith($0) })
      })
    }
  }
}
