//
//  Toolbar.swift
//  SF Covid
//
//  Created by Michael Critz on 4/30/22.
//

import SwiftUI

struct Toolbar: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var summaryVM: SummaryViewModel
    private let sfCovidDataURL = URL(string: "https://sf.gov/data/covid-19-cases-and-deaths")!
    @SceneStorage("ChartDays") public var days: Int = 60
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    openURL(sfCovidDataURL) { accepted in
                        print("Tapped URL", accepted)
                    }
                }, label: {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "safari")
                        Text("SF Covid")
                    }
                })
                .padding(.vertical, 15)
                .padding(.leading, 10)
                Spacer()
                Picker("", selection: $days) {
                    Text("365")
                        .tag(365)
                    Text("60")
                        .tag(60)
                    Text("30")
                        .tag(30)
                    Text("14")
                        .tag(14)
                }
                .accentColor(Color("Secondary"))
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: days) { newValue in
                    Task {
                        try? await summaryVM.update(days)
                    }
                }
            }
            .tint(.accentColor)
        }
    }
}

struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        Toolbar()
    }
}
