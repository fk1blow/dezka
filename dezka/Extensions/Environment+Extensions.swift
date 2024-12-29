//
//  Environment+Extensions.swift
//  dezka
//
//  Created by Dragos Tudorache on 28.12.2024.
//

import SwiftUI

struct DezkaApplicationKey: EnvironmentKey {
  static var defaultValue: Dezka? = nil
}

extension EnvironmentValues {
  var dezka: Dezka? {
    get { self[DezkaApplicationKey.self] }
    set { self[DezkaApplicationKey.self] = newValue }
  }
}
