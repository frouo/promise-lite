//
//  PromiseLite.swift
//  PromiseLite
//
//  Created by François Rouault on 25/04/2020.
//

/// An object that represents the eventual completion or failure of an asynchronous operation, and its resulting value.
public class PromiseLite {

  /// Creates a promise and executes the given executor.
  /// - Parameter executor: The function to be executed by the constructor, during the process of constructing the promise.
  public init(executor: () -> Void) {
    executor()
  }
}
