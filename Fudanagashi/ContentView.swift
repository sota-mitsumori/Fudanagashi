import SwiftUI
import UIKit

//make sure to push to GitHub when new archive of new version is ready.

struct ContentView: View {
    @ObservedObject var viewModel = CardGameViewModel()
    @State private var showSettings = false
    @State private var showAbout = false
    
    // 1. Define the image sequence
    let backgroundImages = (1...100).map { "torifuda\($0)" }
    
    // 2. State variable for current image index
    @State private var currentImageIndex = 0
    @State private var previousImageIndex: Int
    @State private var nextImageIndex: Int

    // 3. Haptic Feedback Generator
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        
    // Initialize previous and next indices
    init() {
        let initialIndex = 0
        self._previousImageIndex = State(initialValue: (initialIndex - 1 + 100) % 100)
        self._nextImageIndex = State(initialValue: (initialIndex + 1) % 100)
        
        // Prepare the feedback generator
        feedbackGenerator.prepare()
    }
    
    var body: some View {
        Group {
            if viewModel.startTime == nil || viewModel.endTime != nil {
                TabView {
                    NavigationView {
                        GeometryReader { geometry in
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
                            if viewModel.showStartButton {
                                if viewModel.showEndButton{
                                     //End Screen Bacground Image
                                    Image("background_finish")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: geometry.size.width * 0.6)
                                        .position(x: geometry.size.width / 2, y: geometry.size.height / 3)
                                } else {
                                    // Layered Images
                                    // Previous Image
                                    Image(backgroundImages[previousImageIndex])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: geometry.size.width * 0.5)
                                        .position(x: geometry.size.width / 2 - 90, y: geometry.size.height / 3 + 0)
                                        .opacity(0.2)
                                        .shadow(radius: 5)
                                    
                                    // Next Image
                                    Image(backgroundImages[nextImageIndex])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: geometry.size.width * 0.5)
                                        .position(x: geometry.size.width / 2 + 90, y: geometry.size.height / 3 + 0)
                                        .opacity(0.2)
                                        .shadow(radius: 5)
                                    
                                    // Current Image
                                    Image(backgroundImages[currentImageIndex])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: geometry.size.width * 0.6)
                                        .position(x: geometry.size.width / 2, y: geometry.size.height / 3)
                                        .shadow(radius: 10)
                                        .transition(.scale)
                                        .animation(.easeInOut(duration: 0.5), value: currentImageIndex)
                                        .gesture(
                                            DragGesture()
                                                .onEnded { value in
                                                    if value.translation.width < -50 {
                                                        // Swipe Left
                                                        nextImage()
                                                    }
                                                    if value.translation.width > 50 {
                                                        // Swipe Right
                                                        previousImage()
                                                    }
                                                }
                                        )
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
        .onAppear {
            feedbackGenerator.prepare()
        }
    }
    
    // 5. Implement Navigation Functions
    func nextImage() {
        // Trigger haptic feedback
        feedbackGenerator.impactOccurred()
        
        currentImageIndex = (currentImageIndex + 1) % backgroundImages.count
        previousImageIndex = (currentImageIndex - 1 + backgroundImages.count) % backgroundImages.count
        nextImageIndex = (currentImageIndex + 1) % backgroundImages.count
    }
    
    func previousImage() {
        // Trigger haptic feedback
        feedbackGenerator.impactOccurred()
        
        currentImageIndex = (currentImageIndex - 1 + backgroundImages.count) % backgroundImages.count
        previousImageIndex = (currentImageIndex - 1 + backgroundImages.count) % backgroundImages.count
        nextImageIndex = (currentImageIndex + 1) % backgroundImages.count
    }
}
        
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
