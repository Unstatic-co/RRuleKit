//
//  NumberTextField.swift
//
//
//  Created by Thanh Duy Truong on 06/12/2022.
//

import SwiftUI

struct NumberTextField: View {
    private let title: String
    @Binding private var intValue: Int

    @State private var text: String

    init(_ title: String = "", value: Binding<Int>) {
        self.title = title
        _intValue = value
        text = "\(value.wrappedValue)"
    }

    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .onChange(of: text) { newText in
                let trimmedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                if let value = Int(trimmedText), value > 0 {
                    intValue = value
                } else {
                    if !trimmedText.isEmpty {
                        text = "\(intValue)"
                    }
                }
            }
    }
}
