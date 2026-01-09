# Friends Only App — Project Summary

This Flutter project implements an AI assistant called “Oracle” that acts as a voice-forward, device-integrated concierge with strong safety and consent design. Below is a concise summary to aid external review (e.g., Gemini) without navigating the full tree.

## Core Capabilities

- Voice assistant (Flutter TTS + speech-to-text) across multiple screens.
- Device control via `DeviceControlService`:
  - Calls: launch `tel:` URIs, contact lookup via `contacts_service`.
  - SMS: launch `sms:` with prefilled body via `url_launcher`.
  - Permissions: `permission_handler` used for contacts/phone/mic/sms.
- Live Web Search via `WebSearchService` (DuckDuckGo JSON API) with advisory responses.
- Travel/Booking via `TravelBookingService`:
  - Detects booking intent (flights/services), gathers missing details,
  - Searches cheapest options, summarizes choices,
  - On confirmation, can place a call to complete booking.
- Payments Guardrails:
  - Double verbal confirmation required prior to any payment using stored cards.
  - First: “Are you sure…?” Second: “Final check…?”
- Phone Call Participation (`PhoneCallInterceptor`):
  - Listens and detects pauses; can inject natural responses using TTS.
  - Intended to sound human to third parties.
- Legal Advocacy Persona (QC-style):
  - Structured reasoning (IRAC), cite when known.
- Guardian & Ethical Rules (System Prompt):
  - Multi-party addressing by name in every sentence.
  - User safety/financial success prioritized; redirect illegal/immoral requests to safe/legal alternatives.

## Key Files

- `lib/core/services/oracle_service.dart` — routing layer for chat input; integrates device control, booking, search, payment confirmation, and model calls.
- `lib/core/services/travel_booking_service.dart` — booking flows + payment consent copy.
- `lib/core/services/device_control_service.dart` — calls, sms, contacts + permissions; uses `url_launcher_wrapper.dart`.
- `lib/core/services/url_launcher_wrapper.dart` — safe wrappers (`tel:`, `sms:`, urls).
- `lib/core/services/phone_call_interceptor.dart` — call monitoring + pause-response.
- `lib/core/services/web_search_service.dart` — DuckDuckGo API search wrappers.
- `lib/features/splash/splash_screen.dart` — intro voice and UI entry.

## Notable Design Choices

- Consent-first device control with explicit permission checks.
- Strong UX rules in the system prompt (names in every sentence, guardian rule).
- Pragmatic platform calls via `url_launcher` for dialer/SMS.
- Web search kept keyless to simplify setup (DuckDuckGo).

## Dependencies (selected)

- flutter_tts, speech_to_text, contacts_service, permission_handler,
  url_launcher, http, shared_preferences.

## Current Gaps / Next Steps

- Phone call audio capture/transcribe may require deeper native integration (Android Telecom/CallKit) beyond current listener approach.
- TTS voice selection on Windows can be limited by platform.
- Add UI flows for booking confirmations and payment double-confirm states.
- Audit keys/credentials; replace with env/secret management.

## Suggested Review Prompts

- “Summarize product value and differentiators vs Siri/Alexa/ChatGPT.”
- “Draft ICPs and a 12-month GTM plan for consumer and SMB.”
- “Propose pricing tiers (Free/Pro/Teams) with value metrics.”
- “Create a 10-slide investor deck outline with narrative.”
