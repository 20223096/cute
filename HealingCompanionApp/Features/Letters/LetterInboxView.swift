import SwiftUI

struct LetterInboxView: View {
    @EnvironmentObject private var letterStore: LetterStore

    @State private var segment: Segment = .incoming
    @State private var selectedLetter: EmotionLetter?

    enum Segment: String, CaseIterable, Identifiable {
        case incoming = "받은 편지"
        case outgoing = "보낸 편지"
        var id: String { rawValue }
    }

    var body: some View {
        VStack(spacing: 14) {
            Picker("", selection: $segment) {
                ForEach(Segment.allCases) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 18)

            let list = segment == .incoming ? letterStore.inbox : letterStore.sent
            if list.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(list) { letter in
                            LetterCardView(letter: letter) {
                                selectedLetter = letter
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
        .fullScreenCover(item: $selectedLetter) { letter in
            LetterOpenView(letter: letter) {
                selectedLetter = nil
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text(segment == .incoming ? "💌" : "✉️")
                .font(.system(size: 48))
            Text(segment == .incoming ? "아직 받은 편지가 없어" : "아직 보낸 편지가 없어")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
}
