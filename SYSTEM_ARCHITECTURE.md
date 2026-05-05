# System Architecture (LWC / interview)

## Overview
This repository contains a Flutter mobile application built around a **feature-first** structure with a clear separation between:

- **Presentation/UI** (`lib/screens`, `lib/features/*/presentation`)
- **Domain models** (`lib/features/*/domain`, `lib/models`)
- **Data access** (`lib/features/*/data`) with **Repository + API** abstractions
- **Cross-cutting infrastructure** (`lib/core/*`) such as networking, caching, and navigation

State management is implemented using **Riverpod**.

## High-level component map

- **App entry**
  - `lib/main.dart`
  - Initializes Firebase (best-effort) and FCM handlers, then runs `ProviderScope`.
  - App root widget: `MarinaApp` -> `MaterialApp(home: SplashScreen())`.

- **Core infrastructure** (`lib/core`)
  - **Networking**: `lib/core/network/*`
    - Centralized HTTP client setup (Dio/ApiClient)
    - Auth token injection and unauthorized handling
  - **Caching**: `lib/core/cache/*`
    - `CacheManager` with shared cache keys and JSON read/write
  - **Navigation**: `lib/core/navigation/*`
    - Route observer (`route_observer.dart`) used to monitor navigation

- **Feature modules** (`lib/features`)
  - Each feature generally follows:
    - `data/`  (API + Repository)
    - `domain/` (models)
    - `presentation/` (Riverpod controllers/providers)

- **Screens/widgets** (`lib/screens`)
  - Flutter UI routes and shared widgets.
  - Often consume feature controllers/providers.

## Key architectural patterns

### Riverpod controllers
The project uses Riverpod providers heavily:

- `Provider` for stateless dependencies (e.g., repositories)
- `AsyncNotifierProvider` / `FutureProvider` for async state and endpoint-backed state
- `StateProvider` for simple local/global counters (e.g., cart badge count)

Controllers commonly provide:

- `build()` -> initial data fetch (often cache-first)
- `retry()` -> force refresh

Example: Purchase history
- Provider: `purchasesControllerProvider`
- Type: `AsyncNotifierProvider<PurchasesController, List<Purchase>>`
- Pattern: cache-first initial value + background revalidation

### Repository + API layering
Most networked features use two layers:

- **API** (thin wrapper over `ApiClient`)
  - Responsible for endpoint path + HTTP method only
- **Repository** (business/data orchestration)
  - JSON parsing / normalization
  - Cache read/write
  - “cache-first + background revalidate” strategies

This keeps UI code and controllers free of endpoint details.

### Cache-first with background revalidation
Some controllers follow this pattern:

1. Load cached response (fast UI)
2. Trigger a background re-fetch
3. Update state when fresh data arrives

This is used in:

- Purchase history (`features/history`)
- Tickets (`features/tickets`)

## Authentication & session lifecycle

### Auth state
Auth is managed via `lib/features/auth/presentation/auth_controller.dart`.

Key concepts:

- Session/token storage is handled in the auth data layer.
- Auth state includes an `isOtpAvailable` flag returned by the backend to control whether OTP verification is required.

### OTP gating (`isOtpAvailable`)
The backend may indicate whether OTP is available for the environment/tenant.

- When `isOtpAvailable == true` and the user is not verified, the UI routes to `VerifyMail`.
- When `isOtpAvailable == false`, verification screens are skipped and the app proceeds.

### Guest mode and unauthorized behavior
Networking includes an unauthorized handler designed to **avoid forcing login** for guest users.

Protected actions (booking, add-to-cart, profile/cart navigation) are typically gated in UI with dialogs that route to sign-in.

## “History” and “Event” endpoints after login
Two endpoint-backed areas are designed to refresh after login:

- **Purchase history**: `features/history` (`/purchases-history/...`)
- **Event/Ticket history**: `features/tickets` (tickets controller)

After a successful login (email/password or Google) that proceeds to dashboard, these providers are invalidated so they refetch with the newly available session tokens.

## Payments and bookings (conceptual flow)
The flow is implemented across:

- `features/bookings` (create booking / reservation)
- `features/payments` (initialize checkout, handle redirects)
- UI screens drive the process and on success invalidate related providers (tickets, purchases, cart state)

Typical flow:

1. Create booking -> receive `paymentId`
2. Initialize payment -> receive checkout URL + txRef
3. Open webview for payment
4. On success:
   - refresh tickets
   - refresh purchases
   - clear active payment id cache
   - reset cart count and invalidate cart items

## Notifications (FCM)
FCM is initialized in `main.dart`:

- Background handler registered best-effort
- In-app message handling shows a dialog and can navigate to `NotificationScreen`

## Project structure

- `lib/main.dart` (entry)
- `lib/core/`
  - `network/` (ApiClient, providers, auth interceptors, unauthorized handling)
  - `cache/` (CacheManager, keys)
  - `navigation/` (route observer)
- `lib/features/`
  - `auth/`, `bookings/`, `cart/`, `events/`, `history/`, `notifications/`, `payments/`, `points/`, `products/`, `profile/`, `tickets/`, `users/`
- `lib/screens/` (UI routes)
- `lib/utils/` (helpers like toasts, transitions, spacing)

## Where to make changes safely

- Add/modify endpoints:
  - Update the feature `data/*_api.dart`
  - Update the repository parsing/caching in `data/*_repository.dart`
  - Expose it via a controller/provider in `presentation/*_controller.dart`
  - Consume in UI (`screens/*`) via `ref.watch(...)`

- Change auth/verification behavior:
  - `features/auth/presentation/auth_controller.dart`
  - `screens/login_screen.dart`, `screens/signup_screen.dart`, `screens/signin_screen.dart`, `screens/widgets/verify_mail.dart`

- Change unauthorized/guest behavior:
  - `core/network/*` unauthorized flow
  - UI gating dialogs in screens

## Assumptions / invariants

- `Info.plist` uses `$(FLUTTER_BUILD_NAME)` and `$(FLUTTER_BUILD_NUMBER)`.
- Controllers that read `authControllerProvider` assume a valid user exists; only call those in authenticated contexts.
- Cache keys are shared; changes to cache schema should bump/clear relevant stored JSON.
