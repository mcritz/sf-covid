import Charts
import SwiftUI

struct CovidChartView: View {
    @EnvironmentObject var summaryVM: SummaryViewModel
    var body: some View {
        ZStack {
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
            Chart(data: summaryVM.chartAvaerageValues)
                .chartStyle(LineChartStyle(.line,
                                           lineColor: Color("AccentContrastColor"),
                                           lineWidth: 3.0))
                .opacity(0.5)
                .shadow(radius: 3.0)
        }
        .opacity(summaryVM.status == .ready ? 1.0 : 0.0)
        .scaleEffect(x: 1.0, y: summaryVM.status == .ready ? 1.0 : 0.0, anchor: .bottom)
    }
}

struct CovidChartView_Previews: PreviewProvider {
    static var previews: some View {
        CovidChartView()
            .environmentObject(SummaryViewModel())
    }
}
