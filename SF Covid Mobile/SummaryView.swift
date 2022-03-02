//
//  SummaryView.swift
//  SF Covid Mobile
//
//  Created by Michael Critz on 2/28/22.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var summaryViewModel: SummaryViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("New Cases")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(summaryViewModel.caseCount)
                .font(.title)
                .foregroundColor(.primary)
            Text("Updated")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(summaryViewModel.lastUpdated)
                .foregroundColor(.primary)
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static let summaryViewModel = SummaryViewModel()
    static var previews: some View {
        SummaryView()
            .environmentObject(SummaryView_Previews.summaryViewModel)
    }
}
