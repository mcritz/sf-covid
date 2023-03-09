import Charts
import SwiftUI

struct ContentView: View {
    @StateObject private var summaryVM = SummaryViewModel()
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Spacer()
                CovidSummaryView(summaryVM: summaryVM)
                    .padding()
            }
        }
        .background {
            ZStack(alignment: .bottomLeading) {
                CovidChartView()
                    .environmentObject(summaryVM)
                    .padding(.top, 20)
                    .ignoresSafeArea(.container, edges: [.leading, .trailing, .bottom])
                    .background {
                        LinearGradient(colors: [
                            Color("AccentColor"),
                            Color("Secondary")
                        ],
                                       startPoint: .top,
                                       endPoint: .bottom)
                        .ignoresSafeArea()
                    }
#if !os(watchOS)
                Toolbar(summaryVM)
#endif
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
