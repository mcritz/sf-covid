//
//  CovidSummaryView.swift
//  SF Covid
//
//  Created by Critz, Michael on 2/14/22.
//

import SwiftUI

struct CovidSummaryView: View {
    @ObservedObject var summaryVM: SummaryViewModel
    
    private func fontSize(for size: CGSize) -> CGFloat {
        if size.width > size.height {
            return size.height * 0.7
        } else {
            return size.width * 0.5
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                Text("New Covid Cases")
                    .font(.title2)
                    .foregroundColor(.init("AccentContrastColor"))
                    .brightness(0.2)
                    .opacity(0.8)
                Text(summaryVM.caseCount)
                    .font(.system(size: 1234, weight: .light, design: .rounded))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                    .foregroundColor(.init("AccentContrastColor"))
                    .brightness(0.25)
                    .opacity(0.9)
                Text("as of " + summaryVM.lastUpdated)
                    .font(.title3)
                    .textCase(.uppercase)
                    .foregroundColor(.init("AccentContrastColor"))
                    .brightness(0.2)
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .task {
                do {
                    try await summaryVM.update()
                } catch {
                    print(error)
                }
            }
            .onTapGesture {
                Task {
                    do {
                        try await summaryVM.update()
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .frame(width: nil)
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
