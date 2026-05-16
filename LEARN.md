# LEARN.md — Binance clone study guide

Companion to RESEARCH.md (product/UX captures). This document is about the **engineering side** — what you need to understand before writing each piece of code, in the order you'll build things.

Format: each chapter is built like a short textbook chapter. **Concept → Why it matters → What to research → What to decide → Self-check questions.** If you can answer the self-check without guessing, you're ready to write code for that piece.

---

## How to use this file

- Read the chapter for the feature you're about to build.
- Do the "What to research" items — open the Binance docs, the package docs, read a bit of source.
- Answer the self-check questions in your head (or in a notebook).
- Only *then* start coding that piece.
- Skip chapters you don't need yet. Come back when you do.

Chapters build on each other — Chapter 2 assumes Chapter 1.

---

# Chapter 1 — Foundations

Stuff that applies to the whole project. You've already scaffolded most of this; this chapter is so you understand **why** each piece exists.

## 1.1 Clean Architecture in one page

**Concept.** Three concentric rings:

```
┌──────────────────────────────────────┐
│  Presentation (UI + Bloc)            │
│  ┌────────────────────────────────┐  │
│  │  Domain (entities + contracts) │  │
│  │  ┌──────────────────────────┐  │  │
│  │  │  Data (DTOs + datasource │  │  │
│  │  │  + repo impl)            │  │  │
│  │  └──────────────────────────┘  │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

**Dependency rule:** arrows only point **inward**. Domain knows nothing about Data or Presentation. Presentation depends on Domain (interfaces), not on Data (implementations).

**Why it matters.** Lets you swap the Binance API for a mock/testnet/fake without touching UI or Bloc. Lets you test Bloc without a network.

**What to research.**
- Uncle Bob's original "Clean Architecture" post (just the diagram + dependency rule).
- `dartz` — `Either<Failure, T>` for typed error returns instead of throwing.

**What to decide per feature.**
- What lives in `domain/entities/` — the **shape** of the concept as your app uses it (plain Dart, no JSON annotations).
- What lives in `data/models/` — the **wire format** from Binance (JSON-annotated, often wider than the entity).
- Where conversions happen — **DTO → Entity** in the repository impl, never in Bloc.

**Self-check.**
- If Binance renames `priceChangePercent` to `priceChange24h` tomorrow, which files do you touch? (Answer: only DTO + repository impl's mapper. Entity, Bloc, UI untouched.)
- Can a widget directly call `Dio.get('/api/v3/ticker/24hr')`? Why not?

---

## 1.2 Bloc (not Cubit) as state management

**Concept.** A Bloc is a stream of states driven by a stream of events. You `add(Event)` → the Bloc's `on<Event>` handler runs → it calls `emit(NewState)` → listeners rebuild.

```
UI ──add(Event)──► Bloc ──emit(State)──► UI rebuilds
```

**Why Bloc over Cubit here.** You already know Bloc from your Solflare clone. Consistency > minor simplicity.

**What to research.**
- `flutter_bloc` docs: `Bloc`, `BlocProvider`, `BlocBuilder`, `BlocListener`, `BlocConsumer`, `MultiBlocProvider`.
- The difference between `BlocBuilder` (rebuilds UI) and `BlocListener` (side effects like snackbars, navigation).
- `buildWhen` / `listenWhen` — rebuild throttling.

**Key patterns you'll use.**
- **States:** model them as a sealed class (or `sealed class` + subclasses) — `Initial`, `Loading`, `Loaded`, `Error`. Compile-time exhaustive `switch` in the UI.
- **Events:** also sealed — `LoadMarkets`, `RefreshRequested`, `FilterChanged`, `TickerReceived`. Each is a request to the Bloc.
- **Side effects vs state:** if it's data the UI displays, put it in state. If it's a one-shot (snackbar, navigation), emit a marker state OR use `BlocListener` + a flag.

**Self-check.**
- What's the difference between "I emit a new state" and "I navigate to a new screen"? Which goes through state, which through listener?
- If your state is a list of 500 tickers and one ticker's price changes, do you `emit` a new list every tick? (Yes — but with `Equatable` and `buildWhen`, UI only rebuilds what needs to.)

---

## 1.3 Dependency Injection with get_it

**Concept.** Instead of constructing objects where you use them (`final bloc = MarketsBloc(MarketsRepositoryImpl(Dio()))`), you register them once and look them up.

```dart
getIt.registerLazySingleton<MarketsRepository>(
  () => MarketsRepositoryImpl(getIt()),
);
getIt.registerFactory(() => MarketsBloc(getIt()));
```

**Why it matters.** Tests swap the registration (`registerSingleton<MarketsRepository>(FakeRepo())`). Production and test paths stay identical.

**What to research.**
- `get_it` — `registerSingleton`, `registerLazySingleton`, `registerFactory`. Know when to use each.
- `injectable` — generates the registration code from annotations. Optional. You can also hand-write a `configure_dependencies()` function.

**What to decide.**
- Singleton (one instance forever) — repositories, Dio, WS client.
- Factory (new instance each `getIt()`) — Blocs (each screen gets a fresh one).
- LazySingleton — created on first lookup. Default choice.

**Self-check.**
- Why is a Bloc usually a `factory` and a repository usually a `lazySingleton`?
- Where in the app lifecycle should `configureDependencies()` be called?

---

## 1.4 Navigation with auto_route

**Concept.** Declare routes as annotated pages; a build-runner generates a type-safe router. Navigate via `context.router.push(HomeRoute())` instead of string paths.

**What to research.**
- `@RoutePage()` annotation on pages.
- `@AutoRouterConfig()` on the router class; `RootStackRouter` as base.
- `AutoTabsRouter` for tab shells (you use this in `shell_page.dart`).
- The `.gr.dart` `part of` file — understand that it's generated and you never edit it.

**Self-check.**
- When do you re-run `dart run build_runner build`? (Whenever you add/rename/delete a `@RoutePage`.)
- Why does the shell need `part of app_router.dart` access, not `import`? (The generated file is a `part of`, so route classes only exist inside that library.)

---

## 1.5 Theme system

**Concept.** Two `ThemeData` instances (light + dark). `MaterialApp.router` picks via `themeMode`. The cubit/bloc controls `themeMode` based on user preference + mode (Lite defaults light, Pro defaults dark per RESEARCH.md).

**What to research.**
- `ThemeData`, `ColorScheme`, `TextTheme`.
- `Brightness`.
- `Theme.of(context).colorScheme.primary` — how widgets read colors.
- `Theme.of(context).textTheme.titleLarge` — how widgets read text styles.

**What to decide.**
- Hard-coded colors (`Color(0xFFFCD535)`) vs scheme colors (`colorScheme.primary`). Rule of thumb: semantic colors (buy=green, sell=red) are literals in a tokens file; structural colors (bg, text, surface) come from the scheme.

**Self-check.**
- In Lite, the Buy CTA is yellow. In Pro, it's green. Why is that decision not a theme switch?
  (Answer: it's a **semantic** color per action, not per theme. Green means "buy" in both themes. The Buy button just always uses `AppColors.buy` — the fact that Lite's Trade FAB is yellow and Pro's Buy pill is green is because they're **different buttons**, not the same button re-themed.)

---

# Chapter 2 — Markets feature

The first real feature. Read RESEARCH.md's Lite Markets section before starting.

## 2.1 What a Ticker IS (domain entity design)

**Concept.** The `Ticker` entity describes what your app needs from a market row. Not what Binance sends — what your UI shows.

**What the Lite row shows** (from RESEARCH.md):
- Circular brand-coloured icon
- Name + ticker (e.g., "Bitcoin" / "BTC")
- 24h % change (colored green/red)
- Last price
- No sparkline

**What Pro shows in addition** (from RESEARCH.md §Pro Markets):
- Volume (subline)
- Fiat approximation ("$634.36" below "634.36 USDT")
- Leverage badge ("10x")
- Fire emoji for trending
- Base vs quote breakdown (`BNB/USDT`)

**What to research.**
- The Binance REST endpoint `/api/v3/ticker/24hr` response shape. You don't need to memorize it — just look at *what fields exist*:
  - `symbol` (e.g. `"BNBUSDT"`)
  - `lastPrice` (string!)
  - `priceChange` (string)
  - `priceChangePercent` (string)
  - `volume`, `quoteVolume`
  - `highPrice`, `lowPrice`
  - Plus others

- **`decimal` package** — why you never use `double` for prices. Run `0.1 + 0.2 == 0.3` in a Dart REPL if you've never seen floating-point sting.

**Key design question.** Should `lastPrice` on your entity be a `String`, `double`, or `Decimal`?
- `String` — matches wire format, no loss. But can't compare/sort without parsing.
- `double` — easy but lossy at edge cases.
- `Decimal` (from `decimal` package) — arbitrary precision, sorts correctly, but heavier.

**Rule for this project:** `Decimal` for any value that gets math done to it (prices, amounts). `String` is fine for display-only fields that never get computed on.

**What to decide for your Ticker entity.**
- Which fields?
- Types for each (`String` for symbol, `Decimal` for price, `double` OR `Decimal` for percent — your call).
- Does the entity know *how* to derive `baseAsset` / `quoteAsset` from `symbol`, or is that a helper elsewhere? (Binance just sends `"BNBUSDT"` — no separator. You need to know quote currency to split.)

**Self-check.**
- Could you sort a list of `Ticker`s by `priceChangePercent` if it's a `String`? (Yes — parse first. But you'd parse every comparison. Better to parse once at DTO→entity mapping.)
- What happens if you sum 1000 `double` prices? (Accumulated floating-point error. `Decimal` doesn't have this.)

---

## 2.2 What a TickerDTO IS (data layer model)

**Concept.** The DTO is the **wire format** — a faithful mirror of Binance's JSON. All `String` fields (because that's what Binance sends). Uses `json_serializable` to deserialize.

**Why separate from entity?** Binance may send 20 fields; you use 5. Binance may rename a field in a version bump. The DTO absorbs that churn; the entity stays stable.

**What to research.**
- `json_annotation` — `@JsonSerializable()`, `@JsonKey(name: 'priceChangePercent')`.
- `freezed` (optional for DTOs, stronger for entities with unions) — generates `copyWith`, `==`, `hashCode`, and serialization together.
- How to run `build_runner` to generate the `.g.dart` files.

**Key pattern.**

```dart
@JsonSerializable()
class TickerDto {
  final String symbol;
  @JsonKey(name: 'lastPrice') final String lastPrice;
  @JsonKey(name: 'priceChangePercent') final String priceChangePercent;
  // etc.

