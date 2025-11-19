//
//  DateSuggestionView.swift
//  SuggestedDateUI
//
//  Created by David Murphy on 15/07/2025.
//

import SuggestedDate
import SwiftUI

public struct DateSuggestionView: View {
    @Binding var selectedDate: Date

    public init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }

    @State private var now = Date()
    @State private var showingCustomPicker = false

    public var body: some View {
        let suggestedDates = SuggestedDate.defaultSuggestions.map { option in
            (option: option, date: option.date(onOrAfter: now))
        }

        if showingCustomPicker {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.top, 8)
        } else {
            VStack(alignment: .leading) {
                Text("Suggestions").font(.caption)
                ForEach(suggestedDates, id: \.option.id) { suggestion in
                    Button(action: {
                        selectedDate = suggestion.date
                        showingCustomPicker = false
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            VStack(alignment: .leading) {
                                Text(String(describing: suggestion.option))
                                Text(
                                    suggestion.date
                                        .formatted(date: .numeric, time: .omitted)
                                ).font(.caption)
                            }.fixedSize()
                        }
                    }.buttonStyle(.borderless)
                }
                Divider()
                Button(action: {
                    showingCustomPicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "calendar")
                        VStack(alignment: .leading) {
                            Text("Custom...")
                            Text("Use the calendar to pick a date"
                            )
                            .font(.caption)
                        }.fixedSize()
                    }
                    
                }.buttonStyle(.borderless)
                
            }
            .onAppear {
                now = Date()
            }}
    }
}

#Preview {
    @Previewable @State var selectedDate: Date = Date()
    DateSuggestionView(selectedDate: $selectedDate)
        .scenePadding()
}
