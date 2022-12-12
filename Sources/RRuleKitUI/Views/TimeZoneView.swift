//
//  TimeZoneView.swift
//
//
//  Created by Thanh Duy Truong on 07/12/2022.
//

import RRuleKit
import SwiftUI

struct TimeZoneView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding private var rule: RecurrenceRule
    private var style = Style()

    @State private var timeZoneIdentifer: String?
    @State private var searchText = ""

    private static let allTimeZoneIdentifers = TimeZone.knownTimeZoneIdentifiers

    private var filteredIdentifiers: [String] {
        Self.allTimeZoneIdentifers.filter {
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty || $0.contains(searchText)
        }
    }

    init(rule: Binding<RecurrenceRule>) {
        _rule = rule
        _timeZoneIdentifer = .init(initialValue: rule.wrappedValue.timeZoneIdentifier)
    }

    var body: some View {
        contentView
            .navigationTitle("Time Zone")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: timeZoneIdentifer ?? ""
            )
            .onChange(of: timeZoneIdentifer) { newIdentifier in
                rule.timeZoneIdentifier = newIdentifier
            }
    }

    private var contentView: some View {
        List {
            ForEach(filteredIdentifiers, id: \.self) { identifier in
                let isSelected = timeZoneIdentifer == identifier
                Button {
                    timeZoneIdentifer = identifier
                    dismiss()
                } label: {
                    HStack {
                        Text(identifier)
                            .foregroundColor(style.labelPrimaryColor)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .font(.body)
            }
        }
    }
}

extension TimeZoneView {
    struct Style {
        var labelPrimaryColor: Color = .init(.label)
    }

    func style(_ style: Style) -> Self {
        var s = self
        s.style = style
        return s
    }
}
