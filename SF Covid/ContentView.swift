import Charts
import SwiftUI

struct ContentView: View {
    @ObservedObject private var summaryVM = SummaryViewModel()
    
    var body: some View {
        HStack {
            Spacer()
            CovidSummaryView(summaryVM: summaryVM)
                .padding([.trailing, .bottom, .leading])
        }
                .background {
                    Chart(data: summaryVM.chartValues)
                        .chartStyle(AreaChartStyle(fill:
                                                    LinearGradient(colors: [
                                                        Color.black.opacity(0.4),
                                                        Color.black.opacity(0.35),
                                                        Color.black.opacity(0.25),
                                                        Color.black.opacity(0.1)
                                                    ],
                                                   startPoint: .top,
                                                   endPoint: .bottom)
                                                  ))
                        .background {
                            LinearGradient(colors: [
                                                Color("AccentColor"),
                                                Color("Secondary")
                                            ],
                                           startPoint: .top,
                                           endPoint: .bottom)
                                .ignoresSafeArea()
                        }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
