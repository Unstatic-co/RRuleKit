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
    static let minutely = "minutely".localized
    static let hourly = "hourly".localized
    static let daily = "daily".localized
    static let weekly = "weekly".localized
    static let monthly = "monthly".localized
    static let yearly = "yearly".localized
    static func minutes(_ value: Int) -> String {
        "minutes".localized(value)
    }

    static func hours(_ value: Int) -> String {
        "hours".localized(value)
    }

    static func days(_ value: Int) -> String {
        "days".localized(value)
    }

    static func weeks(_ value: Int) -> String {
        "weeks".localized(value)
    }

    static func months(_ value: Int) -> String {
        "months".localized(value)
    }

    static func years(_ value: Int) -> String {
        "years".localized(value)
    }

    static func everyMinutes(_ value: Int) -> String {
        "everyMinutes".localized(value)
    }

    static func everyHours(_ value: Int) -> String {
        "everyHours".localized(value)
    }

    static func everyDays(_ value: Int) -> String {
        "everyDays".localized(value)
    }

    static func everyWeeks(_ value: Int) -> String {
        "everyWeeks".localized(value)
    }

    static func everyMonths(_ value: Int) -> String {
        "everyMonths".localized(value)
    }

    static func everyYears(_ value: Int) -> String {
        "everyYears".localized(value)
    }

    static let every = "every".localized
    static let weekend = "weekend".localized
    static let weekday = "weekday".localized
}
