# No Distract App

A Flutter application designed to help users maintain focus and productivity by minimizing digital distractions.

## Overview

No Distract App is a productivity-focused mobile application that helps users stay concentrated on their important tasks by providing distraction-blocking features and focus management tools.

## Features

- **App Blocking**: Block access to distracting applications during focus sessions
- **Focus Timer**: Pomodoro-style timer to structure work periods
- **Usage Statistics**: Track your app usage patterns and productivity metrics
- **Custom Block Lists**: Create personalized lists of apps to block
- **Flexible Scheduling**: Set automatic blocking schedules for different times of day
- **Break Reminders**: Smart notifications to take healthy breaks
- **Progress Tracking**: Monitor your focus improvement over time

## Screenshots

*Screenshots will be added here*

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Android Studio or VS Code
- Android device or emulator (API level 21+)
- iOS device or simulator (iOS 11.0+)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Fahad-Al-Maashani/No_Distract_App.git
cd No_Distract_App
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/               # UI screens
├── widgets/               # Reusable UI components
├── models/                # Data models
├── services/              # Business logic and API calls
├── utils/                 # Utility functions and constants
└── theme/                 # App theming and styling
```

## Dependencies

Key packages used in this project:

- `flutter/material.dart` - Material Design components
- `provider` - State management
- `shared_preferences` - Local data storage
- `flutter_local_notifications` - Local notifications
- `device_apps` - App management functionality
- `usage_stats` - App usage tracking

## Permissions

The app requires the following permissions:

### Android
- `PACKAGE_USAGE_STATS` - To monitor app usage
- `SYSTEM_ALERT_WINDOW` - For overlay blocking functionality
- `DEVICE_ADMIN` - For advanced app blocking features

### iOS
- `Screen Time API` - For app usage monitoring and restrictions

## Configuration

### Android Setup
1. Enable "Usage Access" permission in device settings
2. Grant "Display over other apps" permission
3. Enable device administrator rights (if required)

### iOS Setup
1. Enable Screen Time permissions when prompted
2. Configure app restrictions in iOS Settings if needed

## Usage

1. **Set Up Focus Session**: Choose apps to block and set session duration
2. **Start Focus Mode**: Begin your distraction-free work period
3. **Track Progress**: Monitor your productivity statistics
4. **Customize Settings**: Adjust blocking preferences and schedules

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Development

### Building for Release

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

### Testing
```bash
flutter test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Fahad Al Maashani - [@Fahad-Al-Maashani](https://github.com/Fahad-Al-Maashani)

Project Link: [https://github.com/Fahad-Al-Maashani/No_Distract_App](https://github.com/Fahad-Al-Maashani/No_Distract_App)

## Acknowledgments

- Flutter team for the amazing framework
- Community contributors and testers
- Material Design for UI inspiration

---

**Note**: This app is designed to help with productivity and focus. For best results, combine with good digital wellness practices and healthy work habits.
