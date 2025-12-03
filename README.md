# 🎵 MoodTunes - Music Mood Journal

A full-stack Flutter + Node.js + MongoDB application that helps you track your daily moods through music. Log your emotions, link them to songs, and visualize your mood patterns with beautiful statistics.

## ✨ Features

- **8 Mood Types**: Happy, Sad, Energetic, Calm, Angry, Anxious, Romantic, Nostalgic
- **Mood Intensity Scale**: Rate your mood from 1-10
- **Song Tracking**: Link songs (title + artist) to each mood entry
- **Personal Notes**: Add context to your mood entries
- **Statistics Dashboard**: 
  - Mood distribution pie chart
  - Top songs per mood
  - Daily streak tracking
  - Average mood score
- **Spotify-Inspired UI**: Dark theme with green accents (#1DB954)
- **User Authentication**: Secure login/registration with JWT
- **Cross-Platform**: Works on Web, Android, iOS

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Google Fonts** - Poppins typography
- **fl_chart** - Beautiful charts and graphs
- **JWT Decoder** - Token authentication

### Backend
- **Node.js** - Server runtime
- **Express.js** - Web framework
- **MongoDB** - Database
- **bcrypt** - Password hashing
- **JWT** - Authentication tokens

### DevOps
- **AWS** - VPC, ALB, ASG, EC2
- **MongoDB Atlas** - Cloud database
- **Terraform** - Infrastructure as Code
- **GitLab CI/CD** - Automated deployment
- **Docker** - Containerization

## 📁 Project Structure

```
flutterapp/
├── MoodTunes_Backend/      # Node.js backend
│   ├── model/              # MongoDB schemas (MoodEntry, User)
│   ├── controller/         # Request handlers
│   ├── services/           # Business logic
│   ├── router/             # API routes
│   ├── terraform/          # AWS infrastructure
│   └── Dockerfile
└── moodtunes_frontend/     # Flutter frontend
    ├── lib/
    │   ├── main.dart       # App entry point
    │   ├── loginPage.dart  # Login screen
    │   ├── registration.dart
    │   ├── dashboard.dart  # Main mood journal
    │   └── config.dart     # API endpoints
    └── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Node.js (16+)
- MongoDB
- Docker (optional)

### Backend Setup
```bash
cd MoodTunes_Backend
npm install
node index.js
```

### Frontend Setup
```bash
cd moodtunes_frontend
flutter pub get
flutter run -d chrome  # or android/ios
```

## 📊 Database Schema

### MoodEntry Collection
```javascript
{
  userId: ObjectId,
  mood: String,           // happy, sad, energetic, etc.
  moodScore: Number,      // 1-10
  song: {
    title: String,
    artist: String,
    albumArt: String,
    spotifyUrl: String
  },
  note: String,
  date: Date,
  createdAt: Date,
  updatedAt: Date
}
```

## 🎨 Color Palette

- Background: `#121212`
- Surface: `#1E1E1E`
- Primary: `#1DB954` (Spotify Green)
- Secondary: `#1ED760`
- Text: `#FFFFFF`

## 📱 Screenshots

*Coming soon - New MoodTunes UI screenshots*

## 🔧 API Endpoints

```
POST /registration          # Create account
POST /login                 # User login
POST /createMoodEntry       # Log mood + song
POST /getMoodEntries        # Get user's moods
POST /getMoodStats          # Get statistics
POST /deleteMoodEntry       # Delete entry
POST /getEntriesByMood      # Filter by mood type
```

## 🌐 Deployment

Deployed using GitLab CI/CD with:
- Terraform Cloud for infrastructure
- AWS (VPC, ALB, ASG, EC2 t3.micro)
- MongoDB Atlas M0 Free Tier
- Docker Hub for images
- GitLab Pages for APK downloads

## 📄 License

MIT License

## 👨‍💻 Author

Built as a full-stack DevOps demonstration project
