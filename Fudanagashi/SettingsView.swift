import SwiftUI

struct SettingsView: View {
    @AppStorage("randomRotation") private var randomRotation: Bool = true
    @AppStorage("displayTimerLabel") private var displayTimerLabel: Bool = true
    @AppStorage("displayCardsLeftLabel") private var displayCardsLeftLabel: Bool = true
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CardGameViewModel
    @State private var isShowingAlert: Bool = false
    @State private var isShowingDev: Bool = false
    @State private var isSyncing: Bool = false
    @State private var didSync: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("札の表示")) {
                    Toggle("カードのランダム上下反転", isOn: $randomRotation)
                        .onChange(of: randomRotation) { _ in
                            viewModel.loadImages()
                        }
                }
                Section(header: Text("表示オプション")) {
                    Toggle("経過時間を表示", isOn: $displayTimerLabel)
                    Toggle("残り枚数を表示", isOn: $displayCardsLeftLabel)
                }

                Section(header: Text("データ同期")) {
                    Button(action: {
                        // Start syncing
                        isSyncing = true
                        didSync = false

                        viewModel.loadFromiCloud(completion: { 
                            // Completion handler
                            isSyncing = false
                            didSync = true
                            
                            // Reset the checkmark after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                didSync = false
                            }
                        })
                    }) {
                        HStack {
                            Text("他のApple端末とデータを同期")
                            Spacer()
                            if isSyncing {
                                ProgressView()
                            } else if didSync {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                        }
                    }
                    .disabled(isSyncing)
                }
                
                Section(header: Text("ゲームスコアリセット")) {
                    Button(action: {
                        self.isShowingAlert = true
                        
                    }) {
                        Text("ゲームスコアをリセット")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $isShowingAlert) {
                        Alert(
                            title: Text("記録リセット"),
                            message: Text("ゲームスコアをリセットしますか？"),
                            primaryButton: .destructive(Text("リセット"), action: {
                                viewModel.resetPastResults()
                            }),
                            secondaryButton: .cancel(Text("キャンセル"))
                        )
                    }
                }
                
                Section(header: Text("情報")) {  // Updated header for clarity
                    Button(action: {
                        self.isShowingDev = true
                    }) {
                        HStack {
                            Text("開発者とクレジット")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("バージョン")) {
                    Text("Version 2.2.2 (2026.01.06)")
                }
            }
            .navigationBarTitle("設定", displayMode: .inline)
            .navigationBarItems(trailing: Button("終了") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $isShowingDev) {  // Present the sheet
                DeveloperView()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: CardGameViewModel())
    }
}
