# 🍞 Bakery App (Junior Mobile Developer Certification)

A complete, offline-first mobile application for a local bakery, built as a final project for the Junior Mobile Developer certification. This app demonstrates core Flutter/Dart skills, local database management with SQLite, efficient state management with Provider, and clean architecture principles.

The application serves two distinct user roles—**Admin** and **Buyer**—within a single, robust mobile app.

---

## 📋 Project Context & Requirements

This project was built to fulfill the practical exam requirements for the Junior Mobile Developer certification. The core task was to develop a mobile application for an online bakery based on the following specifications :

- **Functionality:**
  - Display a list of bakery products (cakes and bread).
  - Allow buyers to place orders, providing customer data.
  - Capture the buyer's house coordinates using the device's **GPS**.
  - Store all data (products, users, orders) in a "server".
- **User Roles (2) :**
  - **Admin :** Can view incoming transaction lists and manage (CRUD) product data and order statuses.
  - **Buyer :** Can view the product list, place orders (including GPS location), and view their transaction status.
- **Technology Stack :**
  - **Frontend :** Flutter & Dart
  - **Backend :** SQLite (as the local "server" database)
  - **Plugins :** As needed (e.g., for GPS, database access).

---

## ✨ Features

### 👨‍🍳 Admin Role

- **Product Management (Full CRUD) :**
  - **Create :** Add new bakery products (name, description, price) via a dedicated form.
  - **Read :** View the complete list of all products in the database.
  - **Update :** Edit existing product details.
  - **Delete :** Remove products from the catalog (with a confirmation dialog).
- **Order Management :**
  - View a list of all incoming orders from all buyers, sorted by most recent.
  - View order details, including buyer information, items ordered, and the **GPS coordinates** for delivery.
  - Update the status of an order (e.g., "Pending", "Processed", "Shipped", "Delivered").

### 🛒 Buyer Role

- **Product Catalog :**
  - View all available bakery products in a clean, responsive grid layout.
  - Pull-to-refresh to get the latest product list.
- **Shopping Cart :**
  - Add products to a persistent shopping cart.
  - View all items in the cart in a detailed list.
  - Adjust item quantities (+/-) or remove items completely (with confirmation).
  - See a real-time updating total price.
- **Checkout Process :**
  - View a final order summary.
  - Securely capture the user's current **GPS coordinates** (lat/long) for delivery.
  - Button to "Confirm Order" is only enabled after location is successfully fetched.
- **Order History & Status :**
  - View a complete history of all past orders.
  - See the **real-time status** of each order (e.g., "Pending", "Processed"), which is updated by the Admin.
  - View a detailed digital "Receipt" for any order, showing items, total price, and delivery location.

### 📱 General Application Features

- **Role-Based Authentication :** A single login screen that directs users to the `AdminDashboard` or `BuyerDashboard` based on their role stored in the SQLite database.
- **Splash Screen :** A professionally styled animated splash screen (with the app logo and theme colors) that handles authentication status checking on startup.
- **Global Theming :** A consistent, modern UI/UX applied globally using `ThemeData`. This includes a custom color palette (primary yellow), 'Inter' font (via `google_fonts`), and standardized styles for buttons, cards, and input fields.
- **Offline-First :** As all data is stored in the local SQLite database, the app is 100% functional offline (after the initial font download).

---

## 🛠️ Tech Stack & Key Packages

- **Core :** Flutter (v[Your Flutter Version]), Dart (v[Your Dart Version])
- **Database :** `sqflite` (for raw SQL access to the local SQLite database), `path_provider` (to locate the correct path for the database file).
- **State Management :** `provider` (for clean separation of business logic from UI, using `ChangeNotifier`, `Consumer`, and `MultiProvider`).
- **Hardware API:** `geolocator` (for accessing device GPS and managing location permissions).
- **Local Storage (Session) :** `shared_preferences` (for persisting the logged-in user's ID between app sessions).
- **UI/UX & Utilities :**
  - `google_fonts` : To dynamically load and use the 'Inter' font family.
  - `intl` : For user-friendly date, time, and currency (`Rp`) formatting.

---

## 🏗️ Architecture

This project follows a clean, layered architecture to ensure a strong separation of concerns, making the app maintainable, scalable, and testable.

- **Presentation Layer (UI) :** (`lib/screens/`, `lib/widgets/`)
  - Consists of all Flutter widgets.
  - Responsible for displaying the UI and capturing user input.
  - Does _not_ contain any business logic. It listens to state changes from Providers and calls methods on them.
- **Business Logic Layer (State Management) :** (`lib/providers/`)
  - Implemented using `provider` and `ChangeNotifier`.
  - Contains all business logic (e.g., cart calculations, login validation, order processing).
  - Acts as the "middle-man" between the UI and the Data Layer.
- **Data Layer :** (`lib/data/`, `lib/models/`)
  - **Service (`DatabaseService.dart`) :** A singleton class that acts as the single source of truth for all database operations. It encapsulates all SQL queries (`CREATE`, `SELECT`, `INSERT`, `UPDATE`, `JOIN`, etc.) and handles the `sqflite` logic.
  - **Models (`lib/models/`) :** Plain Old Dart Objects (PODOs) like `User`, `Product`, `OrderHeader` that define the data structures. They include `fromMap()` and `toMap()` methods for serialization/deserialization.
  - **Data Source :** The local `BakeryApp.db` SQLite file.

This structure is initialized in `lib/main.dart`, which sets up the global `ThemeData` and registers all providers using `MultiProvider` at the root of the application.

---

## 🚀 Getting Started

To run this project locally, follow these steps :

1.  **Clone the Repository**

    ```bash
    git clone https://github.com/bugkey24/bakery-mobile-app.git
    cd bakery-mobile-app
    ```

2.  **Install Dependencies**

    ```bash
    flutter clean
    flutter pub get
    ```

3.  **Configure Platform Permissions (Crucial!)**
    This project requires location permissions to function.

    - **Android :**
      Open `android/app/src/main/AndroidManifest.xml` and add the following lines inside the `<manifest>` tag (before `<application>`):

      ```xml
      <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
      <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
      ```

    - **iOS :**
      Open `ios/Runner/Info.plist` and add the following keys and strings inside the main `<dict>` tag:
      ```xml
      <key>NSLocationWhenInUseUsageDescription</key>
      <string>This app needs access to your location to set the delivery address.</string>
      <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
      <string>This app needs access to your location to set the delivery address.</string>
      ```

4.  **Run the App**

    ```bash
    flutter run
    ```

5.  **Database & Seeding Note**

    - The database (`BakeryApp.db`) is created **on the first run** of the app.
    - The `_onCreate` function in `DatabaseService.dart` seeds the database with minimal data (1 admin, 1 buyer, 1 sample product).
    - If you need to re-run the seeding process, you **must completely uninstall the app** from your emulator or device to delete the old database file.

6.  **Login Credentials**
    The following dummy accounts are created on the first run:
    - **Admin :**
      - **Username :** `admin`
      - **Password :** `admin123`
    - **Buyer :**
      - **Username :** `buyer`
      - **Password :** `buyer123`

---

## 🧑‍💻 Author

- **BugKey**
