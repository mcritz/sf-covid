import SwiftUI

struct Toolbar: View {
    @Environment(\.openURL) private var openURL
    @ObservedObject private var summaryVM: SummaryViewModel
    private let sfCovidDataURL = URL(string: Constants.sfGovSite.rawValue)!
    @SceneStorage("ChartDays") private var selectedDays: Int = 60
    
    init(_ svm: SummaryViewModel) {
        self.summaryVM = svm
        self.selectedDays = svm.days
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                #if !os(tvOS)
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
                .padding(.horizontal, 10)
                #endif
                Picker("", selection: $selectedDays) {
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
                .frame(idealWidth: 256, maxWidth: 320)
                .padding()
                .onChange(of: selectedDays) { newValue in
                    Task {
                        try? await summaryVM.update(newValue, type: .covidHospitalizations)
                    }
                }
            }
            .tint(.accentColor)
        }
    }
}

struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        Toolbar(SummaryViewModel())
    }
}
