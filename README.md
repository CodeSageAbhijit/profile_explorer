# Profile Explorer App

Flutter assignment for Starkzapp - A profile browsing app with Clean Architecture and Riverpod state management.

## Features
- Grid view of 20 random user profiles
- Real-time search by name/city
- Twitter-like heart animation
- Profile detail view with Hero transitions
- Pull-to-refresh
- Image prefetching (no lazy loading)
- Clean Architecture + MVVM

## Tech Stack
- Flutter 3.x
- Riverpod 2.5.1
- cached_network_image 3.3.1
- google_fonts 6.2.1
- http 1.2.0

## Installation

Clone repo

git clone github.com/CodeSageAbhijit/profile_explorer

cd profile-explorer-app

Install dependencies
flutter pub get

Run app
flutter run




**Fields Used:**
- name.first, name.last
- picture.large
- dob.age
- location.city, location.country
- login.uuid

## Architecture

lib/
├── data/ # API calls, models, repository impl

├── domain/ # Entities, repository interfaces

└── presentation/ # UI, providers, widgets

text

## Assignment Requirements ✅
- [x] Grid layout with profile cards
- [x] Like functionality with state sync
- [x] Profile detail screen
- [x] Clean Architecture
- [x] Riverpod state management
- [x] Error handling
- [x] Hero animations (Bonus)
- [x] Pull-to-refresh (Bonus)
- [x] Search filter (Bonus)

## Build

Android APK
flutter build apk --release

iOS
flutter build ios --release

text

## Author
**[Abhijit Kad]**  
Email: abhijitkad62@gmail.com


---
Built for Starkzapp Flutter Developer Assignment
