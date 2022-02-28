import SwiftUI

struct ContentView: View {
    var body: some View {
        CovidSummaryView(summaryVM: SummaryViewModel())
            .frame(minWidth: 240, idealWidth: 320, maxWidth: .infinity, minHeight: 120, idealHeight: 360, maxHeight: .infinity)
            .padding([.trailing, .bottom, .leading])
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
