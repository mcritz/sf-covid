//
//  CovidSummaryView.swift
//  SF Covid
//
//  Created by Critz, Michael on 2/14/22.
//

import SwiftUI

struct CovidSummaryView: View {
    @ObservedObject var summaryVM: SummaryViewModel
    @SceneStorage("ChartDays") private var days: Int = 60
    @State private var showOptions: Bool = false
    
    private func fontSize(for size: CGSize) -> CGFloat {
        if size.width > size.height {
            return size.height * 0.7
        } else {
            return size.width * 0.5
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(summaryVM.status == .ready ? "New Covid Cases" : summaryVM.status.description)
                        .font(.title2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.init("AccentContrastColor"))
                        .brightness(0.2)
                        .opacity(0.8)
                    Text(summaryVM.caseCount)
                        .font(.system(size: 144, weight: .light, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .foregroundColor(.init("AccentContrastColor"))
                        .brightness(0.25)
                        .opacity(0.9)
                    Text("7 Day Average: " + summaryVM.average)
                        .font(.callout)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(.init("AccentContrastColor"))
                        .brightness(0.4)
                    Text(summaryVM.lastUpdated)
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .textCase(.uppercase)
                        .foregroundColor(.init("AccentContrastColor"))
                        .brightness(0.2)
                        .opacity(0.8)
                }
            }
            .foregroundColor(.white)
            .task {
                do {
                    try await summaryVM.update(days, type: .covidHospitalizations)
                } catch {
                    print(error)
                }
            }
            #if !os(tvOS)
            .onTapGesture {
                showOptions = true
                Task {
                    do {
                        try await summaryVM.update(days, type: .covidHospitalizations)
                    } catch {
                        print(error)
                    }
                }
            }
            #endif
            #if os(watchOS)
            .sheet(isPresented: $showOptions) {
                showOptions = false
            } content: {
                VStack {
                    Picker("Days", selection: $summaryVM.days) {
                        ForEach([14, 30, 60, 365], id: \.self) { daysOption in
                            Text("\(daysOption)")
                                .tag(daysOption)
                        }
                    }
                    .pickerStyle(InlinePickerStyle())
                    .onChange(of: summaryVM.days) { newDays in
                        days = newDays
                    }
                    Button("Done") {
                        showOptions = false
                        Task {
                            try await summaryVM.update(days)
                        }
                    }
                }
            }
            #endif
        }
    }
}

struct CovidSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        CovidSummaryView(summaryVM: SummaryViewModel())
            .preferredColorScheme(.light)
            .frame(width: 800.0, height: nil)
        CovidSummaryView(summaryVM: SummaryViewModel())
            .preferredColorScheme(.dark)
            .frame(width: 250.0, height: 400.0)
    }
}
