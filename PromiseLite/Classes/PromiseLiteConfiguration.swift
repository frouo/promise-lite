//
//  PromiseLiteConfiguration.swift
//  PromiseLite
//
//  Created by François Rouault on 18/05/2020.
//

internal typealias Configuration = PromiseLiteConfiguration

/// A configuration object that defines behavior for promises.
public struct PromiseLiteConfiguration {
  /// A debugger object that can be used to debug promises.
  public static var debugger: PromiseLiteDebugger?
}
