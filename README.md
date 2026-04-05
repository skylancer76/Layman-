# Layman

Layman is a simplified news reader that covers business, tech, and startups. The core idea: take complex news and present it in plain, everyday language — in layman's terms.

> [!NOTE]
> This project has been developed as part of the assignment for the recruitment process at **BrewApps**.

<p align="center">
  <video src="./Layman/Assets.xcassets/Github%20Video.mov" width="300" controls></video>
</p>

## Features

- **Personalized News Feed**: Stay up to date with the latest business and technology articles from top sources.
- **AI-Powered Simplification**: Leverages the power of LLMs (Llama-3 via Groq) to convert dense, jargon-heavy news articles into easy-to-digest, 6-sentence summaries.
- **Chat with Layman**: Users can chat with an AI assistant specifically contextualized on the article they are reading. Ask follow-up questions to understand the topic deeper.
- **Save for Later**: Fully integrated bookmarking functionality. Save favorite articles to your profile and seamlessly access them later.
- **Authentication**: Fully functional, secure email/password authentication flow.
- **Modern UI/UX**: Designed using native SwiftUI elements mixed with modern Apple design principles, including frosted glass effects, clean typography, and intuitive swipe gestures.

## Tech Stack

- **Frontend**: SwiftUI (iOS 16+)
- **Architecture**: MVVM (Model-View-ViewModel) to ensure a clean separation of concerns and maintainability.
- **Backend & Database**: Supabase (PostgreSQL, Authentication)
- **AI Processing**: Groq API using the `llama-3.1-8b-instant` model for lightning-fast article summarization and contextual chat.
- **News Aggregation**: NewsData.io API for fetching live, real-world tech and business news.

## Architecture & Code Structure

The project strictly follows the **MVVM (Model-View-ViewModel)** architectural pattern. 

- **Models**: Plain Swift structs (`Article`, `SavedArticle`) conforming to `Codable` and `Identifiable` for seamless JSON parsing and SwiftUI List rendering.
- **ViewModels**: Handles the business logic and state management. Utilizes Swift's `async/await` for concurrency and `@MainActor` to ensure UI updates happen predictably on the main thread. State is globally distributed where necessary via `@EnvironmentObject`. 
- **Views**: Declarative SwiftUI views separated into domain-specific folders (`Auth`, `Home`, `ArticleDetail`, `Chat`, `Profile`, `Saved`).
- **Services**: Singleton network managers (`GroqService`, `NewsService`, `SupabaseService`) encapsulating all external API interactions to keep ViewModels lightweight and testable.

## Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ Simulator or Device
- Swift Package Manager (SPM)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository_url>
   cd Layman
   ```

2. **Open the project in Xcode**
   Open the `.xcodeproj` file. Dependencies (Supabase Swift SDK) will resolve automatically via Swift Package Manager.

3. **Configure Environment Variables**
   Ensure your `Info.plist` is populated with your specific API keys:
   - `GROQ_API_KEY`
   - `NEWS_API_KEY`
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

4. **Build and Run**
   Select your preferred iPhone simulator or plugged-in device in Xcode and hit `Cmd + R` to build and run the application.

[!IMPORTANT]
The current AI functionality in the app is powered by Groq (Llama-3.1-8B-Instant) using the free-tier capabilities. Paid or higher-tier features are not currently enabled, which may occasionally impact the quality, depth, or professional tone of some article summaries and responses.
