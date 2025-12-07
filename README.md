# PASTQUEEN

PASTQUEEN is a modern iOS Ballistic Calculator application built with SwiftUI and SwiftData. It allows users to manage ammunition profiles and calculate ballistic trajectories using the `SwiftBallistics` library.

## Features

- **Ammunition Management**: Create, edit, and store ballistic profiles for different ammunitions.
- **Ballistic Calculator**: Calculate drop, windage, velocity, and energy for specific distances.
- **Trajectory Chart**: Visualize the bullet trajectory.
- **Weather Integration**: Automatically fetch local weather data (Wind, Pressure, Temperature) to improve calculation accuracy.
- **Modern Architecture**: Built with MVVM, SwiftData for persistence, and Swift's modern concurrency features.

## Requirements

- iOS 26.0+
- Xcode 15.0+ (Swift 5.9+)

## Getting Started

1. Clone the repository.
2. Open `PASTQUEEN.xcodeproj` in Xcode.
3. Ensure the `SwiftBallistics` dependency is resolved.
4. Run the app on a simulator or device.

## Architecture

- **Models**: SwiftData models (`BallisticSettings`) and logic managers (`WeatherManager`, `LocationManager`).
- **Views**: SwiftUI views for user interaction.
- **External Libraries**: `SwiftBallistics` for core physics calculations.

## License

Private / Proprietary.
