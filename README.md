4ㅊ# Healing Companion (Widget-First MVP)

A lightweight emotional comfort iOS app focused on **home screen widget interaction**.

## Project Structure

```text
cute/
├─ README.md
├─ Shared/
│  ├─ HealingModels.swift
│  └─ HealingStore.swift
├─ HealingCompanionApp/
│  ├─ HealingCompanionApp.swift
│  └─ MainView.swift
└─ HealingCompanionWidgetExtension/
   ├─ EmotionIntent.swift
   ├─ HealingWidget.swift
   └─ HealingWidgetBundle.swift
```

## MVP Features Included

- Widget emoji buttons (`😭`, `😴`, `😡`, `😶`, `💬`)
- Tap emoji -> character reaction + one-line response
- Emotion-based response mapping (Korean short comfort lines)
- Character personality matching logic
- Hourly widget refresh (expression/background/message tone update)
- Basic main app screen for larger character view

## Setup in Xcode (Simulator)

1. Create a new iOS App project named `HealingCompanionApp` (SwiftUI, Swift).
2. Add a new target: **Widget Extension** named `HealingCompanionWidgetExtension`.
3. Enable capability **App Groups** for both targets.
4. Add App Group id in both targets:
   - `group.com.example.healingcompanion`
5. Add all files from this folder into the Xcode project:
   - `Shared/*` -> target membership: App + Widget Extension
   - `HealingCompanionApp/*` -> App target
   - `HealingCompanionWidgetExtension/*` -> Widget target
6. In widget target:
   - iOS deployment target 17.0+ (interactive widget via AppIntent)
7. Build and run app on iOS Simulator.
8. Add widget on simulator home screen:
   - Long press home screen -> `+` -> find `Healing Companion` widget.
9. Tap emoji button on widget and verify:
   - character changes
   - short speech bubble updates
   - update feels immediate (about 1~2s).

## Notes

- No backend/login required.
- All state is local (`UserDefaults` + App Group).
- You can swap placeholder character strings with Lottie assets later.
