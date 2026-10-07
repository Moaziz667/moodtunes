# 🎵 MoodTunes - Music Mood Journal

A full-stack Flutter + Node.js + MongoDB application that helps you track your daily moods through music. Log your emotions, link them to songs, and visualize your mood patterns with beautiful statistics.

The infrastructure is provisioned with Terraform and the pipeline closes the loop: `terraform apply`
hands back the load balancer's DNS name, which is injected into the Flutter app's config before the
APK is built. Production releases go out as an Auto Scaling Group instance refresh behind a manual
gate.

![Architecture](assets/architecture.svg)

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
├── backend/                # Node.js + Express
│   ├── model/              # MongoDB schemas (MoodEntry, User)
│   ├── controller/         # Request handlers
│   ├── services/           # Business logic
│   ├── router/             # API routes
│   ├── terraform/          # AWS + MongoDB Atlas infrastructure
│   │   ├── alb.tf          # Load balancer and target group
│   │   ├── autoscaling.tf  # Launch template, ASG, scaling policies, alarms
│   │   ├── atlas.tf        # Atlas project, cluster, user, IP access list
│   │   └── main.tf         # VPC, subnets, security groups
│   └── Dockerfile
├── frontend/               # Flutter
│   ├── lib/
│   │   ├── main.dart       # App entry point
│   │   ├── loginPage.dart  # Login screen
│   │   ├── registration.dart
│   │   ├── dashboard.dart  # Main mood journal
│   │   └── config.dart     # API endpoints, written by CI
│   └── pubspec.yaml
└── .gitlab-ci.yml          # Seven-stage pipeline
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

| Dashboard | New entry | Statistics |
|---|---|---|
| ![Dashboard](assets/screens/dashboard.png) | ![New entry](assets/screens/entry.png) | ![Statistics](assets/screens/stats.png) |

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

Seven stages in `.gitlab-ci.yml`:

| Stage | What happens |
|---|---|
| `infrastructure` | `terraform apply`, exporting the ALB DNS name, ASG name and Atlas connection details as job artifacts |
| `flutter_config` | Rewrites the app's `config.dart` with the ALB DNS from the previous stage |
| `mobile_build` | Builds the Android APK and publishes it to the GitLab Package Registry |
| `test` | Runs the Flutter test suite with coverage |
| `backend_build` | Builds and pushes the backend image |
| `staging` | Deploys to a VPS over SSH with Docker Compose |
| `production` | Manual gate, then an ASG instance refresh with a rolling strategy, polled to completion |
| `pages` | Publishes an index of every APK version from the registry |

Because the app's API endpoint comes from a Terraform output rather than a hardcoded constant, the
load balancer can be destroyed and rebuilt without touching application code.

Infrastructure is declared across `alb.tf`, `autoscaling.tf`, `atlas.tf` and `main.tf`. Scaling is
driven by CloudWatch CPU alarms at 70% and 30% with 300-second cooldowns, and the ASG uses ELB
health checks so an instance failing HTTP is replaced rather than merely restarted.

## 📄 License

MIT License
