import SwiftUI

final class KimarijiHenkaStore {
    static let shared = KimarijiHenkaStore()

    private init() {}

    /// 読み（`reading` または `kimariji`）で衝突判定し、返す文字列は常に札面の `kimariji` の接頭辞（`reading` と文字数が揃っている前提で位置対応）。
    func resolvedKimariji(poemNumber: Int, remainingPoemNumbers: Set<Int>) -> String {
        let baseSurface = KimarijiStore.shared.kimariji(for: poemNumber) ?? ""
        let basePhone = KimarijiStore.shared.phoneticKimariji(for: poemNumber) ?? baseSurface

        guard !remainingPoemNumbers.isEmpty else { return baseSurface }

        guard !basePhone.isEmpty else { return baseSurface }

        for len in 1...basePhone.count {
            let cand = String(basePhone.prefix(len))
            var ok = true
            for q in remainingPoemNumbers where q != poemNumber {
                guard let kq = KimarijiStore.shared.phoneticKimariji(for: q) else { continue }
                if Self.phoneticPrefixesConflict(cand, kq) {
                    ok = false
                    break
                }
            }
            if ok {
                return Self.surfacePrefix(matchingPhoneticPrefixLength: len, surface: baseSurface, phonetic: basePhone)
            }
        }
        return baseSurface
    }

    /// `kimariji` と `reading` は同一文字数で対応している想定。ずれているときは表面形をそのまま返す。
    private static func surfacePrefix(matchingPhoneticPrefixLength len: Int, surface: String, phonetic: String) -> String {
        guard len <= phonetic.count else { return surface }
        guard surface.count == phonetic.count else { return surface }
        return String(surface.prefix(len))
    }

    /// 別札の決まり字読みが `candidate` と読み上げ上ぶつかるか（どちらかが他方の接頭辞になりうるか）。
    private static func phoneticPrefixesConflict(_ candidate: String, _ otherReading: String) -> Bool {
        otherReading.hasPrefix(candidate) || candidate.hasPrefix(otherReading)
    }
}

enum KimarijiDisplayHelper {
    /// 札がまだ「場にある」とみなす集合を使った決まり字（変化オフ時・オン時とも表示は `kimariji`。オン時は内部で読みを使って短くなる）。
    static func kimariji(
        poemNumber: Int,
        remainingPoemNumbers: Set<Int>,
        useHenka: Bool
    ) -> String {
        let base = KimarijiStore.shared.kimariji(for: poemNumber) ?? ""
        guard useHenka else { return base }
        return KimarijiHenkaStore.shared.resolvedKimariji(poemNumber: poemNumber, remainingPoemNumbers: remainingPoemNumbers)
    }

    /// 変化後に効いている部分を赤、不要になった末尾はラベル標準色（ダークモード対応）で、`reference` 全文を並べて表示する。
    /// 例: reference「みかの」・effective「みか」→「みか」赤 + 「の」primary。
    static func kimarijiColoredText(reference: String, effective: String) -> Text {
        if effective == reference {
            return Text(reference).foregroundStyle(.primary)
        }
        guard reference.hasPrefix(effective) else {
            return Text(effective).foregroundStyle(.red)
        }
        let dropped = String(reference.dropFirst(effective.count))
        return Text(effective).foregroundStyle(.red) + Text(dropped).foregroundStyle(.primary)
    }
}
