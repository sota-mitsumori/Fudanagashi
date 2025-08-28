import SwiftUI

struct DeveloperView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    developersSection
                    artworkSection
                    contactSection
                }
                .padding()
            }
            .navigationBarTitle("開発者とクレジット", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .background(
                colorScheme == .dark ? Color.black.opacity(0.8) : Color(UIColor.systemGroupedBackground)
            )
        }
    }
    
    private var headerSection: some View {
        Text("デベロッパーとクレジット")
            .font(.title)
            .fontWeight(.bold)
            .padding(.bottom, 8)
    }
    
    private var developersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("開発者")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Text("三森颯太, 大戸暢丈")
                .font(.headline)
                .padding(.leading)
            Text("2024-2025")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var artworkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "photo.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("かるた取り札画像")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Text("かるた取り札画像は@momokohanakoさんのものを使用しています。")
                .font(.callout)
                .padding(.leading)
            
            Link(destination: URL(string: "https://x.com/momokohanako/status/1291379443626176514")!) {
                HStack {
                    Text("オリジナル画像のページを開く")
                    Image(systemName: "arrow.up.right.square")
                }
                .font(.callout)
                .foregroundColor(.blue)
            }
            .padding(.leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                Text("連絡先と公式HP")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.secondary)
                Text("メール:")
                    .fontWeight(.medium)
                Link("sota.mitsumori@gmail.com", destination: URL(string: "mailto:sota.mitsumori@gmail.com")!)
                    .foregroundColor(.blue)
            }
            .padding(.leading)
            
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.secondary)
                Text("ホームページ:")
                    .fontWeight(.medium)
                Link("公式サイト", destination: URL(string: "https://sota-mitsumori.github.io/Karuta-Fudanagashi/")!)
                    .foregroundColor(.blue)
            }
            .padding(.leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct DeveloperView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeveloperView()
        }
    }
}
