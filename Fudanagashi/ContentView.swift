import SwiftUI

//make sure to push to GitHub when new archive of new version is ready.

struct ContentView: View {
    @ObservedObject var viewModel = CardGameViewModel()
    @State private var showSettings = false
    @State private var showAbout = false
    
    var body: some View {
        Group {
            if viewModel.startTime == nil || viewModel.endTime != nil {
                TabView {
                    NavigationView {
                        CardGameView(viewModel: viewModel)
                            .navigationBarTitle("百人一首札流し", displayMode: .large)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        self.showAbout = true
                                    }) {
                                        Image(systemName: "questionmark.circle")
                                            .imageScale(.large)
                                    }
                                }
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: {
                                        self.showSettings = true
                                    }) {
                                        Image(systemName: "gearshape")
                                            .imageScale(.large)
                                    }
                                }
                                
                            }
                    }
                    .tabItem {
                        Image(systemName: "gamecontroller")
                        Text("ゲーム")
                    }
                    
                    NavigationView {
                        PastGamesView(viewModel: viewModel)
                    }
                    .tabItem {
                        Image(systemName: "clock")
                        Text("結果")
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(viewModel: viewModel)
                }
                .sheet(isPresented: $showAbout) {
                    AboutView()
                }
            } else {
                CardGameView(viewModel: viewModel)
            }
        }
    }
}
        
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

