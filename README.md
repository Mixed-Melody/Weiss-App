# Weiß Schwarz Card Tracker

This project is a desktop application for managing a collection of **Weiß Schwarz** trading cards and trial decks.  The app allows you to track owned cards and trial decks, maintain a wishlist, scrape the latest prices and card images from popular marketplaces, view visual summaries of your collection, and export your wishlist or selected items to a PDF document for sharing.

## Features

- **Card and Trial Deck Management** – Add, edit, and remove individual cards and trial decks.  Each item supports fields like name, set, rarity, quantity, price and image URL.
- **Wishlist** – Mark cards and decks you want as wishlist items.  Export your wishlist to a nicely formatted PDF document.
- **Dashboard** – A dashboard shows the total value of your collection and visual summaries such as charts.
- **Price and Image Scraper** – Manually run the included scraper to update local price and image data from third‑party marketplaces.  The scraper is designed to be run on demand from within the app or via the command line.
- **Desktop Focus** – The UI is optimized for Windows, macOS and Linux desktops.

## Getting Started

Follow these steps to set up and build the application on your desktop platform.  The examples assume a *UNIX‑like* environment; adjust commands accordingly for Windows.

### Prerequisites

1. **Install Flutter**

   Visit the official Flutter installation guide at <https://flutter.dev/docs/get-started/install> and follow the steps for your operating system.  After installation, ensure that Flutter is added to your path:

   ```bash
   flutter --version
   ```

   The project targets Flutter 2.17 or later.  If your version is older, upgrade Flutter before continuing.

2. **Enable Desktop Support**

   Flutter desktop support is still under development and must be explicitly enabled.  Run the following command to enable support for your platform:

   ```bash
   flutter config --enable-macos-desktop   # On macOS
   flutter config --enable-windows-desktop # On Windows
   flutter config --enable-linux-desktop   # On Linux
   ```

   You can verify that desktop devices are available by running:

   ```bash
   flutter devices
   ```

3. **Clone or Download the Repository**

   Clone this repository using Git or download it as a zip file and extract it.  For example:

   ```bash
   git clone <repository‑url> weis_schwarz_tracker
   cd weis_schwarz_tracker
   ```

### Building and Running the Application

1. **Fetch Dependencies**

   Install the project dependencies:

   ```bash
   flutter pub get
   ```

2. **Run the App**

   To run the app on your desktop platform, specify the desired device:

   ```bash
   flutter run -d windows   # For Windows
   flutter run -d macos     # For macOS
   flutter run -d linux     # For Linux
   ```

   The first build may take some time as Flutter downloads and builds the necessary binaries.  Future runs will be faster.

3. **Build a Release**

   To build a distributable version of the app:

   ```bash
   flutter build windows   # Produces a .exe in build/windows/runner/Release
   flutter build macos     # Produces a .app bundle in build/macos/Build/Products/Release
   flutter build linux     # Produces an executable in build/linux/x64/release/bundle
   ```

### Running the Price and Image Scraper

Prices and images can become outdated as marketplace listings change.  You can update your local database of prices and images manually by running the scraper service.  There are two ways to run the scraper:

1. **From within the App** – Open the application and navigate to the dashboard or settings page.  Click **Run Scraper** to fetch the latest price and image data.  The UI will display progress and inform you when the scrape is complete.

2. **From the Command Line** – Run the scraper directly with Dart:

   ```bash
   dart lib/services/price_scraper.dart
   ```

   This command will fetch the latest data and update the local `hive` database.  Note that the scraper contains placeholder selectors and will need to be customized to work with your preferred marketplace; see the code comments for details.

### Exporting to PDF

To export your wishlist or a selection of cards to a PDF file:

1. Open the Wishlist page in the app.
2. Select the cards and/or trial decks you wish to include.
3. Click the **Export to PDF** button.
4. Choose a save location when prompted.  The resulting PDF file will be formatted nicely with item details and images.

### Dependencies

The application depends on the following Dart/Flutter packages:

- `provider` – Simple state management for Flutter.
- `hive` and `hive_flutter` – Lightweight, fast local database.
- `path_provider` – For determining the correct filesystem paths across platforms.
- `http` and `html` – HTTP client and HTML parser used for scraping web pages.
- `pdf` and `printing` – Creating and exporting PDF documents.
- `fl_chart` – Rendering charts for the dashboard.
- `flutter_test` – Development dependency for writing tests.

These dependencies are declared in `pubspec.yaml` and are automatically fetched when you run `flutter pub get`.

### Code Structure

The source code is organized into modular components:

- **lib/main.dart** – The application entry point.  Initializes services and sets up providers.
- **lib/models/** – Contains data models for cards, trial decks, and wishlist items with their Hive adapters.
- **lib/services/** – Includes services for database access, price scraping, and PDF generation.
- **lib/providers/** – State management classes for the collection and wishlists.
- **lib/screens/** – UI screens for different parts of the application.
- **lib/widgets/** – Reusable UI widgets such as list items and dashboard cards.

### TODOs and Future Enhancements

The project includes TODO comments throughout the codebase to highlight areas for future work:

- Research modern UI design trends and refine the interface to be more visually appealing and accessible.
- Enhance the price scraper with robust parsing logic for specific marketplaces and handle captchas, rate limiting and login if necessary.
- Add support for more metadata fields related to the Weiß Schwarz game (e.g. card effects, attributes, traits).
- Implement unit and widget tests to ensure application stability across updates.

We welcome contributions!  Please open issues or submit pull requests if you’d like to help improve the app.

---

If you encounter any problems or have questions about building or using the app, feel free to consult the Flutter documentation or reach out for assistance.