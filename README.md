# NexSplit 💸

NexSplit is a modern, AI-powered iOS application designed to make splitting bills effortless. By leveraging Google's Gemini 2.5 Flash model, NexSplit can instantly scan receipts, extract line items, and help you split expenses with friends seamleslly.

Built with **SwiftUI** and **SwiftData**, it offers a premium, native iOS experience with support for dark mode, dynamic type, and smooth animations.

## ✨ Features

- **🤖 AI Receipt Scanning**: Snap a photo or upload a receipt, and let Google Gemini extract items, prices, and quantities automatically.
- **📝 Smart Itemization**: Review and edit parsed items before splitting.
- **👥 Group Management**: Create groups for trips, roommates, or frequent hangouts.
- **💰 Flexible Splitting**: Assign specific items to individuals or split shared costs evenly.
- **📊 Expense Tracking**: Keep track of who owes what with a clear summary dashboard.
- **🌙 Dark Mode Support**: A beautiful UI that adapts to your system theme.

## 🛠 Tech Stack

- **SwiftUI**: For a declarative and responsive user interface.
- **SwiftData**: For local persistence of bills, friends, and groups.
- **Google Generative AI SDK**: For powerful receipt analysis and data extraction.
- **Observation Framework**: For modern state management.

## 🚀 Getting Started

### Prerequisites

- Xcode 15+
- iOS 17+
- A Google Gemini API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/saish-dev/NexSplit.git
   cd NexSplit
   ```

2. **Configure your API Key**
   The project requires a Gemini API key to function. Create a `Secrets.swift` file in the `src` directory:

   ```swift
   // src/Secrets.swift
   import Foundation

   enum Secrets {
       static let apiKey = "YOUR_GEMINI_API_KEY_HERE"
   }
   ```
   *Note: `src/Secrets.swift` is Git-ignored to protect your API key.*

3. **Open the Project**
   Open `NexSplit.xcodeproj` in Xcode.

4. **Build and Run**
   Select your target simulator or device and hit **Run (Cmd+R)**.

## 📱 Screenshots

*(Add your app screenshots here)*

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
