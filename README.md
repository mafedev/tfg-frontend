# TFG Frontend

## Overview

This repository contains the Flutter frontend for the TFG project, a caregiver/patient assistant application for people with Alzheimer’s disease. The mobile app provides authentication, patient management, appointments, medication tracking, allergies management, routines, and notifications.

## Key Features

- Authentication flow for caregivers and patients
- Patient profile and detail screens
- Appointment creation, viewing, and voice reading
- Medication tracking and prescription management
- Routine planning and task tracking
- Allergy registration and severity editing
- Home dashboard with upcoming actions and notifications
- Local notifications and text-to-speech support

## Architecture

The app is organized by feature and shared utilities:

- `lib/features/` - Feature modules for allergies, appointment, auth, home, medication, patient, prescription, prescription tracking, profile, relation, routine, and navigation
- `lib/core/` - Shared services, configuration, theme, and utility helpers
- `lib/shared/` - Reusable widgets, models, enums, DTOs, and common UI components
- `lib/main.dart` - App bootstrap and environment initialization

## Technology Stack

- Flutter 3.9.x
- Dart 3.9.x
- `flutter_dotenv`
- `flutter_secure_storage`
- `flutter_local_notifications`
- `timezone`
- `table_calendar`
- `shared_preferences`
- `flutter_tts`
- `url_launcher`

## Prerequisites

- Flutter SDK installed and configured
- Android Studio, Xcode, or VS Code for development
- A connected emulator or device
- Backend API running and accessible from the frontend

## Setup

1. Clone the repository:

```bash
git clone <repository-url>
cd tfg-frontend
```

2. Install dependencies:

```bash
flutter pub get
```

3. Create or update `.env` at the project root:

```env
API_BASE_URL=http://10.0.2.2:8080/api
```

- `10.0.2.2` is the Android emulator alias for the host machine.
- Adjust the URL for iOS, web, or production as needed.

## Run

Launch the application on a connected device or emulator:

```bash
flutter run
```

For a specific target device:

```bash
flutter run -d <device-id>
```

## Testing

Run the Flutter test suite:

```bash
flutter test
```

## Notes

- The frontend expects the backend API to be available at the configured `API_BASE_URL`.
- If you change the API address, update the `.env` file and restart the app.
- This project uses feature-based organization to keep UI, services, and data handling separated.
