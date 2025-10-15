// PastGamesView.swift

import SwiftUI

struct PastGamesView: View {
    @ObservedObject var viewModel: CardGameViewModel
    @State private var isShowingAlert: Bool = false

    var body: some View {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.pastResults.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "gamecontroller")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                                
                                Text("まだゲームをプレイしていません")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            .padding(.top, 60)
                        } else {
                            // Stats Header Card
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("総プレイ回数")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .textCase(.uppercase)
                                            .tracking(0.5)
                                        
                                        Text("\(viewModel.pastResults.count)")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("ベストスコア")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .textCase(.uppercase)
                                            .tracking(0.5)
                                        
                                        if let bestResult = viewModel.pastResults.min(by: { $0.elapsedTime < $1.elapsedTime }) {
                                            Text(formattedTime(bestResult.elapsedTime) + "s")
                                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                                
                                Divider()
                                    .background(Color.secondary.opacity(0.3))
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.blue)
                                    Text("過去のゲーム記録")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                            
                            // Game Results List
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.pastResults.sorted(by: { $0.date > $1.date })) { result in
                                    GameResultCard(result: result)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
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
        return String(format: "%d.%02d", seconds, fractions)
    }
}

// MARK: - GameResultCard Component
struct GameResultCard: View {
    let result: GameResult
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func formattedTime(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        let fractions = Int((interval - Double(Int(interval))) * 100)
        return String(format: "%d.%02d", seconds, fractions)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Time icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.cyan, .green]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("記録")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Spacer()
                    
                    Text(formattedTime(result.elapsedTime) + "s")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(result.date, formatter: dateFormatter)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct PastGamesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CardGameViewModel()
        // Add some dummy data for preview
        viewModel.pastResults = [
            GameResult(date: Date().addingTimeInterval(-1000), elapsedTime: 123.45),
            GameResult(date: Date(), elapsedTime: 110.99)
        ]
        return PastGamesView(viewModel: viewModel)
    }
}
