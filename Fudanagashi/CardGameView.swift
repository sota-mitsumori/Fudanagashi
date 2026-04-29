import SwiftUI
import Combine

class CardGameViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentCardIndex: Int = 0
    @Published var cardOffset: CGSize = .zero
    @Published var cardRotation: Double = 0
    @Published var startTime: Date?
    @Published var endTime: Date?
    
    @Published var previousCard: Card?
    @Published var previousCardOffset: CGSize = .zero
    @Published var previousCardRotation: Double = 0
    
    @Published var timerLabel: String = ""
    @Published var cardsLeftLabel: String = ""
    @Published var message: String = ""
    
    @Published var showStartButton: Bool = true
    @Published var showEndButton: Bool = false
    @Published var showTimerLabel: Bool = false
    @Published var showCardsLeftLabel: Bool = false
    @Published var showMessageLabel: Bool = false
    
    // Synced Properties
    @Published var pastResults: [GameResult] = []
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0

    // Device-Local Settings
    @AppStorage("randomRotation") private var randomRotation: Bool = true
    @AppStorage("showPreviousKimarijiOnNextCard") private var showPreviousKimarijiOnNextCard: Bool = true

    private let iCloudStore = NSUbiquitousKeyValueStore.default

    // iCloud Keys
    private let pastResultsKey = "pastResults_v2"
    private let currentStreakKey = "currentStreak"
    private let bestStreakKey = "bestStreak"

    var gameTimer: AnyCancellable?
    
    var bestScore: TimeInterval? {
        return pastResults.min(by: { $0.elapsedTime < $1.elapsedTime })?.elapsedTime
    }
    
    init() {
        migrateDataIfNeeded() // Run migration first
        loadFromiCloud(completion: {})      // Then load data
        loadImages()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ubiquitousKeyValueStoreDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: iCloudStore
        )
    }
    
    private func migrateDataIfNeeded() {
        let userDefaults = UserDefaults.standard
        let oldPastResultsKey = "pastResults"

        // Check if there is old local data to migrate.
        guard let localResultsData = userDefaults.data(forKey: oldPastResultsKey) else {
            // No old data found, no migration needed for this device.
            return
        }

        print("Starting data migration from UserDefaults to iCloud...")

        // 1. Read Local Data
        let localPastResults = (try? JSONDecoder().decode([GameResult].self, from: localResultsData)) ?? []
        let localCurrentStreak = userDefaults.integer(forKey: "currentStreak")
        let localBestStreak = userDefaults.integer(forKey: "bestStreak")

        // 2. Read iCloud Data
        var icloudPastResults: [GameResult] = []
        if let icloudResultsData = iCloudStore.data(forKey: pastResultsKey) {
            icloudPastResults = (try? JSONDecoder().decode([GameResult].self, from: icloudResultsData)) ?? []
        }
        let icloudCurrentStreak = Int(iCloudStore.longLong(forKey: currentStreakKey))
        let icloudBestStreak = Int(iCloudStore.longLong(forKey: bestStreakKey))

        // 3. Merge Data
        let combinedResults = Set(localPastResults + icloudPastResults)
        let mergedPastResults = Array(combinedResults)

        let mergedCurrentStreak = max(localCurrentStreak, icloudCurrentStreak)
        let mergedBestStreak = max(localBestStreak, icloudBestStreak)

        // 4. Save Merged Data to iCloud
        if let encodedResults = try? JSONEncoder().encode(mergedPastResults) {
            iCloudStore.set(encodedResults, forKey: pastResultsKey)
        }
        iCloudStore.set(Int64(mergedCurrentStreak), forKey: currentStreakKey)
        iCloudStore.set(Int64(mergedBestStreak), forKey: bestStreakKey)
        iCloudStore.synchronize()

        print("Successfully merged data. Cleaning up local data...")

        // 5. Clean Up Local Data to prevent re-migration
        userDefaults.removeObject(forKey: oldPastResultsKey)
        userDefaults.removeObject(forKey: "currentStreak")
        userDefaults.removeObject(forKey: "bestStreak")
        userDefaults.synchronize()
        
        print("Migration complete.")
    }
    
    @objc func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        loadFromiCloud(completion: {})
    }
    
    func loadFromiCloud(completion: @escaping () -> Void) {
        iCloudStore.synchronize()

        // iCloudからデータを取得
        var icloudPastResults: [GameResult] = []
        if let icloudResultsData = iCloudStore.data(forKey: pastResultsKey) {
            icloudPastResults = (try? JSONDecoder().decode([GameResult].self, from: icloudResultsData)) ?? []
        }
        let icloudCurrentStreak = Int(iCloudStore.longLong(forKey: currentStreakKey))
        let icloudBestStreak = Int(iCloudStore.longLong(forKey: bestStreakKey))

        DispatchQueue.main.async {
            // ローカルのデータとiCloudのデータをマージする
            // (読み込み時にもマージを行い、不意なデータ損失を防ぐ)
            let combinedResults = Set(self.pastResults + icloudPastResults)
            let mergedPastResults = Array(combinedResults)
            
            // データが空でない方を優先する
            if !mergedPastResults.isEmpty {
                self.pastResults = mergedPastResults
            }

            self.currentStreak = max(self.currentStreak, icloudCurrentStreak)
            self.bestStreak = max(self.bestStreak, icloudBestStreak)
            
            // 完了を通知
            completion()
        }
    }

    func saveToiCloud() {
        // 1. iCloudから現在のデータを読み込む
        var icloudPastResults: [GameResult] = []
        if let icloudResultsData = iCloudStore.data(forKey: pastResultsKey) {
            icloudPastResults = (try? JSONDecoder().decode([GameResult].self, from: icloudResultsData)) ?? []
        }
        let icloudCurrentStreak = Int(iCloudStore.longLong(forKey: currentStreakKey))
        let icloudBestStreak = Int(iCloudStore.longLong(forKey: bestStreakKey))

        // 2. ローカルのデータとiCloudのデータをマージする
        let combinedResults = Set(self.pastResults + icloudPastResults)
        let mergedPastResults = Array(combinedResults)
        let mergedCurrentStreak = max(self.currentStreak, icloudCurrentStreak)
        let mergedBestStreak = max(self.bestStreak, icloudBestStreak)

        // 3. マージしたデータをiCloudに保存する
        if let encoded = try? JSONEncoder().encode(mergedPastResults) {
            iCloudStore.set(encoded, forKey: pastResultsKey)
        }
        iCloudStore.set(Int64(mergedCurrentStreak), forKey: currentStreakKey)
        iCloudStore.set(Int64(mergedBestStreak), forKey: bestStreakKey)
        iCloudStore.synchronize()

        // 4. マージしたデータをローカルのViewModelにも反映させる
        DispatchQueue.main.async {
            self.pastResults = mergedPastResults
            self.currentStreak = mergedCurrentStreak
            self.bestStreak = mergedBestStreak
        }
    }
    
    func cardImage(at index: Int) -> Image? {
        if index < cards.count {
            let card = cards[index]
            var uiImage = card.image
            if card.isRotated {
                if let cgImage = uiImage.cgImage {
                    uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
                }
            }
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
    
    func image(for card: Card) -> Image {
        var uiImage = card.image
        if card.isRotated {
            if let cgImage = uiImage.cgImage {
                uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
            }
        }
        return Image(uiImage: uiImage)
    }
    
    var currentCardImage: Image? {
        if currentCardIndex < cards.count {
            let card = cards[currentCardIndex]
            var uiImage = card.image
            if card.isRotated {
                if let cgImage = uiImage.cgImage {
                    uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
                }
            }
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }

    var nextCardImage: Image? {
        let nextIndex = currentCardIndex + 1
        if nextIndex < cards.count {
            let card = cards[nextIndex]
            var uiImage = card.image
            if card.isRotated {
                if let cgImage = uiImage.cgImage {
                    uiImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: .down)
                }
            }
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
    
    func loadImages() {
        var loadedCards: [Card] = []
        for i in 1...100 {
            let imageName = "torifuda_F_\(i)"
            if let uiImage = UIImage(named: imageName) {
                let isRotated = randomRotation ? Bool.random() : false
                let card = Card(image: uiImage, isRotated: isRotated, poemNumber: i)
                loadedCards.append(card)
            } else {
                print("Image \(imageName) not found")
            }
        }
        cards = loadedCards.shuffled()
    }
    
    func resetPastResults() {
        pastResults.removeAll()
        currentStreak = 0
        bestStreak = 0
        saveToiCloud()
    }
    
    func startButtonTapped() {
        startTime = Date()
        currentCardIndex = 0
        endTime = nil
        showTimerLabel = true
        showStartButton = false
        showMessageLabel = false
        showCardsLeftLabel = true
        showEndButton = false
        cards.shuffle()
        showCurrentCard()
        startTimer()
    }
    
    func endButtonTapped() {
        startTime = nil
        showStartButton = true
        showMessageLabel = false
        showEndButton = false
    }
    
    func showCurrentCard() {
        if currentCardIndex < cards.count {
            let cardsLeft = cards.count - currentCardIndex
            let format = NSLocalizedString("cards_left_format", comment: "Format string for cards left")
            cardsLeftLabel = String.localizedStringWithFormat(format, cardsLeft)
        } else {
            endTime = Date()
            showFinishScreen()
        }
    }
    
    func showFinishScreen() {
        if let startTime = startTime, let endTime = endTime {
            let elapsedTime = endTime.timeIntervalSince(startTime)
            
            let newResult = GameResult(date: Date(), elapsedTime: elapsedTime)
            pastResults.append(newResult)
            
            let isNewBest = bestScore == nil || bestScore == 0.00 || elapsedTime < bestScore!
            
            if isNewBest {
                currentStreak += 1
                if currentStreak > bestStreak {
                    bestStreak = currentStreak
                }
            } else {
                currentStreak = 0
            }
            
            saveToiCloud()
            
            let timeString = String(format: "%.2f", elapsedTime)
            let finalCardKimarijiLine = finalCardKimarijiLine
            
            if isNewBest {
                message = String(localized: "game_clear_message_best", defaultValue: """
                \(String(localized: "game_clear_title"))
                \(String(format: String(localized: "time_elapsed"), timeString))
                \(String(localized: "best_score"))
                \(finalCardKimarijiLine)
                """)
            } else {
                message = String(localized: "game_clear_message_try_again", defaultValue: """
                \(String(localized: "game_clear_title"))
                \(String(format: String(localized: "time_elapsed"), timeString))
                \(String(localized: "try_again"))
                \(finalCardKimarijiLine)
                """)
            }
            showMessageLabel = true
            showStartButton = true
            showTimerLabel = false
            showCardsLeftLabel = false
            showEndButton = true
            stopTimer()
        }
    }
    
    func handleSwipe() {
        if startTime != nil && endTime == nil {
            withAnimation(nil) {
                currentCardIndex += 1
            }
            showCurrentCard()
        }
    }
    
    func handleTap() {
        if startTime != nil && endTime == nil {
            currentCardIndex += 1
            showCurrentCard()
        }
    }
    
    func startTimer() {
        stopTimer()
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateTimerLabel()
            }
    }
    
    func stopTimer() {
        gameTimer?.cancel()
        gameTimer = nil
    }
    
    func updateTimerLabel() {
        if let startTime = startTime {
            let elapsedTime = Date().timeIntervalSince(startTime)
            let format = NSLocalizedString("elapsed_time_format", comment: "Format string for elapsed time")
            timerLabel = String.localizedStringWithFormat(format, elapsedTime)
        }
    }

    private var finalCardKimarijiLine: String {
        guard showPreviousKimarijiOnNextCard,
              currentCardIndex > 0,
              let finalCard = cards[safe: currentCardIndex - 1],
              let kimariji = KimarijiStore.shared.kimariji(for: finalCard.poemNumber) else {
            return ""
        }

        return String(format: String(localized: "final_card_kimariji_format"), kimariji)
    }
}

struct CardGameView: View {
    @ObservedObject var viewModel: CardGameViewModel
    @State private var showSettings = false

    @AppStorage("displayTimerLabel") private var displayTimerLabel: Bool = true
    @AppStorage("displayCardsLeftLabel") private var displayCardsLeftLabel: Bool = true
    @AppStorage("showPreviousKimarijiOnNextCard") private var showPreviousKimarijiOnNextCard: Bool = true

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            ZStack {
                VStack {
                    if !viewModel.showStartButton {
                        singleCardView
                            .padding(.top, geometry.size.height * 0.15)
                        Spacer()
                    }
                }
                
                if viewModel.showTimerLabel || viewModel.showCardsLeftLabel {
                    VStack {
                        HStack {
                            if viewModel.showCardsLeftLabel {
                                Text(displayCardsLeftLabel ? viewModel.cardsLeftLabel : NSLocalizedString("残り: --枚", comment: "Cards left hidden"))
                                    .font(.system(size: 24))
                                    .padding(.leading, 20)
                            }
                            Spacer()
                            if viewModel.showTimerLabel {
                                Text(displayTimerLabel ? viewModel.timerLabel : NSLocalizedString("経過時間: --秒", comment: "Time elapsed hidden"))
                                    .font(.system(size: 24))
                                    .padding(.trailing, 20)
                            }
                        }
                        Spacer()
                    }
                }
                
                if viewModel.showMessageLabel {
                    Text(viewModel.message)
                        .font(.system(size: min(screenWidth, screenHeight) * 0.05))
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .padding(.bottom, screenHeight * 0.1)
                        .foregroundColor(.primary)
                }
                
                if viewModel.showStartButton {
                    VStack {
                        Spacer()
                        if let bestScore = viewModel.bestScore {
                            Text("ベストスコア: \(String(format: "%.2f", bestScore))秒")
                                .font(.system(size: min(screenWidth, screenHeight) * 0.06))
                                .fontWeight(.bold)
                                .padding(.bottom, geometry.size.height * 0.01)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("さあゲームに挑戦だ！")
                                .font(.system(size: min(screenWidth, screenHeight) * 0.06))
                                .fontWeight(.bold)
                                .padding(.bottom, geometry.size.height * 0.01)
                        }
                        Button(action: {
                            viewModel.startButtonTapped()
                        }) {
                            Text(viewModel.startTime == nil ? "スタート" : "もう一回")
                                .font(.system(size: min(screenWidth, screenHeight) * 0.05))
                                .frame(width: screenWidth * 0.5, height: screenHeight * 0.07)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.primary, lineWidth: 2)
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, geometry.size.height * 0.14)
                    }
                }
                
                if viewModel.showEndButton {
                    VStack {
                        Spacer()
                        Button(action: {
                            viewModel.endButtonTapped()
                        }) {
                            Text("ホームへ")
                                .font(.system(size: min(screenWidth, screenHeight) * 0.05))
                                .frame(width: screenWidth * 0.5, height: screenHeight * 0.07)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(.primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.primary, lineWidth: 2)
                                )
                        }
                        .padding(.bottom, geometry.size.height * 0.01)
                    }
                }
                
            }
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.cardOffset = value.translation
                let angle = atan2(value.translation.height, value.translation.width)
                viewModel.cardRotation = Double(angle * 180 / .pi) / 15
            }
            .onEnded { value in
                let dragDistance = hypot(value.translation.width, value.translation.height)
                if dragDistance > 50 {
                    viewModel.previousCard = viewModel.cards[ viewModel.currentCardIndex]
                    viewModel.previousCardOffset = viewModel.cardOffset
                    viewModel.previousCardRotation = viewModel.cardRotation
                    withAnimation(.easeOut(duration: 0.3)) {
                        let multiplier: CGFloat = 3.0
                        viewModel.previousCardOffset = CGSize(
                            width: value.translation.width * multiplier,
                            height: value.translation.height * multiplier
                        )
                    }
                    
                    viewModel.handleSwipe()
                    
                    viewModel.cardOffset = .zero
                    viewModel.cardRotation = 0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        viewModel.previousCard = nil
                        viewModel.previousCardOffset = .zero
                        viewModel.previousCardRotation = 0
                    }
                } else {
                    withAnimation(.spring()) {
                        viewModel.cardOffset = .zero
                        viewModel.cardRotation = 0
                    }
                }
            }
    }
    
    var singleCardView: some View {
        ZStack {
            if let nextCard = viewModel.cards[safe: viewModel.currentCardIndex + 1] {
                ZStack(alignment: .topTrailing) {
                    viewModel.image(for: nextCard)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom)
                        .animation(nil, value: viewModel.currentCardIndex)

                    if let previousKimarijiForNextCard {
                        Text(previousKimarijiForNextCard)
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 2)
                            .padding(.top, -25)
                            .padding(.trailing, 40)
                    }
                }
            }
            if let currentCard = viewModel.cards[safe: viewModel.currentCardIndex] {
                ZStack(alignment: .topTrailing) {
                    viewModel.image(for: currentCard)
                        .resizable()
                        .scaledToFit()
                        .offset(viewModel.cardOffset)
                        .rotationEffect(.degrees(viewModel.cardRotation))
                        .gesture(dragGesture)
                        .padding()
                        .animation(nil, value: viewModel.currentCardIndex)

                    if viewModel.cards[safe: viewModel.currentCardIndex + 1] == nil,
                       let previousKimarijiForCurrentCard {
                        Text(previousKimarijiForCurrentCard)
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 2)
                            .padding(.top, -25)
                            .padding(.trailing, 30)
                    }
                }
                
            }
            
            if let previousCard = viewModel.previousCard {
                viewModel.image(for: previousCard)
                    .resizable()
                    .scaledToFit()
                    .offset(viewModel.previousCardOffset)
                    .rotationEffect(.degrees(viewModel.previousCardRotation))
                    .padding()
                    .animation(nil, value: viewModel.previousCardOffset)
            
            }
        }
        .animation(nil, value: viewModel.currentCardIndex)
    }

    private var previousKimarijiForNextCard: String? {
        guard showPreviousKimarijiOnNextCard,
              let previousCard = viewModel.cards[safe: viewModel.currentCardIndex - 1] else {
            return nil
        }

        return KimarijiStore.shared.kimariji(for: previousCard.poemNumber)
    }

    private var previousKimarijiForCurrentCard: String? {
        guard showPreviousKimarijiOnNextCard,
              let previousCard = viewModel.cards[safe: viewModel.currentCardIndex - 1] else {
            return nil
        }

        return KimarijiStore.shared.kimariji(for: previousCard.poemNumber)
    }
}

