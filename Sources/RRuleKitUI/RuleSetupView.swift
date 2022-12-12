//
//  RuleSetupView.swift
//
//
//  Created by Thanh Duy Truong on 01/12/2022.
//

import RRuleKit
import SwiftUI

public struct RuleSetupView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.presentationMode) private var presentationMode

    @Binding private var rule: RecurrenceRule

    private var defaultRules: [RecurrenceRule] = []
    private var title = Localized.setup
    private var style = Style()

    public init(rule: Binding<RecurrenceRule>) {
        _rule = rule
    }

    public var body: some View {
        NavigationView {
            navigationContentView
        }
        .navigationViewStyle(.stack)
        .accentColor(style.accentColor)
    }

    private var navigationContentView: some View {
        contentView
            .navigationTitle(title)
            .navigationBarHidden(true)
            .onAppear {
                if rule.dateStart == nil {
                    rule.dateStart = Date()
                }
                if rule.timeZoneIdentifier == nil {
                    rule.timeZoneIdentifier = calendar.timeZone.identifier
                }
            }
    }

    private var contentView: some View {
        List {
            Section {
                repeatCell

                switch rule.frequency {
                case .minutely, .hourly:
                    EmptyView()
                default:
                    timeCell
                }
            }

            Section {
                advanceCell
            }
        }
    }

    private var repeatCell: some View {
        NavigationLink {
            RepeatView(rule: $rule, defaultRules: defaultRules)
                .style(RepeatView.Style(
                    labelPrimaryColor: style.labelPrimaryColor,
                    labelSecondaryColor: style.labelSecondaryColor,
                    systemBackgroundSecondaryColor: style.systemBackgroundSecondaryColor
                ))
        } label: {
            HStack {
                Text(Localized.repeat)
                    .font(.body)
                    .foregroundColor(style.labelPrimaryColor)

                Spacer()

                Text(repeatTitle)
                    .font(.body)
                    .foregroundColor(style.labelSecondaryColor)
            }
        }
    }

    private var timeCell: some View {
        DatePicker(Localized.time, selection: .init {
            rule.dateStart ?? Date()
        } set: { newDate in
            rule.dateStart = newDate
        }, displayedComponents: [.hourAndMinute])
            .datePickerStyle(.compact)
    }

    private var advanceCell: some View {
        NavigationLink {
            AdvanceView(rule: $rule)
                .style(AdvanceView.Style(
                    labelPrimaryColor: style.labelPrimaryColor,
                    labelSecondaryColor: style.labelSecondaryColor,
                    systemBackgroundSecondaryColor: style.systemBackgroundSecondaryColor
                ))
        } label: {
            HStack {
                Text(Localized.advance)
                    .font(.body)
                    .foregroundColor(style.labelPrimaryColor)

                Spacer()
            }
        }
    }

    private var repeatTitle: String {
        let defaultOption = RepeatView.Option.defaultCases.first { option in
            RepeatView.isEqual(rule, option.rule)
        }

        if let defaultOption {
            return defaultOption.title
        } else {
            return Localized.custom
        }
    }
}

public extension RuleSetupView {
    struct Style {
        public var accentColor: Color
        public var labelPrimaryColor: Color
        public var labelSecondaryColor: Color
        public var systemBackgroundSecondaryColor: Color

        public init(
            accentColor: Color = .init(.systemBlue),
            labelPrimaryColor: Color = .init(.label),
            labelSecondaryColor: Color = .init(.secondaryLabel),
            systemBackgroundSecondaryColor: Color = .init(.secondarySystemBackground)
        ) {
            self.accentColor = accentColor
            self.labelPrimaryColor = labelPrimaryColor
            self.labelSecondaryColor = labelSecondaryColor
            self.systemBackgroundSecondaryColor = systemBackgroundSecondaryColor
        }
    }

    func style(_ style: Style) -> Self {
        var s = self
        s.style = style
        return s
    }

    func title(_ title: String) -> Self {
        var s = self
        s.title = title
        return s
    }

    func defaultRules(_ rules: [RecurrenceRule]) -> Self {
        var s = self
        s.defaultRules = rules
        return s
    }
}
