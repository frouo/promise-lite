//
//  PromiseLite+Static.swift
//  PromiseLite
//
//  Created by François Rouault on 11/05/2020.
//

extension PromiseLite {
  /// Returns a Promise that is resolved with a given value.
  /// - Parameter value: The argument to be resolved by this Promise.
  public static func resolve(_ value: Value) -> PromiseLite<Value> {
    PromiseLite { resolve, _ in resolve(value) }
  }

  /// Returns a Promise that is rejected with a given reason.
  /// - Parameter error: The reason why this Promise rejected.
  public static func reject(_ error: Error) -> PromiseLite<Value> {
    PromiseLite { _, reject in reject(error) }
  }
}