struct Card {
    let image: UIImage
    let isRotated: Bool
    let poemNumber: Int
}

struct GameResult: Codable, Identifiable, Hashable {
    let id: UUID
    let date: Date
    let elapsedTime: TimeInterval

    // Conform to Equatable for Hashable
    static func == (lhs: GameResult, rhs: GameResult) -> Bool {
        return lhs.date == rhs.date && lhs.elapsedTime == rhs.elapsedTime
    }

    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(elapsedTime)
    }

    init(id: UUID = UUID(), date: Date, elapsedTime: TimeInterval) {
        self.id = id
        self.date = date
        self.elapsedTime = elapsedTime
    }

    // MARK: - Codable
    // The custom Codable implementation is needed to handle the `id` property,
    // which we don't want to save but need for Identifiable.

    private enum CodingKeys: String, CodingKey {
        case date, elapsedTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try container.decode(Date.self, forKey: .date)
        self.elapsedTime = try container.decode(TimeInterval.self, forKey: .elapsedTime)
        self.id = UUID() // Assign a new UUID since it's not in the saved data
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(elapsedTime, forKey: .elapsedTime)
    }
}

private struct KimarijiEntry: Decodable {
    let poemNumber: Int
    let kimariji: String
}

private struct KimarijiPayload: Decodable {
    let entries: [KimarijiEntry]
}

private final class KimarijiStore {
    static let shared = KimarijiStore()

    private let kimarijiByPoemNumber: [Int: String]

    private init() {
        guard let url = Bundle.main.url(forResource: "Kimariji", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONDecoder().decode(KimarijiPayload.self, from: data) else {
            kimarijiByPoemNumber = [:]
            return
        }

        kimarijiByPoemNumber = Dictionary(
            uniqueKeysWithValues: payload.entries.map { ($0.poemNumber, $0.kimariji) }
        )
    }

    func kimariji(for poemNumber: Int) -> String? {
        kimarijiByPoemNumber[poemNumber]
    }
}

struct CardGameView_Previews: PreviewProvider {
    static var previews: some View {
        CardGameView(viewModel: CardGameViewModel())
    }
}
