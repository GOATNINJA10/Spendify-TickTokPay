## Spendify Expense Tracker App
<!-- ![spendify_bg](https://github.com/user-attachments/assets/07e5c3c3-f463-4c25-8f2f-34820a92d602) -->

## Introduction
  This repository contains the source code for Spendify, a comprehensive expense tracker app built using Flutter. 
  Spendify helps users manage their finances by tracking income and expenses, providing detailed insights into spending patterns, 
  and offering advanced tools for budgeting, financial planning, and seamless payment processing through TickTokPay integration.

## Features  
  1) **Expense Tracking**: Record income and expenses with detailed descriptions and categories
  2) **Data Visualization**: Visualize income and expense data using interactive graphs and charts
  3) **Smart Categorization**: Automatic categorization of expenses with custom category support
  5) **Budget Planning**: Set monthly budgets and receive alerts when approaching limits
  6) **Filtering and Sorting**: Advanced filtering by date, category, amount, and payment method
  8) **Real-time Sync**: Cloud synchronization across all devices
  9) **Security Features**: Biometric authentication and data encryption
  10) **Multi-platform Support**: Available for Android, iOS, and Web platforms
  12) **Custom Reports**: Generate detailed financial reports and insights

## Technologies Used
  - **Frontend**: Flutter (Dart)
  - **Database**: Supabase (PostgreSQL)
  - **Authentication**: Supabase Auth
  - **State Management**: GetX
  - **Payment Processing**: TickTokPay API integration
  - **Charts & Visualization**: FL Chart
  - **Local Storage**: Hive/SQLite
  - **Cloud Storage**: Supabase Storage
  - **Push Notifications**: Firebase Cloud Messaging
  - **Security**: Data encryption
  - **Deployment**: Mobile Application

## Setup

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- Supabase account for backend services

### Installation
1) Clone the repository:
   ```bash
   git clone https://github.com/GOATNINJA10/Spendify-TickTokPay.git
   ```

2) Navigate to the project directory:
   ```bash
   cd Spendify-TickTokPay
   ```

3) Install dependencies:
   ```bash
   flutter pub get
   ```

4) Configure environment variables:
   - Create a `.env` file in the root directory
   - Add your Supabase URL and API key
   - Add TickTokPay API credentials

5) Run the app:
   ```bash
   flutter run
   ```

### Configuration
- Update `lib/config/` files with your API keys
- Configure Supabase database schema using provided migration files
- Set up TickTokPay merchant account for payment processing

## Screenshots
*Coming soon - App screenshots will be added here*

## Architecture
The app follows Clean Architecture principles with the following structure:
- **Presentation Layer**: UI components and state management
- **Business Logic Layer**: Use cases and business rules
- **Data Layer**: Repository pattern with local and remote data sources

## API Integration
### TickTokPay Integration
- Secure payment processing
- Real-time transaction updates

### Supabase Backend
- User authentication and authorization
- Real-time data synchronization
- Secure cloud storage
- Database management

## Security Features
- **Data Encryption**: End-to-end encryption for sensitive data
- **Secure API Communication**: HTTPS with certificate pinning


## Performance Optimizations
- Lazy loading for large datasets
- Image caching and optimization
- Efficient state management with GetX
- Background sync for offline functionality

## Contributions
   Contributions are welcome! Please fork the repository and create a pull request with your changes. 
   If you encounter any bugs or issues, please open an issue on the GitHub repository.

## License
  This project is licensed under the MIT License - see the LICENSE file for details.

## Support
For support and questions:
- Create an issue on GitHub
- Documentation: [Wiki](https://github.com/GOATNINJA10/Spendify-TickTokPay/wiki)


