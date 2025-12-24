# Pulse - Prediction Market

A modern iOS prediction market application built with SwiftUI. Pulse enables users to discover, trade, and track prediction markets with an intuitive and beautiful interface.

## Features

- **Authentication**: Secure sign in and sign up with session management
- **Home Feed**: Personalized home view with bookmarked events and "For You" recommendations
- **Markets Browser**: Browse all available prediction markets with category filtering and search
- **Event Details**: Comprehensive event views with outcomes, probabilities, and market information
- **Orderbooks**: Interactive orderbook interface for trading Yes/No positions
- **Portfolio Management**: Track positions, pending orders, and order history with PnL calculations
- **Real-time Updates**: Network monitoring and error handling for seamless user experience
- **Search & Filter**: Find events by category or search terms
- **Bookmarks**: Save and quickly access your favorite markets

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Setup

1. Clone the repository
2. Open `Pulse.xcodeproj` in Xcode
3. Configure your API endpoint in `Pulse/Services/Network/APIConfiguration.swift`
4. Build and run the project

## Architecture

The app follows a clean architecture pattern with:

- **Views**: SwiftUI views organized by feature (Auth, Home, Event, Market, Portfolio, Profile)
- **Models**: Data models for API responses and domain entities
- **Services**: Network layer, authentication, and business logic services
- **Components**: Reusable UI components
- **Utilities**: Helpers for colors, fonts, animations, and keychain management

## Tech Stack

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data flow
- **URLSession**: Network requests and API communication
- **Keychain**: Secure token storage

## Open Source

This project is open source and available for the community to use, learn from, and contribute to.
