# AI Article Generation — Setup Guide

The app includes an AI-powered article generation feature for journalists. From the **New Article** screen, tap **Generate with AI**, describe your idea, and the AI writes the full title, description, content, and thumbnail for you.

---

## Architecture Overview

The feature is designed to be provider-agnostic. Two abstract interfaces isolate the AI implementation from the rest of the app:

```
AiTextProvider   ← implemented by OpenRouterService (default) or GeminiService (swap)
AiImageProvider  ← implemented by LoremFlickrService (free, no key required)
```

Swapping AI providers requires changing **one line** in `lib/injection_container.dart` — the `AiTextProvider` registration. No other file needs to change.

---

## Default Provider: OpenRouter (Free Tier)

[OpenRouter](https://openrouter.ai) is an API gateway that routes requests to multiple LLMs. The app uses `meta-llama/llama-3.3-70b-instruct:free`, which is free with no usage cost.

### 1. Get an API key

1. Go to [openrouter.ai](https://openrouter.ai) and create a free account.
2. Navigate to **Keys** → **Create Key**.
3. Copy the key (starts with `sk-or-...`).

### 2. Enable provider data sharing (required for free models)

Free models on OpenRouter are served by third-party providers (Nvidia, Venice, etc.). By default, new accounts may have privacy restrictions that block all available providers, causing a **404 "No endpoints available"** error.

To fix this:

1. Go to [openrouter.ai/settings/privacy](https://openrouter.ai/settings/privacy).
2. Enable **"Allow providers to train on my data"** (or the equivalent data-sharing toggle).
3. Save.

> This is required to use the free tier. Paid models with BYOK (bring your own key) bypass this restriction.

### 2. Pass the key at run/build time

The key is never hardcoded — it is injected via `--dart-define`:

```bash
# Development
flutter run -d chrome --dart-define=OPENROUTER_API_KEY=sk-or-your-key-here

# Production build
flutter build web --dart-define=OPENROUTER_API_KEY=sk-or-your-key-here
```

> **Why `--dart-define`?** It keeps secrets out of source control. The constant is resolved at compile time and is never written to any file in the repo.

> **What happens if you omit `--dart-define=OPENROUTER_API_KEY`?** The app starts normally. The constant defaults to an empty string, so all other features work without issue. The error only surfaces when a journalist taps **Generate with AI** — the request is sent with an empty bearer token, OpenRouter returns **401 Unauthorized**, and the UI shows an error message. No crash occurs.

---

## Swap to Gemini (Paid)

### 1. Get a Gemini API key

1. Go to [Google AI Studio](https://aistudio.google.com) and create a project.
2. Generate an API key.

### 2. Change one line in `injection_container.dart`

Open `lib/injection_container.dart` and find the AI providers block (~line 133):

```dart
// AI providers — swap AiTextProvider registration to switch models
sl.registerSingleton<AiTextProvider>(OpenRouterService(sl()));   // ← current
// sl.registerSingleton<AiTextProvider>(GeminiService(sl()));    // ← Gemini
```

Comment out the OpenRouter line and uncomment the Gemini line:

```dart
// sl.registerSingleton<AiTextProvider>(OpenRouterService(sl())); // ← disabled
sl.registerSingleton<AiTextProvider>(GeminiService(sl()));        // ← active
```

### 3. Pass the Gemini key at run/build time

```bash
flutter run -d chrome --dart-define=GEMINI_API_KEY=your-gemini-key-here
```

> Both `GeminiService` and `OpenRouterService` implement the same `AiTextProvider` interface, so no other code changes are needed.

---

## Image Generation: LoremFlickr (Always Free)

Thumbnails are sourced from [loremflickr.com](https://loremflickr.com) using topic keywords returned by the LLM (`imageKeywords` field). No API key is required. The browser loads the URL directly — no HTTP request is made by the app.

To replace it with a real image-generation API (e.g. Replicate, Stability AI):

1. Create a new class that implements `AiImageProvider` in `lib/features/ai_article/data/data_sources/`.
2. In `injection_container.dart`, replace `LoremFlickrService()` with your new class.

---

## Constants Reference

Defined in `lib/core/constants/constants.dart`:

| Constant | Description |
|----------|-------------|
| `kOpenRouterApiKey` | Injected via `--dart-define=OPENROUTER_API_KEY=...` |
| `kOpenRouterBaseUrl` | `https://openrouter.ai/api/v1` |
| `kOpenRouterModel` | Model used for article generation (`nvidia/nemotron-3-super-120b-a12b:free`) |
| `kChatModel` | Model used for AI Chat (`nvidia/nemotron-3-super-120b-a12b:free`) |
| `kGeminiApiKey` | Injected via `--dart-define=GEMINI_API_KEY=...` |

To change either model, update the corresponding constant in `constants.dart`. A list of available models is at [openrouter.ai/models](https://openrouter.ai/models).

> **Note on free model availability:** Free models are subject to upstream rate limits and provider routing. If a model returns 429 (rate limited) or 404 (no endpoints), switch to another free model in `constants.dart`. The `nvidia/nemotron-3-super-120b-a12b:free` model has proven reliable as it routes through Nvidia's own infrastructure.
