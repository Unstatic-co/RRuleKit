//
//  ContentView.swift
//  RRuleKitExample
//
//  Created by Thanh Duy Truong on 29/11/2022.
//

import EventKit
import RRuleKit
import RRuleKitUI
import SwiftUI

struct ContentView: View {
    @State private var isShowTimeTriggerSetupView = false
    @State private var rrule: RecurrenceRule = .init(
        recurrenceWith: .daily,
        end: nil
    )!

    var body: some View {
        ZStack {
            Spacer()
                .sheet(isPresented: $isShowTimeTriggerSetupView) {
                    RuleSetupView(rule: $rrule)
                        .defaultRules([
                            .everyDay,
                            .everyWeekDay,
                            .everyWeekend,
                            .everyHour,
                            .every15Mins,
                        ])
                        .title("Setup rule")
                        .style(RuleSetupView.Style(
                            accentColor: .red.opacity(0.7),
                            labelPrimaryColor: .black.opacity(0.9),
                            labelSecondaryColor: .gray,
                            systemBackgroundSecondaryColor: .gray
                        ))
                }

            VStack {
                Button {
                    isShowTimeTriggerSetupView.toggle()
                } label: {
                    Text("Setup rule")
                }

                if let rrule {
                    Text(RuleParser().fullRule(from: rrule))
                        .padding(16)
                }
            }
            .multilineTextAlignment(.center)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
