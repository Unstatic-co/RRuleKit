//
//  WeeklyRepeatOptionsView.swift
//
//
//  Created by Thanh Duy Truong on 01/12/2022.
//

import RRuleKit
import SwiftUI

struct WeeklyRepeatOptionsView: View {
    @Environment(\.calendar) private var calendar

    @Binding private var rule: RecurrenceRule
    private var style = Style()

    @State var daysOfTheWeek: [Weekday]

    init(rule: Binding<RecurrenceRule>) {
        _rule = rule
        _daysOfTheWeek = .init(initialValue: rule.wrappedValue.daysOfTheWeek.map(\.dayOfTheWeek))
    }

    private static let allWeekdays: [Weekday] = Weekday.allCases

    var body: some View {
        contentView
            .onChange(of: daysOfTheWeek) { newDays in
                rule.daysOfTheWeek = newDays.map { .init($0) }
            }
    }

    var contentView: some View {
        Section {
            ForEach(Self.allWeekdays, id: \.self) { weekDay in
                let isSelected = daysOfTheWeek.contains(weekDay)

                Button {
                    if isSelected {
                        daysOfTheWeek.removeAll { $0 == weekDay }
                    } else {
                        daysOfTheWeek.append(weekDay)
                    }
                } label: {
                    HStack {
                        Text(weekDay.symbol(with: calendar) ?? "")
                            .foregroundColor(style.labelPrimaryColor)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                }
                .font(.body)
            }
        }
    }
}

extension WeeklyRepeatOptionsView {
    struct Style {
        var labelPrimaryColor: Color = .init(.label)
    }

    func style(_ style: Style) -> Self {
        var s = self
        s.style = style
        return s
    }
}
