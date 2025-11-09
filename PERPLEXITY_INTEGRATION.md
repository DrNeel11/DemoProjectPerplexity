# Field-Data Assistant - 100% Perplexity AI Powered

## 🚀 Overview

The Field-Data Assistant is **completely powered by Perplexity AI** for all research capabilities - from paper discovery to analysis and comparison.

## 🔑 API Key Configuration

⚠️ **Security Notice**: API keys should NEVER be committed to Git!

Your Perplexity API key should be configured using environment variables or build-time defines.

See [API_SETUP.md](API_SETUP.md) for detailed setup instructions.

```dart
// Configure using --dart-define
flutter run --dart-define=PERPLEXITY_API_KEY=your_key_here
```

## ✨ 100% Perplexity-Powered Features

### 1. **🔍 Paper Search & Discovery** 
**Fully powered by Perplexity AI**
- Search for research papers directly through Perplexity's web-connected AI
- Finds the 5 most recent and relevant papers
- Real-time search with 1-month recency filter
- Returns comprehensive paper details including:
  - Title, authors, year, journal
  - Full abstract
  - Detailed methodology
  - Key results
  - Study limitations
  - Dataset information
  - DOI and URLs

**Implementation:** `_searchPapersWithPerplexity()` function uses Perplexity to search and structure paper data

### 2. **🧠 AI Research Insights**
**Fully powered by Perplexity AI**
- Click **"AI Insights"** button after entering a query
- Generates comprehensive research overview:
  - Current state of research
  - Key methodologies being used
  - Recent breakthroughs
  - Future research directions
- Includes citations from recent sources
- Beautiful modal dialog with real-time loading

### 3. **📊 AI-Powered Paper Comparison**
**Fully powered by Perplexity AI**
- Automatically compares all retrieved papers
- Deep analysis covering:
  - Methodological approaches and innovations
  - Dataset characteristics and sample sizes
  - Results and performance metrics
  - Key limitations and trade-offs
  - Overall assessment of contributions
- Uses enhanced prompts for detailed comparisons
- Temperature: 0.3 for consistent, factual analysis

### 4. **📄 Paper Summaries & Details**
**All extracted by Perplexity AI**
- Every paper's methodology, results, and limitations come from Perplexity
- Structured JSON extraction from AI responses
- Intelligent text parsing as fallback
- All displayed with "Powered by Perplexity AI" badges

## 🎯 What This Means

**Every piece of research data you see in the app comes from Perplexity AI:**
- ✅ Paper titles and authors - Perplexity
- ✅ Abstracts - Perplexity  
- ✅ Methodologies - Perplexity
- ✅ Results - Perplexity
- ✅ Limitations - Perplexity
- ✅ Dataset info - Perplexity
- ✅ Comparisons - Perplexity
- ✅ Insights - Perplexity

**No other APIs are used for research data.** Only fallback to mock data if Perplexity is unavailable.

## 📡 API Endpoints Used

### Perplexity Chat Completions (ONLY API Used)
```
POST https://api.perplexity.ai/chat/completions
```

**All Requests Use:**
- Model: `llama-3.1-sonar-small-128k-online` (web-connected, real-time)
- Temperature: 0.2-0.3 (consistent, factual responses)
- Max tokens: 300-2000 (depending on task)
- Search recency filter: `month` (latest research only)
- Citations: Enabled where applicable

## 🎯 Usage Examples

### 1. Search for Papers (Perplexity-Powered)
1. Enter a research topic (e.g., "quantum computing applications")
2. Click **"Search"** button
3. Perplexity AI searches the web and returns 5 recent papers
4. Each paper fully analyzed and structured by AI
5. See purple "Powered by Perplexity AI" banner at top

### 2. Get Deep Research Insights
1. Enter a topic in the search box
2. Click **"AI Insights"** button (purple, with sparkle icon)
3. Beautiful modal opens with comprehensive analysis
4. Includes citations from recent sources
5. All generated in real-time by Perplexity

### 3. Compare Papers Intelligently  
1. After searching, scroll to "AI-Powered Comparative Summary"
2. Perplexity analyzes all papers and generates:
   - Methodological comparisons
   - Dataset analysis
   - Results comparison
   - Limitations assessment
3. More detailed than simple text extraction

### 4. Offline Mode
- App uses cached Perplexity results when offline
- Previously fetched data remains available
- Clear offline indicator shown

## 🔧 Configuration Options

### Adjusting AI Response Length
In `api_service.dart`, modify:
```dart
'max_tokens': 800,  // Increase for more detailed responses
```

### Changing Temperature
```dart
'temperature': 0.3,  // Lower = more factual, Higher = more creative
```

### Search Recency
```dart
'search_recency_filter': 'month',  // Options: day, week, month, year
```

## 🎨 UI Components

### Perplexity Insights Dialog
- Beautiful gradient header with lightbulb icon
- Real-time loading indicator
- Formatted insights with citations
- Responsive design

### Branded Elements
- Purple gradient badges showing "Perplexity AI" branding
- AI sparkle icons (✨) throughout the UI
- Professional, modern design

## 📊 Technical Architecture

### Paper Search Flow (100% Perplexity)
```
User enters query
    ↓
Click "Search"
    ↓
searchPapers() called
    ↓
_searchPapersWithPerplexity() 
    ↓
POST to Perplexity API with structured prompt
    ↓
Perplexity searches web + analyzes papers
    ↓
Returns JSON array of 5 papers
    ↓
Parse & display with Paper cards
    ↓
Generate comparison via Perplexity
    ↓
Display results screen
```

### AI Insights Flow (100% Perplexity)
```
User enters query
    ↓
Click "AI Insights"
    ↓
PerplexityInsightsDialog opens
    ↓
POST to Perplexity API
    ↓
Comprehensive research analysis
    ↓
Display in modal with citations
```

### Comparison Flow (100% Perplexity)
```
Papers retrieved
    ↓
generateComparison() called
    ↓
Build detailed prompt with all paper data
    ↓
POST to Perplexity API
    ↓
AI analyzes & compares methodologies
    ↓
Display in comparison section
```

## 🔐 Security Notes

- ✅ API keys are now secured using environment variables
- ✅ Never commit API keys to version control
- ✅ Use `--dart-define` for build-time configuration
- For production, consider:
  - Backend API proxy
  - Key rotation policies
  - Rate limiting

## 🚀 Running the App

```bash
cd my_flutter_app
flutter run -d 382FB4BC-7197-4CF2-89E2-4A52041C2099
```

## 📱 Screens with Perplexity Integration

1. **Home Screen**: AI Insights button
2. **Search Results**: AI-powered comparison section
3. **Insights Dialog**: Dedicated AI insights modal

## 💡 Future Enhancements

- [ ] Voice input for queries
- [ ] Export insights as PDF
- [ ] Compare specific papers side-by-side
- [ ] Topic clustering with AI
- [ ] Personalized research recommendations
- [ ] Multi-language support

## 📞 Support

For issues or questions about the Perplexity integration, check:
- Perplexity API Docs: https://docs.perplexity.ai/
- Flutter HTTP package: https://pub.dev/packages/http

---

**Built with** ❤️ **using Perplexity AI and Flutter**
