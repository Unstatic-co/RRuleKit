//
//  CustomRepeatView.swift
//
//
//  Created by Thanh Duy Truong on 29/11/2022.
//

import RRuleKit
import SwiftUI

struct CustomRepeatView: View {
    @Environment(\.calendar) private var calendar

    @Binding private var rule: RecurrenceRule
    private var style = Style()

    @State private var weekInterval = 1
    @State private var frequency: RecurrenceFrequency

    init(rule: Binding<RecurrenceRule>) {
        _rule = rule
        _frequency = .init(initialValue: rule.wrappedValue.frequency)
    }

    var body: some View {
        contentView
            .navigationTitle(Localized.customRepeat)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: frequency) { newFrequency in
                if var newRule = RecurrenceRule(recurrenceWith: newFrequency) {
                    if let timeZoneIdentifier = rule.timeZoneIdentifier,
                       let dateStart = rule.dateStart
                    {
                        newRule.timeZoneIdentifier = timeZoneIdentifier
                        newRule.dateStart = dateStart
                    }
                    rule = newRule
                }
            }
    }

    private var contentView: some View {
        List {
            frequencyView

            optionsView
                .transition(.asymmetric(insertion: .opacity, removal: .identity))
                .animation(.linear, value: frequency)
        }
    }

    private var frequencyView: some View {
        Section {
            Picker(Localized.frequency, selection: $frequency) {
                ForEach(RecurrenceFrequency.allCases, id: \.self) { frequency in
                    Button(frequency.text.capitalized) {
                        withAnimation {
                            self.frequency = frequency
                        }
                    }
                    .tag(frequency)
                }
            }
            .pickerStyle(.menu)
            .font(.body)

            switch frequency {
            case .minutely, .hourly:
                inputView
            default:
                stepperView
            }
        }
    }

    private var stepperView: some View {
        Stepper(value: $rule.interval, in: 1 ... 1_000_000) {
            let interval = rule.interval
            Text(frequency.everyText(interval))
                .font(.body)
        }
    }

    private var inputView: some View {
        HStack {
            Text(Localized.every)
                .font(.body)
            Spacer()
            HStack(spacing: 6) {
                NumberTextField(value: .init {
                    rule.interval
                } set: { newValue in
                    rule.interval = newValue
                })
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)

                Text(frequency.pluralText(rule.interval))
                    .foregroundColor(style.labelSecondaryColor)
            }
            .font(.body)
        }
    }

    @ViewBuilder
    private var optionsView: some View {
        switch frequency {
        case .minutely:
            EmptyView()
        case .hourly:
            EmptyView()
        case .daily:
            EmptyView()
        case .weekly:
            WeeklyRepeatOptionsView(rule: $rule)
                .style(WeeklyRepeatOptionsView.Style(
                    labelPrimaryColor: style.labelPrimaryColor
                ))
        case .monthly:
            MonthlyRepeatOptionsView(rule: $rule)
                .style(MonthlyRepeatOptionsView.Style(
                    labelPrimaryColor: style.labelPrimaryColor
                ))
        case .yearly:
            YearlyRepeatOptionsView(rule: $rule)
                .style(YearlyRepeatOptionsView.Style(
                    labelPrimaryColor: style.labelPrimaryColor
                ))
        }
    }
}

extension CustomRepeatView {
    struct Style {
        var labelPrimaryColor: Color = .init(.label)
        var labelSecondaryColor: Color = .init(.secondaryLabel)
    }

    func style(_ style: Style) -> Self {
        var s = self
        s.style = style
        return s
    }
}

extension Weekday {
    func symbol(with calendar: Calendar) -> String? {
        let symbols = calendar.weekdaySymbols
        guard symbols.count >= rawValue else {
            return nil
        }
        return symbols[rawValue - 1]
    }
}
