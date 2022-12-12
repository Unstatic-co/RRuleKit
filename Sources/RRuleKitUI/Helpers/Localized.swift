//
//  Localized.swift
//
//
//  Created by Thanh Duy Truong on 08/12/2022.
//

import Foundation

private class BundleGetter {
    private init() {}
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return .module
        #else
            return Bundle(for: BundlerGetter.self)
        #endif
    }()
}

private extension String {
    private var bundle: Bundle {
        BundleGetter.bundle
    }

    var localized: String {
        bundle.localizedString(forKey: self, value: self, table: nil)
    }

    func localized(_ args: CVarArg...) -> String {
        let format = bundle.localizedString(forKey: self, value: self, table: nil)
        return String(format: format, locale: .current, args)
    }
}

enum Localized {
    static let `repeat` = "repeat".localized
    static let time = "time".localized
    static let advance = "advance".localized
    static let setup = "setup".localized

    // Repeat
    static let custom = "custom".localized

    // Advance
    static let timezone = "timezone".localized
    static let endRepeat = "endRepeat".localized
    static let never = "never".localized
    static let on = "on".localized
    static let after = "after".localized
    static func occurrences(_ value: Int) -> String {
        "occurrences".localized(value)
    }

    // Custom repeat
    static let customRepeat = "customRepeat".localized
    static let frequency = "frequency".localized
    static let every = "every".localized
    static let each = "each".localized
    static let onThe = "onThe".localized
}