  TickerDto({...});
  factory TickerDto.fromJson(Map<String, dynamic> json) => _$TickerDtoFromJson(json);

  Ticker toEntity() => Ticker(
    symbol: symbol,
    lastPrice: Decimal.parse(lastPrice),
    priceChangePercent: double.parse(priceChangePercent),
  );
}
```

**Self-check.**
- Why does the DTO keep strings and the entity parses them? (Single parse point. Also, the entity being *typed* means Bloc/UI code can't forget to parse.)
- If the entity had all strings too, what bug could sneak in? (Comparing `"9.5" < "10.0"` lexicographically gives `false`. Sorting breaks.)

---

## 2.3 How to call the REST API (data source)

**Concept.** The datasource is the **only** place Dio/HTTP exists. It:
1. Makes the HTTP call.
2. Parses JSON.
3. Returns DTOs.
4. Throws typed exceptions on failure (which the repo catches and converts to `Failure`).

**What to research.**
- Binance REST base URLs (two options!):
  - `https://api.binance.com` — main, includes private endpoints.
  - `https://data-api.binance.vision` — **market-data-only mirror**. Use this for public data.
  - Why: keeps main API rate-limits for authenticated use; also no CORS issues.
- The `/api/v3/ticker/24hr` endpoint:
  - No params → returns array of ALL tickers (~2000 objects, ~500 KB).
  - `?symbol=BTCUSDT` → one object.
  - `?symbols=["BTCUSDT","ETHUSDT"]` (URL-encoded JSON array) → filtered array.
  - Weight: 2 for single, 80 for all. Know what that means for rate limits.

