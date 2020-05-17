//
//  PromiseLite+Catch.swift
//  PromiseLite
//
//  Created by François Rouault on 17/05/2020.
//

extension PromiseLite {
  /// Returns a Promise and deals with rejected cases only.
  ///
  /// The Promise returned by `catch()` is rejected if the rejection block throws an error or returns a Promise which is itself rejected; otherwise, it is resolved.
  /// - Parameter rejection: A completion block that is called when the Promise is rejected.
  @discardableResult
  public func flatCatch(_ rejection: @escaping (Error) throws -> PromiseLite) -> PromiseLite {
    flatMap(completion: { value in PromiseLite.resolve(value) },
            rejection: rejection)
  }

  /// Returns a Promise and deals with rejected cases only.
  ///
  /// The Promise returned by `catch()` is rejected if the rejection block throws an error or returns a Promise which is itself rejected; otherwise, it is resolved.
  /// - Parameter rejection: A completion block that is called when the Promise is rejected.
  @discardableResult
  public func `catch`(_ rejection: @escaping (Error) throws -> Value) -> PromiseLite {
    flatMap(completion: { value in PromiseLite.resolve(value) },
            rejection: { PromiseLite.resolve(try rejection($0)) })
  }
}
