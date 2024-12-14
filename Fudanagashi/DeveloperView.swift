import SwiftUI

struct DeveloperView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("""
                **デベロッパーとクレジット**
                
                <<開発者>>
                **三森颯太, 大戸暢丈**, 2024.
                
                <<かるた取り札画像>>
                http://100poem.web.fc2.com/
                                    
                <<連絡先と公式HP>>
                - **メール**: sota.mitsumori@gmail.com
                - **ホームページ**: https://sota-mitsumori.github.io/Karuta-Fudanagashi/
                """)
                .font(.body)
                .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("開発者とクレジット", displayMode: .inline)
            .navigationBarItems(trailing: Button("閉じる") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct DeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperView()
    }
}
