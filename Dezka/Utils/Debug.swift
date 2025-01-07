//
//  Debug.swift
//  Dezka
//

struct Debug {
  enum Level {
    case info, warning, error
  }

  #if DEBUG
    static let isEnabled = true
  #else
    static let isEnabled = false
  #endif

  static func log(_ message: String, level: Level = .info) {
    guard isEnabled else { return }
    print("[\(level)] \(message)")
  }
}
