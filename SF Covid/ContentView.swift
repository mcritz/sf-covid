import Charts
import SwiftUI

struct ContentView: View {
    @ObservedObject private var summaryVM = SummaryViewModel()
    @Environment(\.openURL) private var openURL
    @SceneStorage("ChartDays") private var days: Int = 60
    private let sfCovidDataURL = URL(string: "https://sf.gov/data/covid-19-cases-and-deaths")!

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
                    VStack(spacing: 4) {
                        CovidChartView()
                            .environmentObject(summaryVM)
#if !os(watchOS)
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 60)
#endif
                    }
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
                                .onChange(of: days) { value in
                                    Task {
                                        try await summaryVM.update(value)
                                    }
                                }
                            }
                            .tint(.accentColor)
                        }
                        .ignoresSafeArea(.all, edges: [.leading, .top, .trailing])
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
