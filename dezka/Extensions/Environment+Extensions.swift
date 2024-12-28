//
//  Environment+Extensions.swift
//  dezka
//
//  Created by Dragos Tudorache on 28.12.2024.
//

import SwiftUI

struct AppDelegateKey: EnvironmentKey {
    static var defaultValue: AppDelegate? = nil
}

extension EnvironmentValues {
    var appDelegate: AppDelegate? {
        get { self[AppDelegateKey.self] }
        set { self[AppDelegateKey.self] = newValue }
    }
}
