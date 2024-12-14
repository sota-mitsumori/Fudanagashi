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
                    Text("これまでの総プレイ回数: \(viewModel.pastResults.count)")
//                        .font(.headline)
//                        .padding(.top)
                    List(viewModel.pastResults.sorted(by: { $0.date > $1.date })) { result in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("日付: \(result.date, formatter: dateFormatter)")
                                    .font(.headline)
                                Text("記録: \(formattedTime(result.elapsedTime))")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                    .navigationBarTitle("過去のゲーム結果", displayMode: .large)
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
        let seconds = Int(interval)
        let fractions = Int((interval - Double(Int(interval))) * 100)
        return String(format: "%d.%02d seconds", seconds, fractions)
    }
}

struct PastGamesView_Previews: PreviewProvider {
    static var previews: some View {
        PastGamesView(viewModel: CardGameViewModel())
    }
}
