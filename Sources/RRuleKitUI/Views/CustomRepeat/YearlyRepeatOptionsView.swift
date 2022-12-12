//
//  YearlyRepeatOptionsView.swift
//
//
//  Created by Thanh Duy Truong on 02/12/2022.
//

import RRuleKit
import SwiftUI

struct YearlyRepeatOptionsView: View {
    @Environment(\.calendar) private var calendar

    @Binding private var rule: RecurrenceRule
    private var style = Style()

    @State private var months: [Int]

    init(rule: Binding<RecurrenceRule>) {
        _rule = rule
        _months = .init(initialValue: rule.wrappedValue.monthsOfTheYear)
    }

    private static let allMonths = Array(1 ... 12)

    var body: some View {
        contentView
            .onChange(of: months) { newMonths in
                rule.monthsOfTheYear = newMonths
            }
    }

    private var contentView: some View {
        Section {
            let columns: [GridItem] = Array(
                repeating: GridItem(.flexible(), spacing: 1),
                count: 3
            )
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(Self.allMonths, id: \.self) { month in
                    let isSelected = months.contains(month)

                    let color: Color = isSelected ? .accentColor : .clear
                    color
                        .frame(height: 50)
                        .overlay {
                            Text(getSymbolOfMonth(month) ?? "")
                                .foregroundColor(isSelected ? .white : style.labelPrimaryColor)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isSelected {
                                months.removeAll { $0 == month }
                            } else {
                                months.append(month)
                            }
                        }
                        .animation(.linear(duration: 0.1), value: isSelected)
                }
            }
            .listRowInsets(EdgeInsets())
        }
    }

    private func getSymbolOfMonth(_ month: Int) -> String? {
        let allSymbols = calendar.shortMonthSymbols
        guard allSymbols.count >= month, month > 0 else {
            return nil
        }
        return allSymbols[month - 1]
    }
}

extension YearlyRepeatOptionsView {
    struct Style {
        var labelPrimaryColor: Color = .init(.label)
    }

    func style(_ style: Style) -> Self {
        var s = self
        s.style = style
        return s
    }
}
