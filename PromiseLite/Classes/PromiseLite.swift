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
  }

  private var state: State = .pending
  private lazy var completions = [((Value) -> Void)]()

  /// Creates a promise and executes the given executor.
  /// - Parameter executor: The function to be executed by the constructor, during the process of constructing the promise.
  public init(_ executor: (_ resolve: @escaping (Value) -> Void) -> Void) {
    executor(resolve)
  }

  private func resolve(value: Value) {
    state = .fulfilled(value)
    completions.forEach { $0(value) }
  }

  /// Appends a fulfillment handler to the promise.
  /// - Parameter completion: A completion block that executes once the promise fulfilled.
  public func then(_ completion: @escaping (Value) -> Void) {
    if case let State.fulfilled(value) = state {
      completion(value)
    } else {
      completions.append(completion)
    }
  }

  /// `flatMap`
  /// - Parameter completion: A completion block that returns the next promise.
  public func then<NewValue>(_ completion: @escaping (Value) -> PromiseLite<NewValue>) -> PromiseLite<NewValue> {
    return PromiseLite<NewValue> { [weak self] resolveWith in
      self?.then { value in
        let promise = completion(value)
        promise.then { newValue in resolveWith(newValue) }
      }
    }
  }

  /// `map`
  /// - Parameter completion: A completion block that returns the next promise value.
  public func then<NewValue>(_ completion: @escaping (Value) -> NewValue) -> PromiseLite<NewValue> {
    then { value -> PromiseLite<NewValue> in
      return PromiseLite<NewValue> { resolveWith in
        resolveWith(completion(value))
      }
    }
  }
}
