import SwiftUI

struct EmotionCalendarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var referenceDate: Date = Date()
    @State private var selectedSummary: DaySummary?

    private var cal: Calendar { Calendar.current }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.94, blue: 0.94), Color(red: 0.93, green: 0.96, blue: 1.0)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        weekdayHeader
                        monthGrid
                        recentList
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("스토리북")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedSummary) { summary in
                EmotionDayDetailView(summary: summary)
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                shiftMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.primary.opacity(0.6))
            }
            Spacer()
            Text(monthTitle)
                .font(.title3.weight(.semibold))
            Spacer()
            Button {
                shiftMonth(1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.primary.opacity(0.6))
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 8)
    }

    private var weekdayHeader: some View {
        let symbols = cal.shortStandaloneWeekdaySymbols
        return HStack {
            ForEach(symbols, id: \.self) { s in
                Text(s)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var monthGrid: some View {
        let days = daysInGrid()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                dayCell(for: day)
            }
        }
    }

    private func dayCell(for day: Date?) -> some View {
        Group {
            if let day = day {
                let summary = appState.emotionLog.summary(for: day)
                Button {
                    if let summary = summary {
                        selectedSummary = summary
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(cellBackground(for: summary))

                        VStack(spacing: 2) {
                            Text(dayNumber(day))
                                .font(.caption2)
                                .foregroundStyle(.primary.opacity(0.75))

                            if let summary = summary {
                                emojiCluster(for: summary)
                            } else {
                                Color.clear.frame(height: 22)
                            }
                        }
                        .padding(.vertical, 6)

                        if let summary = summary, summary.count > 1 {
                            countBadge(summary.count)
                                .offset(x: 18, y: -20)
                        }
                    }
                    .frame(height: 62)
                }
                .buttonStyle(.plain)
                .disabled(summary == nil)
            } else {
                Color.clear.frame(height: 62)
            }
        }
    }

    @ViewBuilder
    private func emojiCluster(for summary: DaySummary) -> some View {
        let emojis = summary.emotionsInOrder.prefix(3)
        switch emojis.count {
        case 0:
            Color.clear.frame(height: 22)
        case 1:
            Text(emojis[0].emoji)
                .font(.system(size: 22))
        case 2:
            HStack(spacing: -6) {
                Text(emojis[0].emoji).font(.system(size: 18))
                Text(emojis[1].emoji).font(.system(size: 18))
            }
        default:
            HStack(spacing: -6) {
                Text(emojis[0].emoji).font(.system(size: 16))
                Text(emojis[1].emoji).font(.system(size: 16))
                Text(emojis[2].emoji).font(.system(size: 16))
            }
        }
    }

    private func countBadge(_ count: Int) -> some View {
        Text("\(count)")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .frame(minWidth: 16, minHeight: 16)
            .padding(.horizontal, 3)
            .background(Color.black.opacity(0.55), in: Capsule())
    }

    private var recentList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("최근")
                .font(.headline)
                .padding(.leading, 4)

            let recents = appState.emotionLog.recentSummaries(limit: 6)
            if recents.isEmpty {
                Text("아직 기록이 없어요")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            } else {
                VStack(spacing: 10) {
                    ForEach(recents) { summary in
                        Button {
                            selectedSummary = summary
                        } label: {
                            recentRow(summary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.top, 10)
    }

    private func recentRow(_ summary: DaySummary) -> some View {
        let dominant = summary.dominantEmotion ?? summary.moments.first?.emotion ?? .numb
        let anim = dominant.animation
        let trail = summary.emotionsInOrder.prefix(4).map(\.emoji).joined(separator: "  ")
        return HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(dayLabel(summary.day))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary.opacity(0.75))
                Text(weekdayLabel(summary.day))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(trail)
                    .font(.title3)
                Text(summary.recapLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if summary.count > 1 {
                Text("\(summary.count)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.45), in: Capsule())
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [anim.primaryColor.opacity(0.45), anim.secondaryColor.opacity(0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
    }

    private func cellBackground(for summary: DaySummary?) -> some ShapeStyle {
        guard let summary = summary, let dominant = summary.dominantEmotion else {
            return AnyShapeStyle(Color.white.opacity(0.35))
        }
        let anim = dominant.animation
        return AnyShapeStyle(
            LinearGradient(
                colors: [anim.primaryColor.opacity(0.7), anim.secondaryColor.opacity(0.5)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
    }

    private func daysInGrid() -> [Date?] {
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: referenceDate)) ?? referenceDate
        let range = cal.range(of: .day, in: .month, for: startOfMonth) ?? 1..<2
        let firstWeekday = cal.component(.weekday, from: startOfMonth)
        let leading = firstWeekday - cal.firstWeekday
        var days: [Date?] = Array(repeating: nil, count: max(0, leading))
        for d in 0..<range.count {
            days.append(cal.date(byAdding: .day, value: d, to: startOfMonth))
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return days
    }

    private func shiftMonth(_ delta: Int) {
        if let newDate = cal.date(byAdding: .month, value: delta, to: referenceDate) {
            referenceDate = newDate
        }
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월"
        return f.string(from: referenceDate)
    }

    private func dayNumber(_ date: Date) -> String {
        "\(cal.component(.day, from: date))"
    }

    private func dayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M/d"
        return f.string(from: date)
    }

    private func weekdayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "EEE"
        return f.string(from: date)
    }
}
