import SwiftUI

struct SettingsView: View {
    @AppStorage("randomRotation") private var randomRotation: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CardGameViewModel
    @State private var isShowingAlert: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("札の表示")) {
                    Toggle("カードのランダム上下反転", isOn: $randomRotation)
                        .onChange(of: randomRotation) { _ in
                                            viewModel.loadImages()
                    }
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
                Section(header: Text("バージョン")) {
                    Text("Version 2.0.0-beta (2024.XX.XX)")
                }
            }
            .navigationBarTitle("設定", displayMode: .inline)
            .navigationBarItems(trailing: Button("終了") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: CardGameViewModel())
    }
}
