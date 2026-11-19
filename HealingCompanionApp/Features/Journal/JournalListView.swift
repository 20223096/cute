import SwiftUI

struct JournalListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var journal: JournalStore

    @State private var editingEntry: JournalEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.00, green: 0.97, blue: 0.96),
                        Color(red: 0.96, green: 0.96, blue: 1.00)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                if journal.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(journal.entries) { entry in
                                Button {
                                    editingEntry = entry
                                } label: {
                                    entryCard(entry)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        journal.delete(entry)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("감정 일기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
            .sheet(item: $editingEntry) { entry in
                JournalEntryView(editing: entry)
                    .environmentObject(journal)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("૮ ˶ᵔ ᵕ ᵔ˶ ა")
                .font(.system(size: 52))
            Text("아직 기록이 없어")
                .font(.headline)
            Text("💬 를 눌러서 첫 마음을 적어봐")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 80)
    }

    private func entryCard(_ entry: JournalEntry) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 4) {
                Text(dayString(entry.createdAt))
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(timeString(entry.createdAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary.opacity(0.75))
                if let mood = entry.mood {
                    Text(mood.emoji)
                        .font(.title3)
                        .padding(.top, 4)
                }
            }
            .frame(width: 56)

            Rectangle()
                .fill(entry.mood?.animation.primaryColor ?? Color.pink.opacity(0.4))
                .frame(width: 3)

            Text(entry.text)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
                .lineLimit(4)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.92))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        )
    }

    private func dayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M/d"
        return f.string(from: date)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "a h:mm"
        return f.string(from: date)
    }
}
