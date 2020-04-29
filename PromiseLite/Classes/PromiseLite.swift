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
  private lazy var completions = [((Value) -> Void)]()

  /// Creates a promise and executes the given executor.
  /// - Parameter executor: The function to be executed by the constructor, during the process of constructing the promise.
  public init(_ executor: (_ resolve: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) -> Void) {
    executor(resolve, reject)
  }

  private func resolve(value: Value) {
    state = .fulfilled(value)
    completions.forEach { $0(value) }
  }

  private func reject(error: Error) {
    state = .rejected(error)
  }

  private func then(completion: @escaping (Value) -> Void, rejection: (Error) -> Void) {
    if case let State.fulfilled(value) = state {
      completion(value)
    } else if case let State.rejected(error) = state {
      rejection(error)
    } else {
      completions.append(completion)
    }
  }

  /// Returns a promise.
  /// - Parameter completion: A completion block that is called if the promise fulfilled.
  @discardableResult
  public func flatMap<NewValue>(_ completion: @escaping (Value) -> PromiseLite<NewValue>) -> PromiseLite<NewValue> {
    flatMap(completion,
            rejection: { error in PromiseLite<NewValue> { _, rejectWith in rejectWith(error) }})
  }

  /// Returns a promise.
  /// - Parameter completion: A completion block that is called if the promise fulfilled.
  /// - Parameter rejection: A completion block that is called if the promise rejected.
  @discardableResult
  public func flatMap<NewValue>(_ completion: @escaping (Value) -> PromiseLite<NewValue>, rejection: (Error) -> PromiseLite<NewValue>) -> PromiseLite<NewValue> {
    return PromiseLite<NewValue> { [weak self] resolveWith, rejectWith in
      self?.then(
        completion: { value in
          let promise = completion(value)
          promise.then(completion: { newValue in resolveWith(newValue) },
                       rejection: { rejectWith($0) }) },
        rejection: { error in
          let promise = rejection(error)
          promise.then(completion: { resolveWith($0) },
                       rejection: { rejectWith($0) })
      })
    }
  }

  /// Returns a promise.
  /// - Parameter completion: A completion block that is called if the promise fulfilled.
  @discardableResult
  public func map<NewValue>(_ completion: @escaping (Value) -> NewValue) -> PromiseLite<NewValue> {
    map(completion, rejection: nil)
  }

  /// Returns a promise.
  /// - Parameter completion: A completion block that is called if the promise fulfilled.
  /// - Parameter rejection: A completion block that is called if the promise rejected.
  @discardableResult
  public func map<NewValue>(_ completion: @escaping (Value) -> NewValue, rejection: @escaping (Error) -> NewValue) -> PromiseLite<NewValue> {
    map(completion, rejection: Optional.some(rejection))
  }

  private func map<NewValue>(_ completion: @escaping (Value) -> NewValue, rejection: ((Error) -> NewValue)?) -> PromiseLite<NewValue> {
    flatMap(
      { value -> PromiseLite<NewValue> in
        PromiseLite<NewValue> { (resolveWith, _) in
          resolveWith(completion(value))
        }},
      rejection: { error -> PromiseLite<NewValue> in
        PromiseLite<NewValue> { resolveWith, rejectWith in
          if let newValue = rejection?(error) {
            resolveWith(newValue)
          } else {
            rejectWith(error)
          }
        }}
    )
  }
}
