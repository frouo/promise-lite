//
//  PromiseLite+Map.swift
//  PromiseLite
//
//  Created by François Rouault on 01/05/2020.
//

import Foundation

extension PromiseLite {
  /// Returns a promise.
  /// - Parameter completion: A completion block that is called if the promise fulfilled.
  @discardableResult
  public func map<NewValue>(_ completion: @escaping (Value) throws -> NewValue) -> PromiseLite<NewValue> {
    map(completion, rejection: nil)
  }

  /// Use `map(_:)` and `catch(_:)` instead.
  /// - Parameter completion: A completion block that is called if the promise fulfilled.
  /// - Parameter rejection: A completion block that is called if the promise rejected.
  @available(*, deprecated, message: "Use `catch` instead to deal with rejected cases")
  @discardableResult
  public func map<NewValue>(_ completion: @escaping (Value) throws -> NewValue, rejection: @escaping (Error) throws -> NewValue) -> PromiseLite<NewValue> {
    map(completion, rejection: Optional.some(rejection))
  }

  private func map<NewValue>(_ completion: @escaping (Value) throws -> NewValue, rejection: ((Error) throws -> NewValue)?) -> PromiseLite<NewValue> {
    flatMap(
      completion: { value -> PromiseLite<NewValue> in
        PromiseLite<NewValue> { (resolveWith, _) in
          resolveWith(try completion(value))
        }},
      rejection: { error -> PromiseLite<NewValue> in
        PromiseLite<NewValue> { resolveWith, rejectWith in
          if let newValue = try rejection?(error) {
            resolveWith(newValue)
          } else {
            rejectWith(error)
          }
        }}
    )
  }
}
