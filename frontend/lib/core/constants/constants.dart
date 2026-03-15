const String newsAPIBaseURL = 'https://newsapi.org/v2';
const String newsAPIKey = 'ff957763c54c44d8b00e5e082bc76cb0';
const String countryQuery = 'us';
const String categoryQuery = 'general';
const String kDefaultImage = "https://via.placeholder.com/400x200.png?text=No+Image";

// AI providers — pass keys via --dart-define at build/run time
const String kOpenRouterApiKey = String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');
const String kOpenRouterBaseUrl = 'https://openrouter.ai/api/v1';
const String kOpenRouterModel = 'nvidia/nemotron-3-super-120b-a12b:free';
const String kGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');