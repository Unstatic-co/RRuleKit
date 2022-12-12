//
//  MonthlyRepeatOptionsView.swift
//
//
//  Created by Thanh Duy Truong on 01/12/2022.
//

import RRuleKit
import SwiftUI

struct MonthlyRepeatOptionsView: View {
    @Binding private var rule: RecurrenceRule
    private var style = Style()

    @State private var mode: Mode = .daysOfMonth
    @State private var days: [Int]

    init(rule: Binding<RecurrenceRule>) {
        _rule = rule
        _days = .init(initialValue: rule.wrappedValue.daysOfTheMonth)
    }

    private static let allDaysOfMonth = 1 ... 31

    var body: some View {
        contentView
            .onChange(of: days) { newDays in
                rule.daysOfTheMonth = newDays
            }
    }

    var contentView: some View {
        Section {
            Button {
                mode = .daysOfMonth
            } label: {
                HStack {
                    Text(Localized.each)
                        .font(.body)
                        .foregroundColor(style.labelPrimaryColor)

                    Spacer()

                    if mode == .daysOfMonth {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }

            if mode == .daysOfMonth {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 50), spacing: 1),
                    ],
                    spacing: 1
                ) {
                    ForEach(Self.allDaysOfMonth, id: \.self) { day in
                        let isSelected = days.contains(day)

                        let color: Color = isSelected ? .accentColor : .clear
                        color
                            .aspectRatio(1, contentMode: .fill)
                            .overlay {
                                Text("\(day)")
                                    .foregroundColor(isSelected ? .white : style.labelPrimaryColor)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if isSelected {
                                    days.removeAll { $0 == day }
                                } else {
                                    days.append(day)
                                }
                            }
                            .animation(.linear(duration: 0.1), value: isSelected)
                    }
                }
                .listRowInsets(EdgeInsets())
            }

            Button {
                mode = .onSomeDays // TODO:
            } label: {
                HStack {
                    Text(Localized.onThe)
                        .foregroundColor(style.labelPrimaryColor)

                    Spacer()

                    if mode == .onSomeDays {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .font(.body)
        }
    }
}

extension MonthlyRepeatOptionsView {
    enum Mode {
        case daysOfMonth
        case onSomeDays
    }

    struct Style {
        var labelPrimaryColor: Color = .init(.label)
    }

    func style(_ style: Style) -> Self {
        var s = self
        s.style = style
        return s
    }
}
