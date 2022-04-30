import Charts
import SwiftUI

struct ContentView: View {
    @ObservedObject private var summaryVM = SummaryViewModel()
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
                Toolbar()
                    .environmentObject(summaryVM)
#endif // !watchOS
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
