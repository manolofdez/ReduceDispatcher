// Copyright (c) 2024 Manuel Fernandez. All rights reserved.

import Foundation

extension String {
    /// Lowercases the first letter of the word only
    func uppercasingFirst() -> String {
        guard let firstLetter = first?.uppercased() else { return "" }
        guard count > 1 else { return firstLetter }
        return firstLetter + dropFirst()
    }
}
