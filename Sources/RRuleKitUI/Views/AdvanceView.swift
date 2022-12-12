//
//  AdvanceView.swift
//
//
//  Created by Thanh Duy Truong on 06/12/2022.
//

import RRuleKit
import SwiftUI

struct AdvanceView: View {
    @Environment(\.calendar) private var calendar

    @Binding private var rule: RecurrenceRule
    private var style = Style()

    @State private var mode: EndRepeatMode

    init(rule: Binding<RecurrenceRule>) {
        _rule = rule
        let initialMode: EndRepeatMode = {
            switch rule.wrappedValue.recurrenceEnd {
            case .end:
                return .on
            case .occurrenceCount:
                return .after
            case nil:
                return .never
            }
        }()
        _mode = .init(initialValue: initialMode)
    }

    var body: some View {
        contentView
            .navigationTitle(Localized.advance)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: mode) { newMode in
                switch newMode {
                case .never:
                    rule.recurrenceEnd = nil
                case .on:
                    switch rule.recurrenceEnd {
                    case .end:
                        break
                    default:
                        let current = Date()
                        let date = calendar.date(byAdding: .day, value: 3, to: current) ?? current
                        rule.recurrenceEnd = .end(date)
                    }
                case .after:
                    switch rule.recurrenceEnd {
                    case .occurrenceCount:
                        break
                    default:
                        rule.recurrenceEnd = .occurrenceCount(3)
                    }
                }
            }
    }

    private var contentView: some View {
        List {
            Section {
                timezoneCell
            }

            Section {
                endRepeatCell

                switch mode {
                case .never:
                    EmptyView()
                case .on:
                    endRepeatOnConfigView
                case .after:
                    endRepeatAfterConfigView
                }
            }
        }
    }

    private var timezoneCell: some View {
        NavigationLink {
            TimeZoneView(rule: $rule)
                .style(TimeZoneView.Style(
                    labelPrimaryColor: style.labelPrimaryColor
                ))
        } label: {
            HStack {
                Text(Localized.timezone)
                    .foregroundColor(style.labelPrimaryColor)

                Spacer()

                Text(rule.timeZoneIdentifier ?? "")
                    .foregroundColor(style.labelSecondaryColor)
            }
        }
        .font(.body)
    }

    private var endRepeatCell: some View {
        HStack {
            Text(Localized.endRepeat)
                .foregroundColor(style.labelPrimaryColor)

            Spacer()

            Menu {
                ForEach(EndRepeatMode.allCases, id: \.self) { mode in
                    Button {
                        self.mode = mode
                    } label: {
                        Text(mode.title)
                    }
                }
            } label: {
                HStack {
                    Text(mode.title)
                        .fixedSize(horizontal: true, vertical: false)
                        .multilineTextAlignment(.trailing)
                    Image(systemName: "chevron.down")
                }
            }
        }
        .font(.body)
    }

    @ViewBuilder
    private var endRepeatOnConfigView: some View {
        if case let .end(date) = rule.recurrenceEnd {
            DatePicker("", selection: .init {
                date
            } set: { newDate in
                rule.recurrenceEnd = .end(newDate)
            })
            .datePickerStyle(.graphical)
        }
    }

    @State private var occurrences: Int = 3
    @ViewBuilder
    private var endRepeatAfterConfigView: some View {
        if case let .occurrenceCount(count) = rule.recurrenceEnd {
            HStack(spacing: 8) {
                Spacer()

                NumberTextField(value: .init {
                    count
                } set: { newValue in
                    rule.recurrenceEnd = .occurrenceCount(newValue)
                })
                .multilineTextAlignment(.trailing)
                .padding(10)
                .frame(width: 91, height: 40)
                .background(style.systemBackgroundSecondaryColor)
                .cornerRadius(5)

                Text(Localized.occurrences(count))
                    .foregroundColor(style.labelSecondaryColor)
            }
            .font(.body)
            .animation(.linear, value: count)
        }
    }
}

extension AdvanceView {
    enum EndRepeatMode: CaseIterable {
        case never
        case on
        case after

        var title: String {
            switch self {
            case .never:
                return Localized.never
            case .on:
                return Localized.on
            case .after:
                return Localized.after
            }
        }
    }
}

extension AdvanceView {
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

struct AdvanceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvanceView(rule: .constant(.init(recurrenceWith: .daily)!))
        }
        .navigationViewStyle(.stack)
    }
}
