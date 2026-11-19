import SwiftUI

struct FriendsFeedView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var letterStore: LetterStore

    @State private var tab: FriendsTab = .inbox
    @State private var selectedFriend: Friend?
    @State private var showInvite = false
    @State private var showCompose = false

    enum FriendsTab: String, CaseIterable, Identifiable {
        case inbox = "편지함"
        case friends = "친구들"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.98, green: 0.94, blue: 1.0), Color(red: 0.92, green: 0.97, blue: 1.0)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 14) {
                    Picker("", selection: $tab) {
                        ForEach(FriendsTab.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 18)
                    .padding(.top, 10)

                    switch tab {
                    case .inbox:
                        LetterInboxView()
                    case .friends:
                        friendsList
                    }
                }
            }
            .navigationTitle("친구")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showInvite = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.play(.medium)
                        showCompose = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.pencil")
                            Text("편지")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .sheet(item: $selectedFriend) { friend in
                FriendDetailView(friend: friend)
            }
            .sheet(isPresented: $showInvite) {
                inviteSheet
            }
            .sheet(isPresented: $showCompose) {
                LetterComposeView()
                    .environmentObject(appState)
                    .environmentObject(letterStore)
                    .environmentObject(appState.comfortStore)
            }
        }
    }

    private var friendsList: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("가까운 친구들과 조용히 나누는 감정")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(appState.friendsStore.friends) { friend in
                    Button {
                        selectedFriend = friend
                    } label: {
                        friendCard(friend)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
    }

    private func friendCard(_ friend: Friend) -> some View {
        let latest = friend.recentEntries.first
        let anim = latest?.emotion.animation
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                HealyAvatarView(emotion: friend.recentEntries.first?.emotion ?? .talk, size: 36)
                    .font(.system(size: 34))
                    .frame(width: 58, height: 58)
                    .background(.white.opacity(0.85), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(friend.name)
                        .font(.headline)
                    Text(friend.character.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let latest = latest {
                    Text(latest.emotion.emoji)
                        .font(.system(size: 28))
                }
            }

            HStack(spacing: 6) {
                ForEach(friend.recentEntries.prefix(7)) { entry in
                    VStack(spacing: 2) {
                        Text(entry.emotion.emoji)
                            .font(.system(size: 18))
                        Text(dayLabel(entry.date))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 36, height: 44)
                    .background(
                        LinearGradient(
                            colors: [entry.emotion.animation.primaryColor.opacity(0.45), entry.emotion.animation.secondaryColor.opacity(0.3)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
                }
            }

            if let latest = latest {
                Text(latest.message)
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    anim?.primaryColor.opacity(0.45) ?? Color.white.opacity(0.5),
                    anim?.secondaryColor.opacity(0.3) ?? Color.white.opacity(0.3)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private var inviteSheet: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(.secondary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            Text("친구 초대")
                .font(.title3.weight(.semibold))
            Text("초대 코드를 공유하면 조용히 감정을 나눌 수 있어요")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("HC-29F8-LVV3")
                .font(.title2.weight(.bold).monospaced())
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

            Button {
            } label: {
                Text("코드 복사")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.pink.opacity(0.85), in: Capsule())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.bottom, 30)
        .presentationDetents([.medium])
    }

    private func dayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d일"
        return f.string(from: date)
    }
}
