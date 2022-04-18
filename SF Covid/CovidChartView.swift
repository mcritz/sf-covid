import Charts
import SwiftUI

struct CovidChartView: View {
    @EnvironmentObject var summaryVM: SummaryViewModel
    var body: some View {
        Chart(data: summaryVM.chartValues)
            .chartStyle(AreaChartStyle(.line, fill:
                                    LinearGradient(colors: [
                                        Color.black.opacity(0.4),
                                        Color.black.opacity(0.35),
                                        Color.black.opacity(0.25),
                                        Color.black.opacity(0.1)
                                    ],
                                   startPoint: .top,
                                   endPoint: .bottom)
                                  ))
    }
}

struct CovidChartView_Previews: PreviewProvider {
    static var previews: some View {
        CovidChartView()
            .environmentObject(SummaryViewModel())
    }
}