- `dio` package — `Dio`, `BaseOptions`, `Interceptors`, error mapping.

**What to decide.**
- Fetch-all-then-filter vs fetch-specific. Lite Markets shows ~20 pairs — does it make sense to pull all 2000? (Probably yes once, then update via WS. Don't fetch-filter on every load.)
- Timeout. Binance's docs don't say, but 15s is safe.
- Error classification — network timeout vs 429 rate limit vs 500 server vs JSON parse error. Each should map to a different `Failure`.

**What to research specifically for this feature.**
- What does Binance return on rate-limit hit? (HTTP 429, with headers `X-MBX-USED-WEIGHT-1M` and retry-after info. See RESEARCH.md §2.)
- What does a 418 mean? (IP ban. Read the docs.)

**Self-check.**
- If your datasource throws a `DioException`, who catches it? (The repository impl.)
- Why should the datasource not catch `DioException` itself? (Single responsibility. The datasource does HTTP; the repo does error semantics.)

---

## 2.4 Repository — the bridge

**Concept.** The repo:
1. Implements the `MarketsRepository` interface from `domain/`.
2. Calls the datasource.
3. Catches exceptions → returns `Left(Failure)`.
4. Maps DTOs → entities → returns `Right(List<Ticker>)`.

**The `Either<Failure, T>` pattern.**

```dart
Future<Either<Failure, List<Ticker>>> getMarkets() async {
  try {
    final dtos = await remote.fetchAllTickers();
    return Right(dtos.map((d) => d.toEntity()).toList());
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return const Left(NetworkFailure('Connection timed out'));
    }
    return Left(ServerFailure(e.message ?? 'Server error',
                              statusCode: e.response?.statusCode));
  } on FormatException catch (e) {
    return Left(ServerFailure('Bad response: ${e.message}'));
  }
}
```

**Why `Either` instead of throwing?** The method signature tells the caller "this can fail, and here are the failure types." The Bloc is forced to handle both branches — can't forget.

**What to research.**
- `dartz` package — `Left`, `Right`, `Either`, `fold`.
- Functional error handling pros/cons.

**Self-check.**
- If a repo method returns `Future<List<Ticker>>` (no `Either`), how does the caller know it can fail? (It doesn't, unless it reads the impl. Easy to forget try/catch.)
- What's wrong with returning `null` for errors? (Same — caller doesn't know why it failed, and can't distinguish "empty list" from "network dead.")

---

## 2.5 Markets Bloc — events, states, logic

**Concept.** The Bloc holds the list of tickers, handles load/refresh/filter events, and emits states the UI binds to.

**Minimum state machine for v1 (load-only):**

```
Initial ──LoadMarkets──► Loading ──success──► Loaded(tickers)
                                 └──failure──► Error(message)

Loaded ──RefreshRequested──► Loading ──► Loaded/Error
```

**Events you'll want eventually:**
- `LoadMarkets` — first load.
- `RefreshRequested` — pull-to-refresh.
- `FilterChanged(category)` — swap Favorites / Hot / Gainers (Lite sort chips).
- `TickerReceived(ticker)` — when WS push arrives (Chapter 3).

**States:**
- `MarketsInitial` — app start, before first load.
- `MarketsLoading` — fetching, spinner on screen.
- `MarketsLoaded(List<Ticker>, activeFilter)` — the normal state.
- `MarketsError(Failure)` — show retry UI.

**What to research.**
- The `sealed class` pattern for events and states in Dart 3.
- `Equatable` — why you must mix it in or override `==` on every state, or `emit` will silently drop "no-change" emits.
- Bloc `EventTransformer`s — `sequential` (default), `concurrent`, `droppable`, `restartable`. Matter later for search debouncing.

**Key gotcha.** If your state has `List<Ticker>`, `Equatable` compares lists by identity unless you use `ListEquality`. Use `EquatableConfig.stringify = true` in debug and print states to verify they actually change.

**Self-check.**
- Why is there both `Loading` AND `Loaded` state, not just `Loaded` with `isLoading: bool`? (You can do it either way. Sealed states let you switch-exhaustive in UI; boolean flags scale poorly when you add more "modes".)
- What happens in the Bloc if someone spams `LoadMarkets` 10 times while one is in flight? (Default `sequential` transformer queues them. You probably want `droppable` — ignore new ones while one's running.)

---

## 2.6 Markets page — binding UI to Bloc

**Concept.** The page is stateless. It provides a Bloc, and children consume it via `BlocBuilder` / `BlocConsumer`.

**Pattern.**

```dart
@RoutePage()
class MarketsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MarketsBloc>()..add(const LoadMarkets()),
      child: const _MarketsView(),
    );
  }
}

class _MarketsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketsBloc, MarketsState>(
      builder: (context, state) => switch (state) {
        MarketsInitial() || MarketsLoading() => const LoadingList(),
        MarketsLoaded(:final tickers) => MarketsList(tickers: tickers),
        MarketsError(:final message) => ErrorView(message: message),
      },
    );
  }
}
```

**What to research.**
- Dart 3 switch expression with sealed classes — compiler enforces exhaustiveness.
- `ListView.builder` vs `ListView.separated` vs `SliverList` — you'll want slivers when the Markets tab has headers + categories + list.

**What to decide.**
- Skeleton loading (shimmer) vs spinner — Binance uses shimmer. Ship with spinner first, add shimmer later.
- Empty state — what if Binance returns zero tickers? (Can't happen in practice but handle it — show "No markets found" instead of a blank screen.)

**Self-check.**
- Why `BlocProvider` in `MarketsPage` but `BlocBuilder` in `_MarketsView`? (Separation: page provides the Bloc lifecycle; view binds. Keeps the view easy to test without a full Bloc — just wrap it in a `BlocProvider.value` with a fake.)

---

## 2.7 What to research specifically before Chapter 2

Before writing any Markets code, make sure you can answer:

1. What's the URL and response shape of `/api/v3/ticker/24hr`?
2. What does a single entry of that response look like (fields + types)?
3. Why do we use `data-api.binance.vision` instead of `api.binance.com`?
4. What are the two main rate-limit headers Binance returns?
5. What's the difference in your code between "an entity" and "a DTO"?
6. What does `Either<Failure, T>` buy you over throwing exceptions?
7. How do you sort a list where the sort key is a `Decimal`?

If any answer is fuzzy, read that part of Binance docs + RESEARCH.md §2 before coding.

---

# Chapter 3 — WebSocket streaming

You've got Markets loading once via REST. Now you want prices to *move* on screen. Enter WebSockets.

## 3.1 Why WebSockets (not polling)

**Concept.** HTTP polling every 1s = 3600 requests/hour per user = rate-limit suicide at scale + laggy UI. A WebSocket = one persistent TCP connection, server pushes updates as they happen.

**What to research.**
- WebSocket basics — not HTTP-like (request/response), more like a phone call (open → talk freely → hang up).
- Binance WS base: `wss://data-stream.binance.vision` (market-data-only mirror).
- The two subscription modes:
  - **Single stream:** `/ws/btcusdt@ticker` — one stream per connection.
  - **Combined stream:** `/stream?streams=btcusdt@ticker/ethusdt@ticker` — multiple streams, messages wrapped in `{stream, data}`.

**What to decide.** You'll want combined streams (one connection, many streams). Subscriptions can be changed *after* connecting via `SUBSCRIBE` / `UNSUBSCRIBE` JSON messages.

## 3.2 Which stream to use for live Markets

**Stream options for tickers:**
- `<symbol>@ticker` — per-symbol 24h rolling stats, every 1s.
- `<symbol>@miniTicker` — per-symbol lightweight price+volume, every 1s.
- `!ticker@arr` — **array of ALL tickers that changed in last second**, every 1s.
- `!miniTicker@arr` — same but lightweight.

**Rule of thumb for Markets list:** use `!ticker@arr` once — you get every pair in one stream, no subscription management. When you drill into Coin Detail, subscribe per-symbol for finer-grained streams.

**What to research.**
- The `!ticker@arr` message shape — it's an array, each element matches the REST 24hr ticker payload.
- The `@trade` vs `@aggTrade` distinction (trade is every fill; aggTrade is aggregated by price level per 100ms).
- The 24h hard disconnect — Binance forces you to reconnect every 24 hours. Your reconnect logic MUST exist.

## 3.3 WS client architecture

**Concept.** A single `BinanceStreamClient` in `core/websocket/`. Everything else subscribes through it. Raw WebSocket never escapes `core/`.

**Responsibilities:**
1. Open + hold a WebSocket connection.
2. Handle subscribe/unsubscribe requests from upstream features.
3. Demultiplex incoming combined-stream messages to per-stream stream controllers.
4. Reconnect with exponential backoff on disconnect.
5. Resubscribe all active streams after reconnect.
6. Handle Binance's ping/pong (server pings every 3 min; pong within 10 min).

**What to research.**
- `web_socket_channel` package — `WebSocketChannel.connect`, `sink.add`, `stream`.
- Dart streams — `StreamController.broadcast`, why broadcast vs single-subscription.
- Exponential backoff with jitter (ensures many clients don't reconnect in sync after a Binance blip).

**Key pattern — subscription multiplexing.**

```
Features subscribe via a method: client.streamFor('btcusdt@trade')
  → returns Stream<TradeMessage> (filtered)
Client tracks { stream_name → count_of_subscribers }
When count goes 0→1: send SUBSCRIBE over WS.
When count goes 1→0: send UNSUBSCRIBE.
```

## 3.4 Bloc + streams — joining WS to Markets

**Concept.** MarketsBloc gets a new event: `TickerUpdated(Ticker)`. A long-running subscription to the WS stream pipes into `add(TickerUpdated(…))`. The Bloc merges the update into its current list.

**Key design choice — where does the subscription live?**
- **Option A (my default):** Bloc subscribes in its constructor, cancels in `close()`. Simple.
- **Option B:** A `MarketsStreamingUseCase` (StreamUseCase) that the Bloc injects. Cleaner layer separation but more plumbing.

**Why choose:** Option A for Lite (no real streaming complexity yet). Option B when you have 3+ features each streaming.

**Self-check.**
- What happens if your Bloc rebuilds the entire ticker list every second with 2000 entries? (UI stutter. You need `buildWhen` — only rebuild rows where the ticker actually changed. Or structure state as a `Map<String, Ticker>` and rebuild only diff'd rows.)
- What if the WS disconnects between updates? (Bloc doesn't care — the client reconnects and resubscribes silently. Only surface the WS state to UI if disconnect > N seconds.)

## 3.5 Price flash animation

**Concept.** When a price ticks up, the cell bg flashes green for 400ms. Ticks down = red. Core to the "feeling live" polish.

**What to research.**
- `AnimatedContainer` keyed on the last price.
- `TweenAnimationBuilder` for the fade-out.
- How to compare "new price vs old price" without holding old price in widget state (answer: it IS widget state; you stash it in a StatefulWidget).

---

# Chapter 4 — Coin Detail

Reached by tapping a Markets row. Shared shell, different content per Lite vs Pro.

## 4.1 Line chart (Lite) — the simplest thing that works

**What to research.**
- `fl_chart` — `LineChart`, `LineChartData`, `FlSpot`.
- Binance `/api/v3/klines` endpoint — candles with `[openTime, open, high, low, close, volume, closeTime, ...]`. For a line chart you only use close prices.
- Timeframe intervals Binance offers: `1s, 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M`.

**Lite uses:** 1H, 1D, 1W, 1M, 1Y. Map each to a Binance interval + limit:
- 1H → `1m` × 60
- 1D → `5m` × 288
- 1W → `1h` × 168
- 1M → `4h` × 180
- 1Y → `1d` × 365

**What to decide.**
- Line color = sign of period change (green up, red down). Compute once per fetch.
- Floating peak annotation — find the max `high` and place a label at that x.

## 4.2 Candlestick chart (Pro) — the harder one

**Concept.** Pro's chart has candles, MAs (MA60, etc.), volume panel below, indicator selector. Non-trivial.

**What to research.**
- `k_chart_plus` — supports candles, MAs, volume, MACD, RSI, KDJ, WR.
- Whether it supports every indicator Pro shows (`BOLL, SAR, AVL, SUPER`). If not, TradingView webview or custom painting.

**Phase 1 decision.** Ship Lite's line chart. Don't try Pro candles on day 1.

## 4.3 Info tab — CoinMarketCap data

**Concept.** Binance's public API does NOT expose rank, ATH/ATL, max supply, issue date. RESEARCH.md confirmed Binance uses CMC.

**What to research.**
- CoinMarketCap API free tier — endpoint `/v2/cryptocurrency/quotes/latest`, requires API key (free tier has rate limits).
- Alternative: CoinGecko (also free, no API key required on public endpoints).

**What to decide.** CMC (Binance parity) or CoinGecko (simpler). For a learning clone, CoinGecko's looser rate limits make iteration easier.

---

# Chapter 5 — Orderbook (Pro only, Phase 3+)

Hardest piece of the project. Done wrong, the book goes stale and shows impossible prices.

## 5.1 The canonical algorithm

Straight from RESEARCH.md §2:

1. Open WebSocket `<symbol>@depth` (or `@depth@100ms`).
2. **Buffer** incoming events without applying them.
3. Fetch snapshot via REST: `/api/v3/depth?symbol=BTCUSDT&limit=1000`.
4. Discard buffered events with `u < snapshot.lastUpdateId`.
5. Find the event where `U <= snapshot.lastUpdateId+1 <= u`. Apply it.
6. Apply every subsequent event in order.
7. **If any event's `U` isn't `previous u + 1`**, you have a gap — restart from step 1.

**Why it's tricky.**
- You're racing two data sources (REST snapshot vs WS diffs).
- Events can arrive before the snapshot completes.
- Network can drop a single diff and you'd silently diverge.

**What to research.**
- The Binance "How to manage a local order book correctly" doc (in the spot API docs).
- Run the algorithm on paper for 5–10 events before coding.

## 5.2 Isolate compute for hot pairs

**Concept.** BTCUSDT's orderbook gets ~100 diff events/sec at peak. Doing Map updates on the UI thread stutters.

**What to research.**
- `compute()` — runs a top-level function in an isolate.
- `Isolate.run` (Dart 3.0+) — more flexible.
- When the overhead of isolate crossing (message serialization) beats the cost of the compute itself.

---

# Chapter 6 — Auth / KYC

Can't be fully built without a backend. Everything here is **stubbed** for Phase 1.

## 6.1 What "stubbed" means

**Concept.** You build the UI flow end-to-end. The datasource returns fake success responses. No network call. When Phase 3 arrives, you swap the datasource impl for a real one. Nothing else changes.

## 6.2 State machine for the signup flow

From RESEARCH.md Lite signup:

```
identifier + consent → emailOtp → createPassword → welcome → kycStep1-8 → underReview → markets
```

Each transition is an event + state in an `AuthBloc` (or `SignupBloc`). The Bloc holds the in-flight draft (`SignupDraft { email, passwordHash, nin, ... }`) as it moves forward.

## 6.3 Liveness SDK

**Concept.** You don't build this. You integrate Sumsub/Jumio/Veriff. The intro screen (rules + Continue) is yours; everything after Continue is the SDK's UI.

**What to research.**
- Sumsub Flutter SDK docs.
- Platform-channel basics (the SDK is native; you call it via method channels).

**Phase 1 decision.** Stub this entirely. Show the intro screen, tap Continue, fake a 3-second delay, proceed to Confirm Information with dummy data.

---

# Chapter 7 — Trade entry (spot order form)

Post-auth feature. Hits authenticated Binance endpoints → requires the backend proxy.

## 7.1 Order form state

**Fields that compose an order:**
- Side (Buy / Sell)
- Symbol (the pair from Coin Detail or Trade tab)
- Order type (Limit / Market / Stop-Limit / OCO / Trailing / Iceberg)
- Price (empty for Market)
- Amount (in base currency)
- Flags: TP/SL attach, Reduce-Only (futures), Time-in-Force (GTC/IOC/FOK/PostOnly)

**What to research.**
- `POST /api/v3/order` — the endpoint. Requires signing.
- Symbol filters from `/api/v3/exchangeInfo` — `PRICE_FILTER.tickSize`, `LOT_SIZE.stepSize`, `MIN_NOTIONAL`. Your form MUST validate against these.
- `HMAC-SHA256` signing — it happens in your proxy, not the app. But understand what's being signed (query string + timestamp).

## 7.2 Why you need a backend

RESEARCH.md §2 covers this. Short version: shipping the API secret in the app = anyone decompiling the APK drains the account.

**Minimal proxy** — a Cloudflare Worker with:
- Env var: Binance API key + secret (testnet for dev).
- Endpoint: `POST /trade/order` → accepts order params from app → signs → forwards to Binance → returns result.

**What to research.**
- Cloudflare Workers (free tier, cold-start < 50ms).
- Supabase Edge Functions (alternative, tied to your auth).

---

# Appendix A — Decimal safety

Things that bite you with `double`:

```dart
0.1 + 0.2 == 0.3  // false
1e20 + 1.0 - 1e20  // 0.0, should be 1.0
```

Binance sends prices as strings deliberately. Parse straight into `Decimal`:

```dart
final price = Decimal.parse(json['lastPrice'] as String);
```

Arithmetic:

```dart
price * Decimal.parse('1.5')  // works
price * 1.5                   // error, or use price.multiply(Decimal.parse('1.5'))
```

Formatting for display:

```dart
price.toStringAsFixed(2)  // "631.45"
```

**Self-check.** What's the right type for a 24h percent change (values like `-0.15`, `+11.26`)? (`double` is fine here — percentages with 2 decimals don't meaningfully suffer float error. But keep prices Decimal.)

---

# Appendix B — Caching strategy

Per RESEARCH.md §2:

- `exchangeInfo` (symbols, filters, rate limits): 1–6 hour cache. Hit on app start.
- Klines: cache CLOSED klines aggressively in Hive by `(symbol, interval, openTime)`. Current (in-progress) kline never cached.
- `!ticker@arr` stream: always fresh, never cached — each WS message replaces.
- Orderbook: never cache across sessions. Rebuild on every app open.
- Recent trades: ring buffer of last 500/symbol in memory.

**What to research.**
- Hive (or `hive_ce`) basics — typed boxes, adapters.
- Cache invalidation — simpler than distributed (single user), but you still need TTLs.

---

# Appendix C — Testing pyramid

Follow the same clean-arch ring:

**Domain (entities, usecases):** pure unit tests. No Flutter dependency. Fast, many.

**Data (repositories, datasources):** unit tests with `mocktail`. Mock Dio responses, assert correct DTO→Entity mapping and correct `Failure` on errors.

**Presentation (Bloc):** `bloc_test` package. Given an initial state, add events, assert emitted states.

**Widget tests:** pump the page with a fake Bloc, assert expected text/finders.

**Integration tests (patrol):** real app, real navigation, fake data layer. Tests cross-feature flows.

**Rule of thumb.** 70% Bloc + domain tests, 20% widget, 10% integration. Not the other way around.

---

# Appendix D — Common pitfalls

1. **`setState` inside a Bloc `builder`.** Crashes on rebuild. Never do it.
2. **Bloc `emit` after `close()`.** Throws. Use `emit.isDone` guard for long-running handlers.
3. **`Equatable` list comparison.** List identity, not deep equality. Fix with `ListEquality.equals` or `Equatable.stringify`.
4. **WebSocket reconnect that resubscribes *all* streams.** If you forget to resubscribe, the connection is open but receives nothing.
5. **Not using `autoDispose` equivalent.** In Riverpod it's auto; in Bloc, the `BlocProvider.create` gives a bloc that dies with the widget — but if you `getIt<Bloc>()` as singleton, it lives forever. Know which you want.
6. **Decimal-to-double drift.** `price.toDouble()` for one comparison and suddenly your sort is off by epsilon. Avoid.
7. **Forgetting `build_runner` after adding a `@RoutePage`.** Editor shows `HomeRoute` undefined. Fix: run codegen.

---

# Chapter 8 — Square (news feed, Lite)

The first feature where **Binance has no API for the data**. This chapter is shorter than the others because the architecture pattern is already familiar — what changes is the data source and how you design the entity when you're not mirroring a Binance payload.

## 8.1 Why this chapter is different

Every previous feature pulled from Binance REST/WS. Square is different: Binance Square is a private, signed-in social product. The public endpoints don't exist. The internal `bapi/composite/...` endpoints the web app calls aren't documented, fingerprint-gated, and will 403 in production — not safe to ship against.

**Implication for design.** The entity isn't shaped by a Binance DTO. You design `SquarePost` around what the UI needs (per RESEARCH.md §Square), and the DTO mirrors whatever third-party provider you pick. If you swap providers later, the entity stays — only the DTO + mapper change.

**Self-check.**
- If the entity should mirror what the UI shows (not the wire format), what's left for the DTO to do? (Be the exact shape of the third-party response, so the parser doesn't fight it.)

## 8.2 Picking the provider

**Recommended: CryptoCompare News** (`https://min-api.cryptocompare.com/data/v2/news/`).
- Free tier ~100k calls/month with an API key.
- Returns `imageurl`, `source`, `categories`, `tags`, `published_on`, `body` — maps cleanly to the Lite Square card.
- Stable, documented, single endpoint.

**Alternative: CryptoPanic** — has a votes/engagement signal that's closer to Square's social feel, but a thinner free tier. Use as a *secondary* later if you want the action-row counts to feel alive.

**What to research.**
- CryptoCompare News API docs — endpoint, params, response shape.
- Where the API key goes (query string `?api_key=...` is simplest; header is also supported).
- Rate-limit headers and how to surface a friendly error.

**What to decide.**
- Single provider for v1. Don't merge feeds yet — each provider has its own pagination contract and that fight isn't worth it on day one.

## 8.3 What a SquarePost IS (domain entity)

What the Lite card shows (RESEARCH.md):
- Avatar + username + relative time + dismiss X
- Body text with `$TICKER` cashtags (yellow)
- Optional hero image
- Ticker pill (symbol + % change) under the image
- Action row: comments, reposts, likes, views, share

**Entity fields.**
- `id` — provider-scoped string.
- `author` — name + avatarUrl. (CryptoCompare gives `source_info.name` + `source_info.img`.)
- `publishedAt` — `DateTime` (CryptoCompare sends unix seconds — convert at DTO→entity).
- `body` — plain text with `$TICKER` substrings intact.
- `imageUrl` — nullable String.
- `tickerMentions` — `List<String>` parsed once from body at mapping time. Don't re-parse in widgets.
- `categories` — `List<String>` for tab routing.
- `sourceUrl` — for "Read more" / external open.

**Key design question.** The ticker pill needs a % change. The third-party news API doesn't provide it. Two options:
- **A — Show a static pill** with whatever the provider gives (often nothing). Pill becomes decorative.
- **B — Cross-feature lookup**: if the mentioned ticker exists in `MarketsBloc`'s loaded map, render the pill with live %. Otherwise omit. *Recommended.* Re-uses data you already have, no extra request.

**What to research.**
- Dart regex syntax for `\$([A-Z]{2,10})\b` to parse cashtags.
- `RichText` + `TextSpan` for inline-coloured cashtags in the card body.

**Self-check.**
- Why parse cashtags at DTO→entity time instead of in the widget? (Parse-once. The widget rebuilds on every scroll tick — regex on every rebuild is wasted CPU.)
- If CryptoCompare renames `imageurl` to `image_url` tomorrow, which files change? (DTO + mapper. Entity, Bloc, UI untouched — same rule as Markets.)

## 8.4 The five tabs — what to build vs stub

| Tab | Real Binance | Your v1 |
|---|---|---|
| Discover | Algorithm-mixed feed | CryptoCompare default (no category filter) |
| Following | Posts from followed accounts | **Stub** — empty state ("Sign in to follow creators"). No social graph in Phase 1. |
| Hot | Engagement-sorted | Sort by `published_on desc`, take top 20. You have no engagement signal. |
| News | News-category only | CryptoCompare `categories=Markets|Trading|Regulation` |
| Academy | Binance educational LMS | **Stub** — empty state. Not a feed problem. |

**Why stubbing is fine.** RESEARCH.md captures these as flows you haven't observed end-to-end yet. Building real Following requires auth + social graph, which is Chapter 6 work. Don't pre-build it.

**What to research.**
- CryptoCompare's `categories` query param — what category names are valid, how they combine.
- `DefaultTabController` + `TabBar` + `TabBarView` in Flutter.

**What to decide.**
- One Bloc with tab-index in state, or one Bloc per tab? Per-tab is simpler — each tab owns its own cursor + cache. Pick per-tab.

## 8.5 Square Bloc — events & states

**Events.**
- `SquareLoadRequested(category)` — first load when tab mounts.
- `SquareRefreshRequested` — pull-to-refresh.
- `SquareLoadMore` — pagination via CryptoCompare's `lTs` (last-timestamp cursor).

**States (sealed).**
- `SquareInitial`
- `SquareLoading`
- `SquareLoaded(posts, isLoadingMore, hasReachedEnd)`
- `SquareError(failure)`

**What to research.**
- `EventTransformer.droppable` — for refresh (ignore spam taps while one is in flight).
- `EventTransformer.sequential` — for `LoadMore` (queue, don't drop).
- CryptoCompare's cursor pagination — pass `lTs=<oldest_published_on>` to fetch older.

**Self-check.**
- On tab switch, do you refetch or reuse posts? (Reuse if you cached; refetch only on pull-to-refresh. Saves API quota.)
- What if the user yanks the refresh handle 5 times in a second? (`droppable` collapses those into one in-flight request.)

## 8.6 UI shape — page → tabs → list → card

```
SquarePage (StatelessWidget)
├── AppBar (search icon)
├── TabBar (5 tabs)
└── TabBarView
    └── SquareFeed(category)         × 5  (each provides its own Bloc)
        ├── RefreshIndicator
        └── ListView.separated
            └── SquarePostCard       (or EmptyTabPlaceholder for Following/Academy)
                ├── Header row (avatar, name, time, dismiss)
                ├── RichText body (cashtags coloured)
                ├── Optional image
                ├── Ticker pill (if mention is in Markets map)
                └── Action row
+ FloatingActionButton (yellow + with badge — "coming soon" snack on tap)
```

**What to research.**
- `cached_network_image` — non-negotiable for image scrolling perf.
- A relative-time formatter — either the `timeago` package or hand-roll one. Hand-rolling teaches more.

**What to decide.**
- Image placeholder — shimmer skeleton vs solid grey. Solid first, shimmer later.
- Empty state copy for Following/Academy — write it once, share across both via a small `EmptyTabPlaceholder` widget.

## 8.7 What to research specifically before Chapter 8

Before writing any Square code, make sure you can answer:

1. What's the URL and response shape of CryptoCompare's `/data/v2/news/`?
2. What does a single article object look like (fields + types)?
3. How do you authenticate (API key in query string vs header) and how is the key kept out of git?
4. How does CryptoCompare's `lTs` pagination cursor work?
5. What categories are valid in the `categories` query param?
6. How do you write a Dart regex that captures `$TICKER` cashtags (2–10 uppercase letters, word-boundary)?
7. How do you cross-reference a ticker from a Square post with the Markets Bloc's loaded tickers — without coupling Square's bloc to Markets' bloc? (Hint: read-only access via `MarketsBloc.state` or a dedicated `MarketsLookup` interface registered in `get_it`.)

If any answer is fuzzy, read the CryptoCompare docs + RESEARCH.md §Square before coding.

---

# How this document grows

Each time we tackle a new feature:
- I'll add (or you'll ask me to add) a new chapter *before* we write code.
- You read it, research what's needed, then build.
- If the build surfaces something we didn't anticipate, we back-fill it into the chapter.

Treat this file as a living syllabus, not a static doc.
