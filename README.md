# NutriScan

A mobile app that lets users scan a food product's barcode and instantly
see its allergens, harmful ingredients, and beneficial nutritional traits.

## Tech stack
- Flutter (Dart)
- Barcode scanning: `mobile_scanner`
- Food data: external food database API (e.g., Open Food Facts)
- Local storage: `shared_preferences` (user allergy/preference profile)

## Getting started
1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Clone this repo and run:
   ```bash
   flutter pub get
   flutter run
   ```
3. See `CONTRIBUTING.md` before pushing any code.

## Project structure
```
lib/
  main.dart          # app entry point
  app.dart           # MaterialApp + routes
  core/               # theme, constants, shared config
  models/             # data models (Product, UserProfile)
  screens/            # one file per screen
  services/           # API calls, barcode scanning, storage
  widgets/            # reusable UI components
```

## Team
See the M0 Project Selection Report for team roles and responsibilities.
