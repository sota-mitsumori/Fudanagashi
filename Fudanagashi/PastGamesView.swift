// PastGamesView.swift

import SwiftUI

struct PastGamesView: View {
    @ObservedObject var viewModel: CardGameViewModel
    @State private var isShowingAlert: Bool = false


    var body: some View {
        NavigationView {
            VStack {
                if viewModel.pastResults.isEmpty {
                    Text("表示する過去のゲームがありません")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Text("Total Games Played: \(viewModel.pastResults.count)")
//                        .font(.headline)
//                        .padding(.top)
                    List(viewModel.pastResults.sorted(by: { $0.date > $1.date })) { result in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Date: \(result.date, formatter: dateFormatter)")
                                    .font(.headline)
                                Text("Time: \(formattedTime(result.elapsedTime))")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                    .navigationBarTitle("Past Games", displayMode: .large)
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.isShowingAlert = true
                        }) {
                            Image(systemName: "trash")
                        }
                        .disabled(viewModel.pastResults.isEmpty)
                        .alert(isPresented: $isShowingAlert) {
                            Alert(
                                title: Text("記録リセット"),
                                message: Text("スコアをリセットしますか？"),
                                primaryButton: .destructive(Text("リセット"), action: {

                                }),
                                secondaryButton: .cancel(Text("キャンセル"))
                            )
                        }
                    )
                }
            }
        }
    }

    // DateFormatter for displaying the date
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    // Helper function to format TimeInterval
    private func formattedTime(_ interval: TimeInterval) -> String {
        let seconds = Int(interval) % 60
        let fractions = Int((interval - Double(Int(interval))) * 100)
        return String(format: "%d.%02d seconds", seconds, fractions)
    }
}

struct PastGamesView_Previews: PreviewProvider {
    static var previews: some View {
        PastGamesView(viewModel: CardGameViewModel())
    }
}
