import SwiftUI

struct FriendDetailView: View {
    let friend: Friend
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.97, green: 0.95, blue: 1.0), Color(red: 0.93, green: 0.98, blue: 0.98)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        entriesList
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(friend.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HealyAvatarView(emotion: friend.recentEntries.first?.emotion ?? .talk, size: 56)
                .font(.system(size: 60))
                .frame(width: 110, height: 110)
                .background(.white.opacity(0.85), in: Circle())
            Text(friend.character.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var entriesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("최근 감정")
                .font(.headline)
                .padding(.leading, 4)
                .padding(.top, 12)

            ForEach(friend.recentEntries) { entry in
                entryCard(entry)
            }
        }
    }

    private func entryCard(_ entry: EmotionEntry) -> some View {
        let anim = entry.emotion.animation
        let reactions = appState.friendsStore.friends.first(where: { $0.id == friend.id })?.receivedReactions[entry.id] ?? []

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(entry.emotion.emoji)
                    .font(.system(size: 26))
                VStack(alignment: .leading, spacing: 2) {
                    Text(dateString(entry.date))
                        .font(.subheadline.weight(.medium))
                    Text(entry.message)
                        .font(.caption)
                        .foregroundStyle(.primary.opacity(0.75))
                        .lineLimit(2)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                ForEach(FriendReactionKind.allCases) { kind in
                    Button {
                        Haptics.play(.light)
                        appState.friendsStore.toggleReaction(kind, on: entry.id, friendID: friend.id)
                    } label: {
                        HStack(spacing: 4) {
                            Text(kind.emoji)
                            Text(kind.label)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            reactions.contains(kind)
                                ? Color.white.opacity(0.95)
                                : Color.white.opacity(0.45),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(reactions.contains(kind) ? 0.9 : 0), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [anim.primaryColor.opacity(0.5), anim.secondaryColor.opacity(0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M월 d일 (EEE)"
        return f.string(from: date)
    }
}
