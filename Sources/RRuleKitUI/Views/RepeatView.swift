//
//  RepeatView.swift
//
//
//  Created by Thanh Duy Truong on 02/12/2022.
//

import RRuleKit
import SwiftUI

struct RepeatView: View {
    @Binding private var rule: RecurrenceRule
    private let defaultRules: [RecurrenceRule]
    private var style = Style()

    init(rule: Binding<RecurrenceRule>, defaultRules: [RecurrenceRule]) {
        _rule = rule
        self.defaultRules = defaultRules
    }

    var body: some View {
        contentView
            .navigationTitle(Localized.repeat)
            .navigationBarTitleDisplayMode(.inline)
    }

    private var contentView: some View {
        List {
            Section {
                ForEach(defaultRules, id: \.self) { defaultRule in
                    let isSelected = Self.isEqual(rule, defaultRule)

                    Button {
                        var newRule = defaultRule
                        if let timeZoneIdentifier = rule.timeZoneIdentifier,
                           let dateStart = rule.dateStart
                        {
                            newRule.timeZoneIdentifier = timeZoneIdentifier
                            newRule.dateStart = dateStart
                        }
                        rule = newRule
                    } label: {
                        HStack {
                            Text(defaultRule.toString)
                                .foregroundColor(style.labelPrimaryColor)

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .font(.body)
                }
            }

            Section {
                let isSelected = !isDefaultRule(rule)

                ZStack {
                    HStack {
                        Text(Localized.custom)
                            .foregroundColor(style.labelPrimaryColor)

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .font(.body)

                    NavigationLink {
                        CustomRepeatView(rule: $rule)
                            .style(CustomRepeatView.Style(
                                labelPrimaryColor: style.labelPrimaryColor,
                                labelSecondaryColor: style.labelSecondaryColor
                            ))
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)
                }
            }
        }
    }

    static func isEqual(_ rule1: RecurrenceRule?, _ rule2: RecurrenceRule?) -> Bool {
        guard let rule1, let rule2 else {
            return false
        }

        let ruleParser = RuleParser()
        return ruleParser.rule(from: rule1) == ruleParser.rule(from: rule2)
    }

    private func isDefaultRule(_ rule: RecurrenceRule?) -> Bool {
        guard let rule else {
            return false
        }

        return defaultRules.contains { defaultRule in
            Self.isEqual(rule, defaultRule)
        }
    }
}

extension RepeatView {
    struct Style {
        var labelPrimaryColor: Color = .init(.label)
        var labelSecondaryColor: Color = .init(.secondaryLabel)
        var systemBackgroundSecondaryColor: Color = .init(.secondarySystemBackground)
    }

    func style(_ style: Style) -> Self {
        var s = self
        s.style = style
        return s
    }
}
