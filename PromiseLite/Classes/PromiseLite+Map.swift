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
    flatMap { PromiseLite<NewValue>.resolve(try completion($0)) }
  }
}
