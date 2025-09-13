# Take Note - Flutter Notes App

A modern note-taking application built with Flutter, Supabase, and Riverpod.

## Features

- ✅ **Authentication**: Sign up, sign in, sign out with Supabase Auth
- ✅ **Notes CRUD**: Create, read, update, delete notes
- ✅ **Search & Filter**: Real-time search by title and content
- ✅ **Pin Notes**: Pin important notes to the top
- ✅ **Undo Delete**: 5-second undo functionality
- ✅ **Offline Support**: Hive local storage with sync
- ✅ **Responsive Design**: Works on mobile and desktop

## Architecture

- **MVVM Pattern**: Clean separation of concerns
- **Riverpod**: State management
- **Supabase**: Backend as a Service (Auth + Database)
- **Hive**: Offline storage
- **Material Design 3**: Modern UI

## Setup

### 1. Clone the repository
```bash
git clone <repository-url>
cd take_note
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Environment Configuration
Create a `.env` file in the root directory:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key-here
```

### 4. Supabase Setup
1. Create a new Supabase project
2. Enable Authentication
3. Create the `notes` table:
```sql
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  content TEXT,
  is_pinned BOOLEAN DEFAULT FALSE,
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own notes" ON notes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notes" ON notes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notes" ON notes
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notes" ON notes
  FOR DELETE USING (auth.uid() = user_id);
```

### 5. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── constants/     # App constants
│   ├── errors/        # Custom exceptions
│   ├── network/       # Network utilities
│   └── storage/       # Local storage
├── models/            # Data models
├── services/          # API & Storage services
├── viewmodels/        # Riverpod providers
├── views/             # UI screens
└── shared/            # Shared widgets & theme
```

## Security

- ✅ Environment variables for sensitive data
- ✅ Row Level Security (RLS) in Supabase
- ✅ User-specific data access
- ✅ Secure authentication flow

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.