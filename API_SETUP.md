# EdgeScholar API Setup Guide

## ⚠️ Security Notice
**NEVER commit your API keys to Git!** This project uses environment variables to keep your keys secure.

## Quick Setup

### Step 1: Get Your Perplexity API Key
1. Go to https://www.perplexity.ai/
2. Sign up or log in to your account
3. Navigate to API settings
4. Generate a new API key
5. Copy the key (it starts with `pplx-`)

### Step 2: Configure Your API Key

#### Option A: For Running the App (Recommended)
Run the app with your API key:
```bash
flutter run --dart-define=PERPLEXITY_API_KEY=pplx-your-actual-key-here
```

#### Option B: For Local Development Only
**Warning: Don't commit these changes!**

1. Open `lib/services/api_service.dart`
2. Find line ~10: `defaultValue: 'YOUR_API_KEY_HERE',`
3. Replace `YOUR_API_KEY_HERE` with your actual API key
4. Do the same in `lib/screens/perplexity_insights_dialog.dart` around line 30

⚠️ **Important**: Add these files to your local git ignore before making changes:
```bash
git update-index --assume-unchanged lib/services/api_service.dart
git update-index --assume-unchanged lib/screens/perplexity_insights_dialog.dart
```

#### Option C: VS Code Launch Configuration
Create/update `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "EdgeScholar",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=PERPLEXITY_API_KEY=pplx-your-actual-key-here"
      ]
    }
  ]
}
```

### Step 3: Build the App

For iOS:
```bash
flutter build ios --dart-define=PERPLEXITY_API_KEY=pplx-your-actual-key-here
```

For Android:
```bash
flutter build apk --dart-define=PERPLEXITY_API_KEY=pplx-your-actual-key-here
```

## Current API Model
EdgeScholar uses the `sonar` model from Perplexity AI for:
- Research paper search
- AI-powered comparisons
- Insights generation

## Troubleshooting

### "API key not set" warning
If you see this warning, make sure you're passing the `--dart-define` flag or have set the default value locally.

### API returns 401 Unauthorized
Your API key is invalid or expired. Generate a new one from Perplexity.

### API returns 400 Bad Request
Check that you're using the correct model name (`sonar`).

## Security Best Practices
✅ Use environment variables or build-time defines  
✅ Add sensitive files to `.gitignore`  
✅ Rotate API keys regularly  
✅ Use different keys for development and production  

❌ Never commit API keys to version control  
❌ Don't share keys in public repositories  
❌ Don't hardcode keys in source files (without using environment variables)

## Need Help?
Check the Perplexity AI documentation: https://docs.perplexity.ai/
