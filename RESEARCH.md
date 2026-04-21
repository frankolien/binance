# Binance Clone — Research

Foundational research compiled before building. Four areas: product surface, APIs, visual design, and the Flutter stack.

**Important:** Binance ships as two distinct product modes — **Lite** and **Pro** — with a user-switchable toggle (usually in Profile / Settings). They share backend but diverge heavily in UI, navigation, and feature surface. Sections 1 and 3 below cover **Pro** unless noted; section 0 below summarizes Lite specifically.

---

## 0. Binance Lite (simplified mode)

Lite is the onboarding / casual surface. Confirmed from user-supplied screenshots (2026-04-21).

### Navigation — 5 tabs
`Markets · Square · Trade (center, FAB-style swap icon) · Discover · Portfolio`

Differences from Pro:
- **No Futures tab.** No margin, no orderbook trading from within Lite.
- **Portfolio** replaces "Wallets."
- **Markets** is the landing tab (not Home).
- **Square** (social feed) is promoted to a primary tab.
- **Trade** is a center button that opens a bottom sheet, not a tabbed screen.

### Markets tab (Lite)
- Header: rounded-square Binance mark (yellow bg, black chevron) + search + QR scan + gift/rewards icon.
- Hero: **Est. Total Value** (eye toggle) + large balance + **Add Funds** pill button.
- Promo card: "Team Up with Binance — Invite Friends & Share $X in Y rewards."
- Sub-tabs: **Watchlist · Coin**.
- Sort chips: `Hot · Market Cap · Price ⇅ · 24h Change ⇅`.
- Row: circular brand-colored coin icon + name / ticker (left), 24h % change (colored) + price (right). No sparkline in Lite.

### Trade bottom sheet (Lite)
Opens when the center Trade button is tapped. Four actions only:
1. **Buy** — Buy crypto with USD (fiat on-ramp)
2. **Sell** — Sell crypto to USD
3. **Convert** — Swap currencies and trade instantly (the main trading primitive in Lite)
4. **Deposit** — Deposit with fiat and crypto currency

No limit / market / stop orders, no orderbook. Trading in Lite = Convert flow.

### Discover tab (Lite = Earn hub)
Sub-tabs: **Earn · Launchpool · Trading**.
- **Rewards Calculator** front and center: coin dropdown + amount field + term selector (Flexible / 15D / 30D / 60D / 90D) → "Estimated rewards in N years" + **Buy & Earn** pill CTA.
- **Recommendation** section: Flexible / Locked / ETH Staking sub-tabs, "Missed Rewards (asset-based) $0.00" yellow banner, product cards (e.g., Ethereum Max APR 1.47%, Catizen 19.53%, USDC 5.57%), "View More" link in yellow.

### Portfolio tab (Lite)
Replaces Pro's multi-sub-wallet structure with a single flat view:
- Title bar: "Portfolio" + history icon top-right.
- **Est. Total Value** (eye toggle) + balance.
- Two CTAs: **Take Out** (grey pill) + **Add Funds** (yellow pill).
- **Allocation** donut chart + legend (e.g., Ethereum 100%, Others <0.01%) with a toggle between line chart and donut views.
- **Hide 0 balances** checkbox + search icon.
- Flat asset list: icon + name / ticker + quantity + fiat value.

### Transaction History (Lite)
Accessed from the Portfolio history icon.
- Primary tabs (scrollable): `Deposits · Withdrawals · Buy · Sell · P2P · Pay · Convert` — flat by type, not by sub-wallet.
- Sub-toggle: `Crypto · Cash`.
- Filter funnel icon top-right, download icon for export.
- Contextual banner: "Deposits not arrived? Check solutions here →".
- Row: asset + timestamp (left), signed amount (green for +) + status (Completed / Pending) (right).

### Square tab (Lite = social feed)
Tabs: `Discover · Following · Hot · News · Academy` + search icon.
- Post card: avatar + username + time + dismiss X · body text with `$TICKER` cashtags (yellow) · optional TradingView chart image · ticker pill with % change below image · action bar: comments, reposts, likes, views, share.
- Floating yellow "+" FAB with notification badge for composing.
- "Square Assistant" message bubble appears as an in-feed system notification.

### Design specifics unique to Lite
- **Light theme by default** (Pro defaults to dark).
- **Fully rounded pill buttons** (Add Funds, Take Out, Buy & Earn, View More) — distinct from Pro's square 8-radius buttons.
- Heavier, larger typography on balance display — dominant hero.
- Circular coin icons with each token's brand color as background.
- Green gain color `#0ECB81`-ish, consistent with Pro.
- Yellow `#FCD535` for primary CTAs, selected sort chips, accent links, and the Trade FAB background.
- Trade FAB is a black rounded-square containing the yellow bidirectional-arrows mark.

### What Lite does NOT have (vs Pro)
- Futures, Margin, Options, Copy Trading, Trading Bots, P2P is present but buried, Orderbook spot trading, Advanced charts on coin detail, VIP/fee-tier surfaces, Launchpad (Launchpool only in Discover), NFT marketplace, Binance Card configuration depth, Tax tools, API key management, Sub-accounts.

### Mode toggle
Switch Lite ↔ Pro via Profile → Settings → Binance Lite / Binance Pro. Persists per-device.

### Splash screen (Lite)
- White background. Pure chevron mark + wordmark centered vertically.
- Mark: yellow `#FCD535` rotated square made of chevrons.
- Wordmark: "BINANCE" below mark, uppercase, heavy geometric sans (~weight 700–800), tight letter-spacing, same yellow.
- No tagline, no spinner, no version label.

### Logged-out Markets (Lite)
- Same chrome as logged-in (Binance mark + search + QR scan + gift icon).
- Replaces the balance hero with a **promo block**:
  - Heading: "Explore the World of Digital Assets!" (same weight/size as the logged-in balance display).
  - Right-side flat illustration: a figure running with a black flag bearing the Binance yellow mark.
  - Two full-width CTAs stacked side-by-side: **Log In** (grey pill, secondary) + **Sign up** (yellow pill, primary).
  - CTA order matches logged-in Portfolio's Take Out / Add Funds pair: secondary left, primary right.
- Markets list starts immediately below the divider — Watchlist / Coin sub-tabs + Hot / Market Cap / Price ⇅ / 24h Change ⇅ sort chips + coin rows.
- **Prices stream live even when logged out** — uses public WS tickers, no auth gate on market data.
- Bottom nav shows all 5 tabs — no disabled states, no hidden tabs. Gating happens at action-time (tapping Portfolio, Trade, favorite-star, etc. triggers a login prompt).
- Red loss color confirmed ≈ `#F6465D` from "-0.05%" Ethereum row.
- Small-price rendering: Lite shows full leading zeros (`$0.00000379` for PEPE), **not** subscript-zero notation as Pro does.

### Implementation pattern for auth-optional screens
Single `MarketsScreen` widget with a conditional hero slot: `BalanceCard` when authenticated, `UnauthPromo` when not. Header, bottom nav, list, and sort chips are shared. This pattern likely repeats on Portfolio (prompt login if unauthed) and Discover.

### Auth entry — Log in / Sign up (Lite)

Both auth entries are **bottom-sheet modals** overlaying Markets, not full-screen routes. Status bar + system chrome stay black around the top-rounded white sheet. The Markets screen stays mounted underneath.

**Shared structure:**
- Title top-left, large display weight.
- Single pill-shaped input field (grey fill `~#F5F5F5`, no border, full radius).
- Full-width yellow primary pill CTA labeled **Continue**.
- `or` text divider with hairlines either side.
- Outlined pill buttons for alternative providers (left icon + centered text).
- Yellow text links at the bottom for cross-navigation.
- All pills share full-radius (`~24px` on `~48px` height).

**Log in sheet:**
- Heading: "Log in".
- Top-right: close X only.
- Field label above: "Email/Phone number". Field supports pre-fill with clear-X.
- Alt options (3): **Continue with Passkey** (person-with-key icon), **Continue with Google** (multicolor G), **Continue with Apple** (black apple).
- Bottom yellow links stacked: **Create a Binance Account**, **Can't log in?**.

**Sign up sheet:**
- Heading: "Welcome to Binance".
- Top-right: **support headphones icon** + close X (support only shown on signup).
- Field placeholder: "Email/Phone (without country code)".
- Consent row below field, pre-checked: black filled rounded-square checkbox + "By creating an account, I agree to Binance's Privacy Notice." (yellow underlined link).
- Alt options (2): **Continue with Google**, **Continue with Apple**. **Passkey deliberately absent** (can't sign up with a credential that doesn't exist).
- Bottom yellow link row: **Sign up as an entity**  ·  **Log in** (separated by a lowercase grey "or").

**Flow pattern:**
- **Email-first single-step** — no password on the entry screen. Submitting Continue advances to a next step (likely OTP to email/phone, then password or 2FA setup).
- No SMS/Telegram/WeChat SSO in Lite (Pro has more).
- Biometric auth attaches post-login, not at entry.

**Implementation sketch:**
- Single `AuthSheet` widget with `mode: AuthMode.login | signup` enum. Differs only in heading, top-right icon set, consent row, passkey option, and bottom links.
- Present via `showModalBottomSheet(isScrollControlled: true, useSafeArea: true)`.
- The sheet **hosts a nested Navigator** — flow pages push/pop within it. Back arrow = intra-sheet nav, close X = dismiss entire sheet.

### Auth flow state machine (Lite)

```
Entry (Login or Sign up) → identifier input → Continue
  ├─ Backend: password exists → Password entry → 2FA → Done
  ├─ Backend: no password set → Alert dialog "You have not set up a password
  │  for this account..." → OK → Reset Password intro → Email OTP → New
  │  password → Done
  ├─ Passkey tap → WebAuthn platform prompt → Done
  └─ Google / Apple tap → OAuth → Done

Can't log in? → "Need help to log in?" branch selector
  ├─ "I Remember My Account" → Reset Password flow (same as above)
  └─ "I Forgot My Account" → Forgot Account Appeal
       ├─ Submit a New Appeal (async, manual review)
       └─ Check Previous Result (state-persisted)
```

### Screen-level details within the auth sheet

- **"No password" alert dialog** — white rounded card, centered yellow warning-triangle-in-yellow-circle icon, body copy, single full-width yellow OK pill. Background sheet gets ~50% black overlay + the background Continue button darkens to `~#B8971A` (disabled-yellow state = primary yellow at ~70% value).
- **Reset Password intro screen** — `←` back + `×` close header, thin-stroke shield-with-Binance-diamond illustration with green checkmark sticker overlay (~200px centered), title "Reset Password", masked identifier row with person-icon prefix (e.g., `fr***@gmail.com`), grey disclaimer body explaining 24-hour service restriction post-reset, **bottom bar with two 50/50 pills: grey "Cancel" + yellow "Continue"** (distinct from single-CTA screens — reserved for confirmation moments).
- **Email Verification screen** — title "Email Verification", body "Enter the 6-digit verification code sent to ***...***.", labeled field "Email Verification Code" with placeholder "Code Sent" + trailing (i) info icon (resend countdown likely replaces placeholder), full-width yellow Submit pill, yellow text link "Switch to Another Verification Method" (TOTP / SMS / Passkey fallback), footer "Protected by Binance Risk" with outlined shield icon — sensitive-flow trust signal.
- **"Need help to log in?" screen** — title + two filled-grey rounded cards (~12px radius, `~#F5F5F5` bg), each with icon left / title + caption / right `→`:
  - "I Remember My Account" — *Click here to start resetting your password*
  - "I Forgot My Account" — *I don't remember the email or phone number I used for my Binance account. Click here to submit an appeal.*
- **Reset Password (entry from "Can't log in?")** — title only, labeled input "Email/Phone number", full-width yellow "Next" pill. Simpler than the illustrated intro because the user hasn't typed an identifier yet.
- **Forgot Account Appeal screen** — title + subcopy "Please select the operation you want to perform.", two cards:
  - "Submit a New Appeal" (plus-in-square icon)
  - "Check Previous Result" — *Please only choose this if you have submitted a forgot account appeal recently.* (list-in-square icon)
  Implies async server-side manual review with state persistence.

### New Lite design tokens captured here

- **Disabled yellow**: `~#B8971A` (brand yellow at ~70% value). Used for the disabled Continue state when a dialog covers the sheet.
- **Success green accent**: `~#10B981` circle+checkmark sticker overlaid on illustrations.
- **Alert yellow icon**: warning triangle rendered in white on a solid yellow circle (~`#FCD535`).
- **Two-button bottom bar** pattern for confirmation screens: equal-width grey Cancel (left) + yellow Continue (right) pills in the safe-area footer.
- **"Protected by Binance Risk"** footer — outlined shield + label, shown on verification-code screens.
- **Option-picker card style**: filled `~#F5F5F5`, 12px radius, left icon (outlined, 24px) + title + grey caption stacked + trailing `→`. Used for branch selectors inside flows.
- **Flow illustration style**: thin-stroke black line art, large and centered, with a single-color accent sticker (green ✓ or yellow !) overlapping a corner. Used on security-step intros.

### Sign-up flow — post-identifier steps (Lite, captured 2026-04-21)

Progression after tapping Continue on the "Welcome to Binance" (sign-up) sheet with email identifier + pre-checked consent:

**1. Verify your email (signup variant)**
- Header: `← back` + `headphones support` + `× close` (3-icon chrome; back appears now that we're past entry).
- Title: "Verify your email".
- Subcopy: "A 6-digit code has been sent to {email} (the email is case insensitive). Please enter it within the next 30 minutes." → **explicit 30-min code TTL**.
- Field label "Verification Code" + placeholder **"Code Sent"** (doubles as send-status indicator) + trailing (i) info icon.
- Primary yellow **Continue** pill (button text is "Continue" here — **not** "Submit" as RESEARCH.md previously described for login's verification variant; those two screens likely both use "Continue" — flag for correction when login flow is re-captured).
- Yellow link: **"Didn't receive the code?"** — opens resend/switch-method options.
- **Absent here (present on login verification):** no "Switch to Another Verification Method" link, no "Protected by Binance Risk" footer. Signup verification is leaner than login's.
- Native iOS autofill works: keyboard surfaces "From Gmail {code}" chip above keys. Full qwerty keyboard (not numpad) — supports paste/autofill.
- **Caret color is brand yellow** (`#FCD535`), not system blue. Applies across all inputs — theming detail worth capturing globally.

**2. Create a password**
- Same 3-icon chrome (back + support + close).
- Title: "Create a password".
- Single password field, grey pill fill. Trailing icons: **eye-off** (visibility toggle) when empty; **clear-X + eye-off** pair when filled.
- **Live-validating rule list** under the field, each row = circle-check icon + text:
  - `8 to 128 characters`
  - `At least 1 number`
  - `At least 1 upper case letter`
  - Unmet = grey outline ✓. Met = **green filled ✓** (solid circle in success-green).
  - **No special-character requirement, no lowercase requirement** — only 3 rules.
- Primary yellow **Continue** pill (active immediately on focus, not gated — submission would presumably fail server-side if rules unmet, but UI doesn't disable the button on this screen).

**3. Welcome aboard!**
- Header: **close X only** — no back, no support. Signup is committed at this point; user cannot reverse to previous steps.
- Centered hero: **green filled ✓ circle** (`~#10B981`) with pale-green halo ring + **multi-color confetti sparks** (yellow, red, blue) radiating from 4 corners. Celebratory moment pattern.
- Title below hero: "Welcome aboard!" (display weight).
- Thin divider hairline below title.
- Prompt: **"Do you have an inviter? (Optional)"** centered.
- Two **outlined rounded-rectangle option cards** side-by-side: **Yes** / **No**. Equal width, ~56px tall, thin grey 1px border, no fill — a different button style from pill CTAs and from filled option-picker cards. Appears to be a **selectable segmented choice**, not auto-advance.
- **Bottom Next pill** (yellow, full-width) — separate from the Yes/No selection. User must tap an option, then tap Next. Referral capture is optional but advancing requires an explicit choice.

**4. Let's Get You Verified (KYC entry — Verified tier)**
- Thin **yellow step progress bar** at top (~2–3px height, grey track). Filled ~1/N — first step of a multi-step KYC flow. No numeric "1 of N" label.
- Header: **support headphones + close X** (no back — this is step 1 within its own sub-flow).
- Title: "Let's Get You Verified".
- Two dropdowns (grey pill fill, circular flag prefix + country name + chevron):
  - **Residence** — user's country of residence.
  - **Nationality** — user's passport nationality.
- Below Nationality: **"I have another nationality" checkbox** (unchecked: rounded-square grey outline).
- Section heading: **"Verify with BVN or NIN"** (locale-specific — this appears when Residence=Nigeria).
  - Radio pair: `● BVN` (selected — Bank Verification Number, 11-digit Nigerian) / `○ NIN` (National Identification Number).
  - Radio style: filled black dot in black outline = selected; grey empty circle = unselected. **Not themed yellow** — plain black/grey binary.
  - Empty text input below (accepts the BVN or NIN number).
  - Yellow link: **"Don't have BVN or NIN? Verify with ID documents"** — fallback to passport/driver's license flow.
- Legal footer: "By continuing, I agree to Terms of Use and Privacy Policy" with yellow inline links.
- **Continue button in a disabled-yellow state** — brand yellow at very low alpha (~20%) with greyed-out label. Distinct from the `~#B8971A` disabled-yellow used when a modal covers the sheet. Two separate "not interactable" visual treatments coexist in Lite.

### Country / Region picker (reusable bottom sheet)

Full-height bottom sheet overlaying the host screen (host dims behind).
- Title "Country / Region" + close X.
- Grey pill **Search** field with magnifier prefix.
- Scrollable list row: **circular flag icon** + country name + **native-language parenthetical** (e.g., `Albania (Shqipëri)`, `Armenia (Հայաստան)`, `Austria (Österreich)`, `Afghanistan (افغانستان)`, `United Arab Emirates (الإمارات العربية المتحدة)`).
- **List order is not strict A-Z** — observed: Andorra → UAE → Afghanistan → Antigua → Anguilla → Albania → Armenia → Angola → Argentina → Austria → Australia → Aruba. Possibly ordered by ISO country code (AD, AE, AF, AG, AI, AL, AM, AO, AR, AT, AU, AW — **confirms ISO-3166-1 alpha-2 ordering**, not by display name).
- Reusable component — same picker surely reappears for phone country code, fiat currency selector, etc.

### New Lite design tokens captured here (2026-04-21 batch)

- **Disabled-yellow variant A — modal overlay**: `~#B8971A` (yellow at ~70% value). Background button darkens while a dialog is up.
- **Disabled-yellow variant B — gated form**: brand yellow at ~20% alpha + greyed text. Used when a required input is empty on the current screen. **Two distinct disabled states — choose the right one per context.**
- **Brand-yellow caret**: all text inputs use `#FCD535` for the insertion caret (not system blue). Theming detail, applies globally.
- **Step progress bar**: ~2–3px yellow fill on grey track, pinned to top of multi-step flow screens (KYC, possibly 2FA setup, withdrawal flows). No numeric labels — pure visual progress.
- **Radio button**: filled black dot in black outline = selected; grey outline empty = unselected. Plain black/grey, not brand-themed.
- **Live-validating rule list**: circle-check icon + text rows beneath an input. Grey ✓ = unmet → green filled ✓ (`~#10B981`) = met. Used on password creation; pattern likely reused on any input with server-enforced constraints.
- **Celebratory hero**: green filled ✓ circle with pale-green halo + multi-color confetti sparks (yellow/red/blue) at 4 corners. Used at flow-completion moments (post-signup, likely post-KYC approval, post-first-deposit).
- **Outlined option card** (Yes/No segmented choice): thin 1px grey border, no fill, ~56px tall, rounded rectangle. Different from filled `#F5F5F5` option-picker cards (which have icon + title + caption + `→`). Outlined = binary/small-choice selection; filled = branch selector with subcopy.
- **Bottom-advance pattern on choice screens**: a selectable choice above + a separate yellow Next pill at the bottom. Choice doesn't auto-advance; explicit confirmation required.

### KYC flow — Verified tier (Lite, captured 2026-04-21)

Entered immediately after "Welcome aboard!" → Next. Thin **yellow step progress bar** pinned to top throughout (~2–3px on grey track). Observed bar fill positions suggest a **4-step model**.

**Step 1 — Let's Get You Verified (data entry)** — already described in the sign-up section above. Key interactions:

- **"I have another nationality" checked state** reveals a **Second Nationality** dropdown inline (dynamic form expansion, not a new screen). Checkbox renders as the same filled-black-square + white-✓ style as the signup consent checkbox — unchecked = outlined rounded-square, checked = filled black square (same component).
- **BVN vs NIN radio is mutually exclusive**; filled black dot = selected.
- **NIN entered value observed: `3575 361 5446`** — rendered 4-4-4 with spaces. Note: Nigerian NIN is actually 11 digits and BVN is 11 digits — this mock shows 12, but the **auto-space grouping (every 4 chars)** is the implementation pattern.
- **Floating scroll-to-top FAB**: yellow filled circular button with black up-arrow appears bottom-right when the form has scrolled. Distinct from the Trade center FAB (black rounded-square with yellow bi-arrows).
- **Continue gating**: disabled (yellow at ~20% alpha, greyed text) until the identifier field has content — doesn't appear to validate length/format client-side, just non-empty.

**Step 2 — Verifying Data (async interstitial)**
- Header: support headphones + close X (no back; cannot cancel mid-verification without dismissing entire KYC).
- Centered thin-stroke **ID-document illustration** (passport/form silhouette + person-icon + **yellow filled ✓ badge** overlapping bottom-right corner). Same illustration style as Reset Password's shield.
- Title: "Verifying Data".
- Subcopy: **"We are verifying your information with the public database."** → confirms BVN/NIN validates against **external government database** (not Binance's records) — explains latency.
- **"Estimated time:"** label + large tabular **"26s"** countdown. Binance shows a synthetic ETA instead of a spinner — trust-building pattern, likely reused for: deposit confirmations, withdrawal processing, Convert settlement, document review.
- No CTA; auto-advances on completion.

**Step 3 — Liveness Check (intro / rules)**
- Title "Liveness Check".
- Centered thin-stroke **face-scan illustration** — head/shoulders in oval capture frame with a horizontal scan line + yellow-fill chin/neck area.
- **Filled `~#F5F5F5` info card** titled "Please show your face clearly" with **diamond-bullet (`◆`)** rules list:
  - Your face and background will be recorded
  - Maximize screen brightness
  - Well lit area
  - No glasses, mask, hat
- Grey body disclaimer *below* the card (outside it): "Please be mindful that both your face and the surrounding background will be recorded during the verification." — repeats the recording warning for legal emphasis.
- Primary yellow Continue pill.

**Step 4 — Liveness capture (embedded third-party SDK takeover)**

**Binance delegates this to an external SDK** (UI fingerprint matches **Sumsub** — purple/blue sparkle-face badge bottom-right, hexagonal frame, blue success state). Do not reimplement in Flutter; wrap the SDK.

Observed sub-screens during capture:

1. **Framing — "Put your face in the oval"**
   - Full-bleed **dark background** (breaks out of the KYC sheet aesthetic entirely).
   - Close X top-left as a **grey circular button** (larger tap target for emergency exit).
   - Large white thin-stroke **oval** centered, filled with a bright radial white spotlight (screen functioning as illumination source for low-light capture).
   - Black pill tooltip near top of oval: "Put your face in the oval".
   - Tiny SDK brand badge bottom-right (purple/blue sparkle-face icon on white rounded-square).
2. **Challenge 1 — "Please nod your head"**
   - Background inverts to **full-bleed white** (screen = light source for subject's face).
   - **Hexagonal frame** (6-sided) replaces the oval once face is detected. Thin white border.
   - Live selfie-cam feed inside hex.
   - Close X top-right as a plain black X (no grey circle now that background is white).
   - Below hex: grey countdown `17s` + instruction `Please nod your head`.
3. **Challenge 2 — "Please turn your head"** (advances after nod passes)
   - **Hexagon border turns bright blue** — positive state signal (advancing to next challenge).
   - Countdown resets (observed `19s` after a 17s for previous challenge) — **per-challenge timer**, not one global countdown.
   - Instruction: "Please turn your head".
   - Blue is the **SDK's native accent color**, overriding Binance yellow. The embedded provider theme takes over inside the liveness screens.

Likely continues with additional challenges (smile, blink) before auto-returning to the KYC flow on success.

### New Lite design tokens captured here (2026-04-21 batch 2)

- **Scroll-to-top FAB**: yellow filled circle (`#FCD535`) with black up-arrow, bottom-right of long scrollable forms. Different from the Trade center-button FAB (black rounded-square with yellow bi-arrows).
- **Diamond bullet (`◆`)**: used in info-card rules lists (Liveness Check rules). Distinct from the circle-check live-validating rule rows (password creation) — circle-check = validates dynamically, diamond = static instructions.
- **Async ETA pattern**: centered illustration + title + subcopy + "Estimated time: Ns" countdown. Used instead of indeterminate spinners for async flows hitting external systems.
- **Yellow filled ✓ badge** on line-art illustrations (Verifying Data) — same shape/role as the green filled ✓ accent on the Reset Password shield, but yellow = "in progress / pending", green = "success / complete". Two-color semaphore for illustration-overlay accents.
- **Full-bleed camera takeover**: during liveness capture, the app leaves the sheet/rounded-corner aesthetic and goes edge-to-edge. Close-X style adapts to background (grey circle on dark, plain X on white).
- **Screen-as-illumination** pattern: full-white background during selfie capture to light the subject's face in low ambient light. Implementation: no dark UI on liveness capture screens.
- **Third-party SDK accent override**: the liveness provider uses its own accent color (bright blue for success) rather than Binance yellow. Expected wherever we embed a provider (KYC, payment processors, TradingView charts).
- **Dynamic form expansion**: checking "I have another nationality" reveals a new dropdown inline. Pattern for optional additional fields — don't push to a new screen.

### Implementation flags

- **Liveness SDK integration** (Phase 3): pick a provider (Sumsub/Jumio/similar) before building the intro screen. The intro (rules + Continue) is Binance-themed and ours to build; everything after Continue is the provider's UI via native SDK or webview.
- **Country picker ordering**: list uses **ISO-3166-1 alpha-2 ordering** (AD, AE, AF, AG, AI, AL, AM, AO, AR, AT, AU, AW…), not alphabetical display-name ordering. Users searching by English name will rely on the search field, not scroll position.
- **Two distinct disabled-yellow states**: `~#B8971A` (yellow @ ~70% value) when a modal covers the sheet vs brand yellow @ ~20% alpha with greyed text when a required field on the current screen is empty. Implement as two separate tokens.
- **Brand-yellow text caret** globally on inputs (`#FCD535`, not system blue).

### KYC flow — post-liveness steps (Lite, captured 2026-04-21 batch 3)

Progression after the liveness SDK sub-flow completes. Returns from SDK's blue-themed UI back to Binance yellow chrome.

**Step 4b — Verifying… (SDK final verdict, still inside SDK frame)**
- Last frame from the provider SDK before it hands control back to Binance.
- Large hexagonal frame **with bright blue border** (same success-state blue as the "turn your head" challenge). Inside: a **blurred/out-of-focus captured frame** of the subject — the SDK has stopped live-previewing and is showing the final capture while it runs its backend check.
- Centered white text inside hex: **"Verifying..."** with trailing ellipsis.
- SDK brand badge still pinned bottom-right (purple/blue sparkle-face icon).
- Background is still white (screen-as-illumination pattern persists through final verdict).
- No close button visible in this frame — the user cannot cancel once the SDK is running its check.
- **Distinct from step 2's "Verifying Data"** — step 2 is Binance-themed (line-art ID illustration + countdown), step 4b is SDK-themed (hex frame + blur + ellipsis). Two different providers, two different verifying screens.

**Step 5 — Processing Liveness Check (Binance handoff interstitial)**
- Control returns to Binance; full-bleed white, **no KYC progress bar visible** at this point (SDK exit → Binance reassembles chrome).
- Centered **dark grey rounded-square icon** (`~#3A3A3A` or near-black fill, ~12px radius, ~80×80) with **yellow dot pattern** inside — appears to be the Binance mark stylized as a loading indicator (dots animating).
- Title below icon: **"Processing Liveness Check…"** (centered, body weight, black text).
- **No countdown, no illustration, no subcopy** — leaner than step 2's "Verifying Data". This is a transient post-SDK interstitial while Binance's own backend ingests the SDK result; expected to flash by in <5s.
- Header chrome is empty/hidden — no back, no support, no close. Non-dismissible.

**Step 6 — Confirm Information (KYC data review + submit)**
- Progress bar returns at top, **now filled further** (~3/4, consistent with a 4-step model where Continue here commits submission).
- Header: **headphones support + close X** (no back — user can't reverse a completed liveness).
- Title: **"Confirm Information"** (display weight).
- Subcopy below title: "By continuing, you agree that the above captured personal data is accurate." → legal framing — tapping Continue is the consent moment for data accuracy.
- **Four read-only field blocks** stacked vertically. Each block = grey label above + large black value below, **no input chrome, no pill fill** — purely informational presentation (not an editable form):
  - **Full Name** — pulled from NIN/BVN lookup (observed: `FRANK CHUKWUALASUNE OPIA`, all caps from government database).
  - **NIN** — the identifier user entered (observed: `35753615446`, 11 digits — contradicts the earlier 12-digit capture with 4-4-4 spacing in step 1, suggesting the spaces in step 1 were input-mask cosmetic only; stored value is raw 11 digits).
  - **Date of Birth** — ISO format `YYYY-MM-DD` (observed: `2007-05-23`).
  - **Address** — multi-line free text (observed: `21B ONA-OPEPO STREET, ABULE EGBA` line 1, `Alimosho, Nigeria` line 2 — street + LGA/country on separate lines).
- Below fields, **yellow text link**: **"Entered wrong NIN? Try again"** — escape hatch to re-enter identifier without losing progress entirely. Distinct from the standard back arrow (which isn't present) — this is a targeted "restart-this-field" action, not a generic back.
- Bottom: **full-width yellow Continue pill** (active, not gated — the data is already verified).
- **No editable override** of the displayed fields — user accepts the government-database return as-is, or uses the "Try again" link to redo from step 1. This protects against users typing a wrong NIN then editing the returned name to match a different person.

### New Lite design tokens captured here (2026-04-21 batch 3)

- **Read-only data block**: grey label (caption weight, `text.tertiary`) + large black value (title weight). No surrounding pill, no border, no fill. Stacked with generous vertical spacing. Used on confirmation screens where data is sourced from an external system and presented for acceptance — not edited.
- **"Try again" rescue link**: yellow text link above a primary CTA, phrased as a question ("Entered wrong X? Try again"). Targeted restart of a specific sub-step, distinct from back-arrow generic navigation. Pattern likely reused wherever verified data is shown for acceptance (address proof, payment method, etc.).
- **Two-provider verifying screens**: Binance-themed "Verifying Data" (step 2, line-art + countdown) vs SDK-themed "Verifying..." (step 4b, hex frame + blur + ellipsis). Keep both patterns — they serve different backends and shouldn't be unified.
- **Post-SDK handoff interstitial** ("Processing Liveness Check…"): dark rounded-square icon with animated yellow dots, title below, no subcopy/countdown. Used for short transient waits when returning from an embedded SDK to the host app. Distinct from long-wait patterns (which use the ETA countdown).
- **Yellow-dot loading mark**: the Binance mark rendered as an animated dot pattern inside a dark rounded-square, used as a loading glyph. Different from indeterminate spinners — branded loading state.

### Implementation flags (batch 3)

- **NIN input mask is cosmetic**: step 1 shows `3575 361 5446` (4-4-4 with spaces), but step 6 confirms the stored value is `35753615446` (11 digits, no spaces). Strip spaces before sending to backend; display with spaces in the input field only.
- **Confirm Information is non-editable**: no inline edit mode. Only restart via "Try again" link. Don't build editable fields here; just read-only display blocks + a targeted restart.
- **Progress bar reassembles post-SDK**: the yellow step progress bar is hidden during SDK takeover (steps 4/4b) and reappears on the Binance-themed steps (5, 6). Implement as a Binance-host-chrome element, not persisted through SDK frames.

### KYC flow — final steps + post-KYC landing (Lite, captured 2026-04-21 batch 4)

Progression after Confirm Information → Continue.

**Step 7 — What's your employment status? (regulatory questionnaire)**
- Step progress bar still pinned top (advanced further — near end of KYC).
- Header: **headphones support + close X** (no back).
- Title: **"What's your employment status?"** (display weight, wraps to two lines).
- Subcopy: "Your accurate response helps us protect your account and meet regulatory requirements." → explicit AML/compliance framing. This is **post-identity KYC — financial-profile questions**, not ID verification. Likely followed by source-of-funds and income-bracket questions (standard KYC/AML triad: identity → employment → funds source).
- Seven **outlined option rows** stacked vertically, each = radio circle (left) + label (black text). Same radio style as the BVN/NIN selector (grey empty outline / filled black when selected):
  1. Employed
  2. Employed - Senior management positions *(called out separately — PEP/high-risk flag trigger)*
  3. Self-employed / Freelance
  4. Student
  5. Retired
  6. Rentier *(someone living on investment/rental income — unusual inclusion, suggests template is Euro-regulation-derived rather than US)*
  7. Unemployed
- Row style: **full-width outlined rounded-rectangle**, thin 1px grey border, no fill, ~56px tall, generous internal padding. Same outlined-card style as the Yes/No inviter choice but here as a **single-select vertical list** rather than a horizontal pair.
- Bottom: **Continue button in disabled-yellow variant B** (brand yellow at ~20% alpha + greyed label) until a radio is selected. Doesn't auto-advance on selection — requires explicit Continue tap.

**Step 8 — Under Review (KYC submission confirmation, full-screen)**
- Header: **close X only** (top-right), no support, no back, **no progress bar** — KYC is submitted, progress bar retires.
- Centered **hourglass illustration**: grey thin-stroke hourglass outline with **yellow sand** in upper and lower chambers (yellow `#FCD535`). Not animated in capture but likely has subtle sand-falling animation.
- Title below illustration: **"Under Review"** (display weight, centered).
- Body copy: "You will receive an email/app notification once the review is completed. Meanwhile, please feel free to explore our website/App" → confirms **async push/email notification** on KYC verdict + encourages exploration while pending.
- Separate **"Estimated time"** label + **"15 Minute(s)"** value below (centered, stacked). Another instance of the **synthetic ETA** pattern (step 2 used `26s` countdown, step 8 uses `15 Minute(s)` static label — different precision for different wait magnitudes).
- Bottom: **full-width yellow "Go to Homepage" pill** — sole CTA. Dismisses the KYC sheet entirely and returns to Markets.

**Step 9 — Stay Informed (push-opt-in prompt, first landing after KYC)**
- **Background**: Markets tab now renders in its **logged-in + KYC-submitted state** — dimmed ~50% black overlay behind the dialog. Background reveals:
  - Normal Markets chrome (Binance mark + search + QR + gift).
  - **New 3-step onboarding progress tracker at top**: `Sign up ✓ — Verification [2] — Deposit [3]` (horizontal, with checkmark on completed step, numbered diamond on current/future steps, connecting lines).
  - Under the tracker: **"Your Verification is Under Review"** headline + yellow link **"Check Details →"** (re-enters the Under Review screen for status).
  - Markets list rendering live data underneath (`BNB +0.17% $634.36`, `BTC +0.33% $38.23`[k likely], `ETH +0.13%`, `SOL $85.85`, 币安人生 `+12.36% $0.5153`, `XRP +1.06% $1.43`, `Pepe +0.53% $0.00000378`). Note the **Chinese-named token** "币安人生" ("Binance Life") surfaces in the default watchlist — localization/region-specific content leaks through.
- **Dialog card** (centered, white rounded card ~20px radius):
  - Icon at top: **struck-through bell** (bell with diagonal yellow slash overlaying a grey bell body) — "notifications off" glyph used to *advocate turning them on*.
  - Title: **"Stay Informed"** (title weight, centered, black).
  - Body: "Do you want to receive updates on token airdrops, campaigns and special rewards?" (centered, grey body).
  - **Two pill buttons side-by-side** at bottom: grey **"No"** (secondary, left) + yellow **"Yes"** (primary, right). Same 50/50 layout as Reset Password's Cancel/Continue pair — same confirmation-moment pattern.
- Primary placement = yellow-right, secondary = grey-left: consistent with Add Funds / Take Out and Cancel / Continue — **right = affirmative primary** is a hard rule.

### New Lite design tokens captured here (2026-04-21 batch 4)

- **Full-width single-select list**: vertical stack of outlined rounded-rect rows, each with a radio dot + label. Different from the horizontal Yes/No outlined pair — same row style, different layout. Continue pill at bottom gates on selection.
- **Synthetic ETA at two scales**: seconds-precision ("26s") for sub-minute async calls using **tabular countdown**; minutes-precision ("15 Minute(s)") for multi-minute waits using **static estimate label** (not a countdown). Different visual patterns per magnitude, both under the "Estimated time" header.
- **Hourglass-with-yellow-sand illustration**: grey line-art hourglass + yellow fill in chambers. Dedicated glyph for async-review states (KYC under review, likely reused for deposit confirmations, appeal reviews, withdrawal holds).
- **Struck-through bell icon**: bell + diagonal yellow slash, indicating "notifications currently off" — used in the opt-in dialog to frame the current state before the ask. Action-state icons (current state, not target state).
- **Post-completion onboarding progress tracker**: persistent horizontal 3-step `Sign up → Verification → Deposit` bar pinned under the Markets chrome while KYC is pending and until first deposit. Checkmark diamonds for completed, numbered diamonds for pending. Disappears once all three are done.
- **Inline KYC status strip**: "Your Verification is Under Review" headline + yellow "Check Details →" link, rendered above the watchlist while review is pending. Replaces the balance hero (since there's no balance yet pre-deposit).
- **Two-button dialog**: white rounded card with icon + title + body + 50/50 pill pair. Greyed secondary left, yellow primary right — same pattern as Reset Password intro's Cancel/Continue bottom bar but here as a centered modal dialog rather than a safe-area footer. Confirmation/choice-moment modal pattern.

### Implementation flags (batch 4)

- **Employment status list is region-dependent**: "Rentier" as a first-class option suggests a EU-regulation-origin taxonomy. Wire the list to locale/residence, not a hardcoded enum — Nigerian KYC happens to surface the EU list because Binance serves both from the same compliance model, but other regions may differ.
- **KYC review is async with push notification**: backend emits email + in-app push on verdict. Client should listen for a `kyc.status_updated` push/WS event rather than polling the Under Review screen.
- **3-step onboarding tracker is a persistent chrome element**: lives above the Markets list (and likely Portfolio) while any of Sign up / Verification / Deposit is incomplete. Implement as a conditional banner in the Markets screen scaffold, not inside the balance-hero component.
- **Notification opt-in timing**: prompted **after KYC submission on first landing**, not at app install. Pattern: earn attention first (completed sign-up flow), then ask for permissions. Implement the OS push-permission request *inside* the Yes handler of this dialog, not at launch.
- **Markets list streams live even while KYC is pending**: background data is already active behind the Stay Informed modal. Market data is not gated by KYC status — only balances/trading/deposit are.

### Flow map update

```
Sign up sheet → identifier + consent → Continue
  → Verify your email (6-digit, 30min TTL, iOS autofill)
  → Create a password (3 live rules)
  → Welcome aboard! (inviter Yes/No + Next)
  → KYC step 1 — Let's Get You Verified (residence/nationality + BVN/NIN or ID docs)
  → KYC step 2 — Verifying Data (~26s async, public-database check, Binance-themed)
  → KYC step 3 — Liveness Check intro (rules + Continue)
  → KYC step 4 — Liveness capture (3rd-party SDK: oval framing → hex challenges: nod, turn head)
  → KYC step 4b — Verifying… (SDK final verdict, blue hex + blurred capture)
  → KYC step 5 — Processing Liveness Check… (Binance handoff interstitial, dark mark + yellow dots)
  → KYC step 6 — Confirm Information (read-only fields from gov database + Try again escape + Continue)
  → KYC step 7 — Employment status (7-option radio list, regulatory)
  → [likely additional AML questions — source of funds, income bracket — not yet captured]
  → KYC step 8 — Under Review (hourglass + 15min ETA + Go to Homepage)
  → Markets landing (logged-in + KYC pending)
     → 3-step tracker "Sign up ✓ — Verification [2] — Deposit [3]"
     → "Your Verification is Under Review" banner + Check Details link
     → Stay Informed push opt-in dialog (No / Yes)
  → [post-verdict — KYC approved push → unlocks Deposit step]
```

### KYC-pending status detail screen (Lite, captured 2026-04-21 batch 5)

Reached via the "Check Details →" yellow link on the Markets landing banner. Full-screen route (not a sheet — no rounded top corners, no drag handle observed), but dismissible.

- Header: **pill-shaped control cluster** top-right containing overflow `⋯` + divider + close `×`, all inside a single grey rounded pill. Different chrome pattern — **combined action pill** rather than separate icons.
- **Profile header block** (top of body):
  - Circular avatar tile (grey rounded-square card, ~72×72) containing a **yellow placeholder avatar** — grey person silhouette with yellow head/envelope-like shape + yellow body wedge. Default pre-photo avatar.
  - Right of avatar, stacked: **"User-c67e8"** (display weight, black) — auto-generated anon handle with 5-char suffix; **"ID: 1237583017"** (caption, grey) — numeric account ID; **"Unverified"** badge (grey pill, small, to the right of the ID).
- **Under Review card** (white, 12px radius, light-grey hairline border):
  - Centered **hourglass illustration** (same grey + yellow sand glyph from the standalone Under Review screen — reusable asset, not a duplicate).
  - Title "Under Review".
  - Body block: **"Estimated review time: 15 Minute(s)"** (bold label + bold value on one line — here the ETA is inline in a label: `value` format, not the stacked `Estimated time` / `15 Minute(s)` of the previous screen). Below: "You will receive an email/app notification once the review is completed."
  - Same content as the standalone Under Review screen but **compacted into a card** — demonstrates the same copy reappears in multiple contexts with layout variations.
- **Account Limits After Verification card** (separate card below):
  - Section heading "Account Limits After Verification" (title weight, black, left-aligned).
  - Four rows, each = **outlined padlock icon** (left) + stacked label + value (right of icon):
    - Fiat Deposit & Withdrawal Limits — **50K USD Daily**
    - Crypto Deposit Limit — **Unlimited**
    - Crypto Withdrawal Limit — **8M USDT Daily**
    - P2P Transaction Limits — **Unlimited**
  - No CTA on this card — purely informational. Padlock icons signal "locked until KYC approves" — reveals upgrade motivation.

### Coin Detail screen (Lite, captured 2026-04-21)

Reached by tapping a row in the Markets watchlist. **First Lite Coin Detail capture** — superseded by later captures if structure changes.

- Header: **back arrow** top-left + **bell (price alert)** + **star (favorite/watchlist)** top-right. Minimal chrome — no title in the header; the coin name lives in the body.
- **Title block** (below header):
  - Line 1: **"BNB"** (display weight, black) + **"BNB"** (same size, grey) — ticker + name pair, where name happens to equal ticker for BNB. Other coins will show `BTC Bitcoin`.
  - Line 2: **"$634.36"** (extra-large display weight, ~48–56px) + trailing `(i)` info icon (opens a price-disclaimer / data-source popover).
  - Line 3: **"-0.15%"** in **red `#F6465D`-ish** — 24h change, no surrounding pill (just coloured text). Distinct from the Markets list where the % is on its own right-aligned; here it's left-aligned under the price.
- **Chart** (takes ~⅓ of viewport):
  - **Line chart** (not candles) — Lite uses simplified line charts, matching no-orderbook philosophy. Pro gets candles + TradingView overlay.
  - Stroke color matches the change direction (red here for negative period). **Dynamic line color = sign of period change** — likely green for positive.
  - **Floating high-point label** `$634.63` in grey, positioned above the peak — passive annotation, no crosshair/drag observed.
  - Faint **"BINANCE" watermark** (grey, diagonal-left positioning) embedded in the chart background — anti-screenshot branding.
  - No gridlines, no axis labels, no volume. **Minimal chart aesthetic** for Lite.
- **Timeframe selector** (horizontal row below chart): `1H · 1D · 1W · 1M · 1Y`. Five options, spaced edge-to-edge. Active = **grey pill fill** (subtle, not yellow — visual selection via background rather than color). Inactive = plain grey text.
  - **Narrower timeframe set than Pro** (Pro has minutes, 4H, etc.). Lite keeps it to what casual holders track.
- **Your balance** row (below chart, hairline above + below):
  - Left: "Your balance" (title weight, black).
  - Right: **"0 BNB"** (black) + below it **"≈$0"** (grey caption). Right-aligned stacked. Pre-deposit zero-state.
- **About BNB card** (below balance row):
  - Section heading "About BNB" (title weight).
  - Label / value rows, each full-width:
    - `Rank` — `No. 5`
    - `Market Cap` — `$85.39B` + below it `≈$85.39B` (grey caption — a USD approximation of itself, likely always-visible for tokens whose market cap is already USD-denominated).
    - (row below cropped off-screen — possibly `Market Dominance` or `Volume`).
  - Plain grey labels left, black values right. No dividers observed — spacing-based separation.
- **Bottom action bar**: sticky full-width yellow **"Buy"** pill pinned above safe-area. **Single CTA** (no Sell, no Convert, no Receive) — confirmed that pre-holding the only action surfaced is Buy. Post-holding, Sell/Convert likely appear here.

### New Lite design tokens captured here (2026-04-21 batch 5)

- **Combined action pill header** (`⋯ | ×`): pill-shaped container holding overflow + close, grouped as one control cluster top-right. Used on identity/detail screens where overflow actions exist. Different from standalone close-X chrome.
- **Placeholder avatar style**: grey circular silhouette + yellow head/body fill wedges, on a grey rounded-square card background. Used before the user uploads a profile photo.
- **Anonymous auto-handle**: `User-<5charHex>` (e.g., `User-c67e8`) assigned at signup, persists until the user sets a custom handle.
- **Verification status pill**: grey pill-shaped chip (`Unverified`) to the right of the user ID — a chip-as-status pattern. Likely states: `Unverified` (grey) / `Under Review` (yellow?) / `Verified` (green).
- **Inline ETA format variant**: `Estimated review time: 15 Minute(s)` on one line with bold label + bold value, vs the standalone Under Review screen's stacked `Estimated time` / `15 Minute(s)` two-line format. **Two ETA presentation patterns** — standalone full-screen uses stacked, embedded-in-card uses inline. Pick based on layout context.
- **Locked-feature list with padlocks**: outlined-padlock icon + label + value rows, shown on verification/upgrade screens to tease what unlocks. Motivational pattern — visible pre-verification, padlocks presumably disappear (or turn unlocked) post-verification.
- **Line chart with directional color**: chart stroke matches the selected period's direction (red for negative, green for positive). Single-color line, no gradient fill, no candles. Lite aesthetic.
- **Floating peak annotation**: grey price label floated above the chart's highest point (`$634.63`), passive (no crosshair/interaction). Marks the local max as a visible data point.
- **Watermark branding in chart**: faint grey "BINANCE" wordmark diagonally embedded in the chart area — anti-screenshot / brand-leak protection.
- **Timeframe selector — fill-based active state**: active tab = grey pill fill (`~#F5F5F5`), inactive = plain text. **Not** yellow selection — restrained chart-control aesthetic. Contrast with the Markets sort chips, which use yellow for active.
- **Stacked balance value row**: "Your balance" label left + `0 BNB` (native-unit value) primary + `≈$0` (fiat-approximation) caption stacked right. Dual-denomination display pattern — reusable for any holdings cell.
- **Market-cap double-value**: value + below it the same value in a different unit (`$85.39B` + `≈$85.39B`). Unusual — probably a template that shows native-currency + USD-approximation for all rows, degenerates to same-value when the metric is already USD-denominated.
- **Single-CTA bottom bar (coin detail)**: sticky full-width yellow Buy pill above safe-area. Pre-holding state. Post-holding layout not yet captured.

### Implementation flags (batch 5)

- **Reusable hourglass illustration**: same glyph used standalone (Under Review screen) and in-card (KYC detail screen) — extract as a single asset.
- **Avatar + handle + ID + status pill** is a reusable identity header block. Likely reappears on Profile tab, account settings, and the about/support screens. Build once.
- **Line chart component** is the Lite chart primitive. Needs to accept: price series, selected timeframe, color-by-direction logic, floating peak annotation, timeframe selector below. `fl_chart`'s `LineChart` is sufficient — no need for `k_chart_plus` in Lite. Save `k_chart_plus` for Pro's candles.
- **Coin Detail CTA set is state-dependent**: pre-holding = `Buy` only. Post-holding likely = `Buy + Sell` or `Buy + Sell + Convert` segmented. Plan for a conditional bottom-bar slot.
- **The "Market Cap ≈$85.39B" redundancy** suggests the row template is generic — each metric has a `value` + `secondaryApproximation` slot. For pure-USD metrics it displays the same value twice. Either suppress the duplicate when `value == secondary` or just render both and accept the oddity; Binance chose the latter.
- **KYC status pill is a durable UI element**: visible on the detail screen header, likely also on Profile, Security settings, Withdraw (where it gates), etc. Drive from a single `kycStatus` provider.

---

## 1. Product Map (Pro) — visual captures

### Pro mode — first screen captures (2026-04-21, from Figma reference board)

**Important:** these are from a Figma reference file, not live app screenshots. Still authoritative for structure. Dark theme throughout (confirmed Pro default). Covers: Splash, Home, Markets, Spot Trade, Wallet Overview, Futures, Square, and a mini bottom-nav-only Wallet app (likely the companion Binance Wallet — separate product).

#### Splash screen (Pro)
- Black background (contrasts with Lite's white splash).
- "Welcome to" small text above the logo.
- **BINANCE Pro wordmark** — yellow Binance diamond mark + "BINANCE Pro" (two words, "Pro" in lighter weight).
- Confirms Pro is a distinct product identity, not just a toggle state in the same binary — dedicated splash asset.

#### Home tab (Pro)
- **Header**: hamburger menu (`≡`) left + **Exchange | Wallet** segmented switcher center (active = Exchange) + gift/rewards icon + notification bell with **badge "13"**. Hamburger + top-right icon cluster is distinctly Pro (Lite has no hamburger).
- **Search bar**: full-width grey pill: `🔥 TLM hot search` (hot-search teaser in the search placeholder).
- **Onboarding Tasks banner**: "Start Your First Trade" (title) + yellow **Trade** pill CTA (right-aligned). Dismissible; reappears when prereqs unmet.
- **Est. Total Value (BTC)**: `0.00000182` (denominated in BTC, not USD — Pro lets you toggle the reporting currency, default BTC for Pro vs USD for Lite). Below: `≈ $0.1390218` + `Today's PNL +$0.0001908(+0.14%)` (green). Chevron to expand.
- **Action row**: `Add Funds` (yellow pill, primary).
- **Coin spotlight card** (half-width left): `BNB` icon + "BNB" label + `633.44` price + `▲ 1.21%` (green) + tiny **green sparkline** at bottom. Tappable → Coin Detail.
- **P2P Orders card** (half-width right): icon row `P2P` + `Find Offer` two actions. Sub-label: "Buy/Sell Crypto with USD".
- **Markets preview sub-tabs**: `Favorites · Hot · Alpha · New · Gainers · ≡` (overflow). Below that: `Crypto · Futures` secondary toggle.
- **Bottom nav (5 tabs, Pro)**: `Home · Markets · Trade · Futures · Assets`. Confirms difference from Lite:
  - Pro: **Home** (not Markets) is the landing tab
  - Pro: dedicated **Futures** tab (Lite has none)
  - Pro: **Assets** (not Portfolio)
  - Pro: **Trade** is a tab, not a center FAB bottom-sheet
  - Pro: **no Square tab** in bottom nav (Square is elsewhere, likely in hamburger)

#### Markets tab (Pro)
- **Header**: search bar (full-width pill: `Search coin pair and trend` + voice/mic or overflow `⋯` right).
- **Category chips row**: `Favorites · Market · Alpha · Prediction · Grow · Square` (horizontal scroll, wider than Lite's simpler tab set).
- **Quote-currency sub-tabs**: `Crypto · Spot · USDⓈ-M · COIN-M · Options`. Confirms Pro surfaces derivatives market pages inside the Markets tab.
- **Second sub-tabs**: `USDC · USDT · U · USD1 · USD · BNB · BTC · ≡` — **quote-currency filter** (active USDT pill). Lite has nothing like this.
- **Column headers**: `Name / Vol ⇅` left · `Last Price` center · `24h chg% ⇅` right (sortable — Lite has sort chips, Pro has column-header sort).
- **Row structure** (denser than Lite):
  - Ticker badge `USDC /USDT` + **leverage tag `10x`** (yellow pill, margin multiplier) + 24h volume (`2.69B`) below.
  - Price `0.9995` + dollar value `$1` below (native + fiat approx).
  - **Green/red rounded-rect change pill** on the right (`+0.00%`, `+1.22%`, `+0.18%`, etc.) — **filled pill with color bg**, distinct from Lite's plain coloured text.
- Observed rows: `USDC/USDT 10x · BTC/USDT 10x · ETH/USDT 10x · SOL/USDT 10x · XRP/USDT 10x · RLUSD/USDT 5x · USD1/USDT 5x · BNB/USDT 10x · ZEC/USDT 10x`. Leverage multiplier varies per pair.

#### Spot Trade tab (Pro) — the core orderbook UI
Left side = **orderbook + order entry**. Right side = **order form**.
- **Top tab row**: `Convert · Spot · Alpha` + overflow `≡`. **Convert is promoted next to Spot** (not buried in a tool menu).
- **Pair picker**: `SOL/USDT ▼` (tappable symbol dropdown) + `+0.70%` (24h change).
- **Action icons** right: funding/history icon + overflow `⋯`.
- **Order type dropdown**: `Limit ▼` (Market/Stop-Limit/OCO/Trailing Stop/Iceberg via this dropdown).
- **Margin toggle**: `Margin ☐` (off) — inline cross-margin switch. When on, this becomes a margin order.
- **Buy / Sell segmented pill**: green **Buy** active + red **Sell** right. Colour-coded with semantic buy/sell.
- **Price + Amount fields**: `Price (USDT) [85.81]` with `−/+` spinners on either side + **BBO** button (Best Bid/Offer — quick-fill current top-of-book). Amount `Amount (SOL)` with `+` spinner.
- **%-selector slider**: horizontal track with tick marks at `0 · 25 · 50 · 75 · 100` (no labels visible but the dot-markers are there) — lets user size as % of available balance.
- **Total (USDT)** computed field.
- **Flag checkboxes** vertically: `☐ TP/SL` (attach take-profit/stop-loss) + `☐ Iceberg` (hidden large order).
- **Avbl / Max Buy / Est. Fee** triplet (readable stats) with asset unit right-aligned: `0 USDT`, `0 SOL`, `-- SOL`.
- **Primary CTA**: **green filled "Buy SOL" pill** (full-width, semantic-green `#0ECB81`, NOT Binance yellow — **trading primary CTA uses side colour, not brand colour**).
- **Orderbook (left column)**: vertical list with price (red-tinted for asks above the mark, green for bids below) + amount columns. Mark price `85.82 ≈ $85.82` shown with **spread bar below** (red `51.24%` — sell pressure | green `48.76%` — buy pressure bar).
- **Granularity selector** bottom of orderbook: `0.01 ▼` (price-grouping precision) + histogram/depth toggle icon + orderbook-style toggle icon.
- **Bottom tabs**: `Open Orders (0) · Holdings (1) · Bots · ⊕` (new-order button). Records area below.

#### Wallet Overview (Pro)
- **Header**: back arrow + centered title "Binance Wallet" (distinct from the in-app Wallets tab; this is a full-screen view when opening a sub-wallet).
- **Est. Total Value** with masked dots `******` + chart icon + QR/receive icon right.
- **Currency display**: `****** BTC ▼` (value masked + currency denomination dropdown).
- **Today's PNL** `****** ▶` (chevron to drill into PNL breakdown).
- **Action row** (3 outlined pills): `+ Add Funds` (yellow filled) · `↗ Send` · `⇄ Transfer`.
- **Sub-tabs below**: `Crypto · Account` (underline indicator on Account).
- **Spot** section header: `******` value masked right.
- Empty state with masking pattern — user had no/hidden balances on this capture.

#### Futures tab (Pro)
- **Top tabs**: `USDⓈ-M · COIN-M · Options · Smart Money` + overflow `≡`.
- **Campaign banner**: `🔥 Hot Campaign: Altcoins Futures Sprint- Week 1` (yellow highlight) + dismiss ×.
- **Symbol picker**: `BTCUSDT Perp ▼` + `+1.17%` change.
- **Sub-line**: `Funding (8h) / Countdown · -0.00616% / 03:42:53` — **funding rate + next-funding countdown**, unique to perpetuals.
- **Position controls row**: `Cross | 20x | S` (margin-mode · leverage · position-side-hedge selector). Editable chips.
- **Order form** (similar layout to Spot): `Price/Amount · Price (USDT) · BBO · Amount (BTC)`. Plus:
  - `% slider` (0/25/50/75/100).
  - `TP/SL ☐` + `Reduce Only ☐` (don't open new exposure) + `GTC ▼` (time-in-force: GTC/IOC/FOK/Post-Only).
- **Spread bar**: `93.91% ↔ 6.09%` (extreme imbalance example).
- **Activate Futures Account** yellow pill — gated access. Below: "Activate Futures Account to start Trading" subtext.
- **Positions (0) · Open Orders (0) · Bots** tabs with "You have no positions" empty state + icon.
- **BTCUSDT Perpetual Chart** collapsible section with chevron-up.

#### Binance Square (Pro, surfaced from Markets' Square category)
- **Tabs**: `Exchange | Wallet` header segmented (same as Home).
- Content: live-watchlist strip up top (`SOL $85.83 +0.74%`, `币安人生 $0.5074 +10.79%`, `View more`).
- **Sub-tabs**: `Discover · Following · Campaign · Hot · Announcements · ≡`.
- Posts: avatar + handle + date + **sentiment badge** (`Bullish` / `Bearish` yellow text): e.g., "Mike_Block · Apr 20 **Bullish** — Something is shifting around $DOCK … and it doesn't need noise to prove it. I'm watching a project that's built on a simple but powerful idea—giving people control over their digital identity…". TradingView-ish attached image/chart on some posts.
- Action bar per post: comment count · repost · like (`42`) · views (`95.4K`) · share.
- **Floating yellow + FAB** bottom-right (compose post).
- Second-row posts: `Crypto_lens_ · Apr 19 **Bearish** — ETHEREUM is preparing for a massive dump` + more posts.
- Confirms Pro's Square is **behind the Markets tab category list**, not a dedicated bottom-nav tab (Lite promotes it to bottom nav).

#### Home tab (Pro) — continued — Markets preview rows
After the BNB/P2P cards, the Home feed continues with a Markets preview section:
- Column headers: `Name · Last Price · 24h chg%`.
- Row format: ticker + fire emoji (`BNB 🔥`, `BTC 🔥`, `ETH 🔥` — **heat indicator for trending pairs**) + last price + dollar approximation below + green/red filled change pill right.
- Observed: `BNB 633.39 $634.36 +1.20%`, `BTC 76,263.82 $76,365.54 +1.29%`, `ETH 2,316.26 $2,323.27 +0.26%`, `SOL 85.80 $85.85 +0.76%`, `币安人生 0.5100 $0.51 +11.26%`. **View more →** link below.
- Below markets: `Discover · Following · Campaign · Hot · Announcements · ≡` (embedded Square strip).
- **Floating yellow + FAB** appears here too for cross-posting.

### Binance Wallet (companion product, NOT Lite/Pro)

A separate app surfaced in the captures: **Binance Wallet** (Web3 wallet product). Not to clone — worth noting since captures include it.
- Black bg + yellow shield-with-key illustration + **"Welcome to BINANCE Wallet"** splash.
- Subtitle: "All wallets, one account".
- **Create Keyless Wallet** (yellow pill) + **Import Wallet** (outlined pill).
- Bottom legal: "By using the Binance Wallet Services, you agree to the Binance's Terms of Use."
- Bottom nav: **Home · Markets · Trade · Futures · Assets** (same tab set as Pro, but this is a *distinct* app).
- **Outside project scope.** Captured for reference only.

### Pro vs Lite — key structural differences (captured)

| Dimension | Lite | Pro |
|---|---|---|
| Theme default | Light | Dark |
| Landing tab | Markets | Home |
| Bottom nav 5 | `Markets · Square · Trade(FAB) · Discover · Portfolio` | `Home · Markets · Trade · Futures · Assets` |
| Trade entry | Center FAB → bottom sheet (Buy/Sell/Convert/Deposit only) | Dedicated tab with orderbook, limit/market/etc. |
| Futures | Absent | Dedicated tab + USDⓈ-M/COIN-M/Options/Smart Money |
| Chart | Simple line chart, directional color | Candles + orderbook + depth + TradingView-style overlays |
| Markets rows | Flat list, sort chips | Denser rows w/ leverage badge, volume subline, filled change pill, sortable columns |
| Market filter | Watchlist/Coin sub-tabs only | Quote-currency filter (USDC/USDT/U/USD1/…) + category chips (Favorites/Market/Alpha/Prediction/Grow/Square) |
| Home | Absent (Markets is home) | Greeting + balance + quick actions + spotlight + onboarding tasks + Markets snapshot + Square feed |
| Square | Dedicated bottom-nav tab | Embedded in Markets category + Home feed strip |
| Search | Simple icon | Full pill with hot-search teaser (`🔥 TLM hot search`) |
| Header chrome | Binance mark + search + QR + gift | Hamburger + Exchange/Wallet toggle + gift + notif bell with count badge |
| Trade CTA colour | Yellow (brand) | **Green for Buy, red for Sell** (semantic, overrides brand) |
| Default balance denomination | USD | **BTC** (Pro lets users think in BTC) |
| PNL display | Hidden/absent pre-deposit | "Today's PNL +$0.xxx (+y%)" always visible |
| Composition FAB | Absent | Yellow + FAB on Square/feed contexts |

### New Pro-specific design tokens

- **Dark-theme primary-surface hierarchy**: confirms `bg.base #0B0E11` / `bg.surface #181A20` / `bg.surfaceAlt #1E2026` stack from RESEARCH.md section 3 is correct for Pro.
- **Trading CTA colours** (semantic, not brand): **`#0ECB81` Buy green filled pill** + `#F6465D` Sell red filled pill. Yellow NOT used for the execute action on Spot/Futures.
- **Leverage badge**: inline yellow-filled `10x` pill attached to pair name. Small, h~18, tight padding.
- **Filled change pill** (Pro Markets rows): rectangular green/red fill with white text, e.g., `+1.22%` on green bg. Distinct from Lite's plain-coloured-text-no-bg pattern.
- **Spread pressure bar**: horizontal bar split into red (sell pressure %) / green (buy pressure %) with labels on each half. Shown on both Spot orderbook and Futures.
- **Heat indicator emoji**: `🔥` inline in ticker name to mark trending pairs on Home preview.
- **Sentiment badge** (Square): `Bullish` (yellow text) / `Bearish` (yellow text or red text) inline in post metadata line.
- **BBO button**: small outlined pill in price-field row, autofills top-of-book price. Pro-only.
- **Flag checkbox row**: vertical list of `☐ TP/SL · ☐ Iceberg · ☐ Reduce Only` — advanced-order toggles. Plain rounded-square outlined checkbox.
- **Value-masking dots**: `******` pattern when user toggles eye-off on balance/PNL. Pro convention is masked-by-default for privacy.
- **Funding countdown**: `-0.00616% / 03:42:53` line = funding rate + countdown to next funding (8h cycle on most perps). Unique to Futures.
- **Depth/granularity selector**: numeric price-step dropdown (e.g., `0.01`) at the bottom of the orderbook, plus two small toggle icons for orderbook-view variants (combined/bids-only/asks-only).

### Implementation flags (Pro batch 1)

- **Auth is shared between Lite and Pro** (user-confirmed): signup/login/KYC flows already captured are the same UI in both modes. Mode toggle is a post-login setting that changes the rendered nav + theme + feature set.
- **Default-theme-per-mode**: Lite defaults to light, Pro defaults to dark. User can override via system switch (user-confirmed). Implement: `themeMode = system` default, but `mode == Pro` flips the default brightness to dark when system is `auto` at login.
- **Default balance denomination**: Pro = BTC, Lite = USD. Store as `prefs.reportingCurrency` — need a converter service that accepts `(nativeCurrency, fiatCurrency, amount)`.
- **Trade CTA = semantic colour, not brand**: the `Buy {SYMBOL}` and `Sell {SYMBOL}` primary buttons use green/red fill, not yellow. Keep a `SemanticButton` widget separate from `PrimaryButton`.
- **Markets list is category-heavy in Pro**: category chips + quote-currency filter + sortable columns. Needs a `MarketsFilter` state model: `{category, quoteCurrency, sortBy, sortDir}` producing a query against exchangeInfo + ticker streams.
- **Orderbook is its own widget family**: price-ladder list + spread pressure bar + granularity dropdown + style toggles. Phase 3/4 scope — do not attempt in Phase 1.
- **Futures activation is a gate**: "Activate Futures Account" is a separate KYC-like gate before any futures order entry is enabled. Not day-1 scope.
- **Square in Pro lives inside Markets + Home feed**, not as a dedicated tab. Route: `MarketsTab → categoryChips[Square]` renders the feed. Plus a strip embedded in Home. Different info-arch from Lite.
- **Binance Wallet (companion Web3 app) is out of scope**. Captures included it; do not clone.

### Pro Home tab — full capture (2026-04-21 batch 2, live-app screenshots)

Complete deep-scroll of the Home tab across multiple captures. All from real device (status bar: iPhone charging indicator). Dark chrome throughout.

**Top-of-scroll (above-the-fold)**

- **Header row** (pinned, no elevation):
  - `≡` hamburger left (opens drawer — not yet captured).
  - Centered **Exchange | Wallet segmented pill** (active Exchange underlined, tappable to switch contexts — Wallet likely routes to the Binance Wallet companion product or the wallet sub-product view).
  - Right cluster: gift/rewards icon (yellow-accented) + notification bell with **yellow "13" badge** (count caps visible, likely at some max).
- **Hot-search ticker pill**: full-width rounded-square card, `bg.surfaceAlt`, left-aligned grey text. Rotating headline — observed values: `🔥 TLM hot search`, **`Arbitrum Freezes $71M ETH`** (news-headline rotation — this is a **news ticker**, not a static search affordance; tap likely opens Square/News).
- **Onboarding Tasks card** (dismissible): title `Onboarding Tasks` + body "Start Your First Trade" + yellow **Trade** pill right. Kept until the user completes first trade.
- **Est. Total Value (BTC)** block:
  - Small label `Est. Total Value (BTC) ⌄` (chevron to toggle currency denomination — tap opens a picker, confirmed by the `BTC ▼` dropdown on the Assets screen).
  - Value `0.00000182` (extra-large display, tabular figures).
  - Outlined **Add Funds** pill (secondary on Home, because the balance hero is already centered — primary is implicit).
  - Sub-line: `≈ $0.1387794` USD approximation (grey caption).
  - Sub-line: `Today's PNL -$0.0000246(-0.02%)` (coloured by sign — red for negative observed).

**Trading Countdown card** (new surface — not in the Figma capture)
- Full-width rounded-square card, `bg.surface`, close `×` top-right.
- Title: `Trading Countdown`.
- Row: circular coin icon (black/dark for CHIP here) + ticker `CHIP` + name `CHIP` + yellow **Trade** pill right.
- Pagination dots below (`⬤ ⚪ ⚪` — carousel of countdowns).
- **Implication**: featured-pair promotion carousel, likely tied to Launchpool/Megadrop listings. Surfaces upcoming or newly-listed pairs with a countdown (not visible in this static capture but implied by "Countdown" title).

**Coin spotlight + P2P Orders (side-by-side half-width cards)**
- **Left — BNB spotlight card**: `bg.surface`, radius ~12px.
  - BNB icon (circular yellow) + `BNB` ticker.
  - Price `632.45` (display weight) + `▲ 1.14%` (green caret-up + %).
  - **Mini sparkline** below, line chart only (no candles), matches directional colour (green here for positive).
  - Tappable → Coin Detail.
- **Right — P2P Orders card**: `bg.surface`, chevron `>` top-right.
  - Title `P2P Orders` + caption `Buy/Sell Crypto with USD`.
  - Two action icons in a row: **P2P** (two-person icon) + **Find Offer** (magnifier icon), labelled below each.

**Embedded Markets preview section**
- **Category chips row**: `Favorites · Hot · Alpha · New · Gainers · ≡` (overflow). Active = yellow underline below chip label (`Hot` active in captures). Horizontal scroll.
- **Secondary filter row**: `Crypto · Futures` (toggle which market type the chips apply to). Underline indicator.
- **Column headers**: `Name · Last Price · 24h chg%` (small caption, grey, left/center/right aligned to columns).
- **Row format**:
  - Left: ticker (bold) + **🔥 fire emoji** if trending (observed on BNB, BTC, ETH — not on SOL, 币安人生 in this capture).
  - Center: last price (tabular figures, prominent).
  - Below price (grey caption): fiat-approximation (`$631.79`, `$76,144.61`, etc.) — only visible on some rows, likely when the quote currency differs from display currency.
  - Right: **filled rounded-rect change pill** — green fill for positive (`+1.04%`, `+0.74%`, `+0.13%`, `+0.61%`, `+9.05%`), red fill for negative. White text on colour fill.
- Observed rows (example): `BNB 🔥 632.93 $631.79 +1.04%`, `BTC 🔥 76,090.98 $76,144.61 +0.74%`, `ETH 🔥 2,312.89 $2,313.61 +0.13%`, `SOL 85.99 $85.49 +0.61%`, `币安人生 0.4902 $0.4902 +9.05%`.
- **`View more` link** below list → routes to Markets tab.

**Markets preview — alternate layout (2×3 grid / card view)**
Same data, different rendering. Toggle likely via the `≡` icon at end of category chips row (confirms list ↔ grid toggle):
- **Six outlined cards** in a 2-column 3-row grid.
- Each card: **yellow star** (favorited indicator, top-left) + ticker + `/USDT` quote (grey) + price prominent + `+change%` below in green/red plain text (no pill fill in grid view).
- Cards have thin grey 1px border, no fill, ~88px tall, 12px radius.
- Below the grid, **yellow "Add Favorites" pill CTA** (full-width) — appears when fewer than some threshold of favorites, motivating the user to favorite more.
- Observed grid: `★ BNB/USDT +1.08% · ★ BTC/USDT +0.83% · ★ ETH/USDT +0.20% · ★ SOL/USDT +0.70% · ★ 币安人生/USDT +8.83% · ★ SENT/USDT +5.55%`.

**Social feed section (Square embedded in Home)**
Below Markets preview, without a visible section divider — continuous scroll.

- **Feed tabs**: `Discover · Following · Campaign · Hot · Announcement · Live · ≡`. Active = yellow underline (Discover observed).
- **Livestream/Space strip**: horizontally-scrolling **purple pill cards** showing active live sessions:
  - Example: `🟣 +361 [Hot] YP PLAYS Axie Infinity Atia's ⫸⫸` (avatar + viewer count + title + animated-dots indicator).
  - Another: `+305`, `@时光1913 This livestream is trending ⫸⫸`.
  - Purple is the **Live/Space accent colour** (distinct from Square's yellow — indicates real-time audio/video).
- **Post cards** (feed rows), each = avatar + handle + timestamp + `×` dismiss:
  - **Text + image posts**: body text with `$TICKER` cashtags (yellow), attached image (article thumbnail OR TradingView chart screenshot), action bar bottom.
  - **Article posts**: `📄 Article` badge overlay on image, headline in body, body preview text (2–3 lines truncated with ellipsis), `BTC +1.04%` chip below article if the post is tagged to a ticker.
  - **Livestream promos**: embedded in feed, not just the top strip.
  - Observed posts: `ApexFlowTrader · 12h — 🚀 DOCK Coin Alert – Price Action + CHEQ Token Swap Update…`, `Spot Safe Capital · 15h — UPDATE $SOL $BTC FDUSD 21/04/2026 5:50…` (with attached multi-chart image), `Bơ Ngan · 5h — Article: Why $DOCK is the "Secret Weapon" for the 2026 RWA Explosion 🚀…`, `Ai Cryptoo · 10h — $PORTAL : This coin can go high anytime…` (with chart screenshot).
- **Action bar per post**:
  - 💬 comment count (`9`, `7`)
  - 🔁 reposts (`1`, `3`)
  - 👍 likes (`32`)
  - 📊 views (`56.2K`, `43.7K`)
  - ↗ share
- **Floating compose FAB**: circular yellow button with black `+` icon + **red notification dot with count `4`** (draft notifications or replies). Bottom-right, ~24px from safe-area.

**Post detail screen** (tapping a post)
- Header: back arrow + `🏠` home icon + `⋯` overflow (top-right).
- **Author header**: large circular avatar + handle `CryptoAnix` with **verified-account tier badge** (orange-ish `1` badge — creator/VIP tier indicator) + outlined yellow **Follow** pill right.
- Body text (multi-paragraph, supports **hashtags in yellow** like `#WhatNextForUSIranConflict`).
- Attached image (split diptych example: Powell + Trump photos).
- Disclaimer footer: "Disclaimer: Includes third-party opinions. No financial advice. May include sponsored content. See T&Cs."
- Metadata: `8:24 AM · Apr 20, 2026 · 120.1K Views`.
- **Engagement row**: `💬 38 · 🔁 5 · 👍 144 · ↗` (with the liked-state highlighted yellow thumb — indicates this post is liked by viewer).
- **Bottom composer bar**: full-width `Share your insights` grey input pill + right action cluster (comment count `38`, repost `5`, likes `144`, share).

**Assets tab (glimpse from bottom-nav-visible captures)**
Brief capture shows the Assets tab chrome:
- Title row: `Overview · Spot` (sub-tab selector).
- Balance row: `Est. Total Value 👁 0.00000182 BTC ▼` (eye-toggle for privacy + denomination dropdown).
- `≈ $0.1385976` below.
- PNL: `Today's PNL -$0.0002814(-0.20%)  ›`.
- Action row (3 pills): yellow **Add Funds** (primary) + grey **Send** + grey **Transfer** (secondary — same 3-button pattern as the Figma Wallet Overview capture).
- **Crypto / Account** sub-tabs with underline on Crypto.
- Holdings list row format: coin circle + ticker (`ETH`) + name below (`Ethereum`) + holdings amount right (`0.00006`) + BTC-equivalent below (`0.00000182 BTC`).
  - Second-line below holdings: `Today's PNL +$0.00(-0.25%)` (red) + `Average Price $2,953.50` (grey caption).
  - Per-row action row: outlined **Earn** pill + outlined **Trade** pill right.
- Bottom nav: Assets tab highlighted.

### New Pro-specific design tokens (Home-tab batch)

- **News-ticker search pill**: horizontally-rotating headline text in a search-affordance-shaped container. Dual purpose: news teaser + search entry. Distinct from a plain search input — the rotating copy signals "latest market events."
- **Countdown promo carousel**: featured pair/campaign card with pagination dots + Trade pill. Used for time-sensitive promotions (upcoming listings, Launchpool starts).
- **Outlined grid card** (Markets preview grid view): thin 1px grey border, no fill, favorite star top-left, ticker + quote + price + plain-text change. Alternative to list rows for the same data.
- **Add Favorites CTA**: yellow full-width pill prompting user to favorite more pairs when count is low. Motivational-empty-state pattern.
- **Purple Live/Space pill**: fully-rounded purple pill with viewer count (`+361`) + title + animated indicator (`⫸⫸`). Purple is the designated real-time/audio-video accent colour, distinct from yellow (brand), green (gain), red (loss), blue (SDK/third-party).
- **Article badge overlay**: `📄 Article` chip positioned bottom-left of a post's hero image. Marks long-form vs short-form posts.
- **Cashtag/hashtag colouring**: `$TICKER` and `#Topic` render in brand yellow within post body text. Tap to filter/search.
- **Engagement metric bar**: standardized row of comment / repost / like / views / share with icon + count. Views uses a bar-chart icon, not an eye. Liked-state inverts the thumb to filled yellow.
- **Creator-tier badge**: small numbered badge (e.g., orange `1`) attached to verified creator handles in Square. Indicates VIP/creator tier.
- **Compose FAB with notification dot**: yellow circle `+` button with red numbered dot overlay (unread drafts or mentions). Bottom-right, persistent on feed contexts.
- **Segmented Exchange/Wallet switcher**: centered pill in the Home header — signals dual-product identity (CEX exchange vs Binance Wallet companion). Contextual mode-switch at the top of the app.

### Implementation flags (Home batch)

- **Home's Markets preview and the dedicated Markets tab share a data source but not a layout**. Extract `MarketsFeedProvider` (category + filter + sort state) that both consume; render via two different row/grid widgets per context.
- **Markets preview supports dual layout (list vs grid)** with toggle at end of category chips. State is preference-persisted — users who pick grid on Home expect grid next session. Store in `shared_preferences`.
- **Square feed is embedded in Home**, not just a standalone surface. This means Home's scroll position must survive tab switches (use `PageStorageKey` or Riverpod-backed scroll controller per tab).
- **News ticker rotation** is a client-side animation, not a server push per headline. Pre-fetch a list (maybe top 5–10 headlines) and rotate every N seconds. Tap opens the current-headline article.
- **Trading Countdown carousel** needs: pair list with start/end timestamps, a timer tick to update countdown displays, pagination indicator synced with page controller. Build with `PageView.builder` + a periodic `Timer`.
- **Creator-tier badges** require a separate `userTier` field in the Square post author model. Design the post data model to accommodate.
- **Post types are polymorphic**: text-only, text+image, article, livestream-promo, chart-attached. Use a sealed class or `type` discriminator on the post DTO; render via a `PostCard.forType(post)` factory.
- **Exchange/Wallet segmented** in header is a mode-switch that affects more than just Home — tapping Wallet likely navigates to the Binance Wallet companion product. For our clone, this toggle is probably non-functional (out of scope) or maps to a different internal route. Flag early, don't over-engineer.
- **Hot/trending fire emoji 🔥** is driven off a server-side "trending" flag on the ticker, not client-computed. Expect an `isHot: bool` or `trendingScore: number > threshold` on each market row DTO.
- **Filled change pill (list) vs plain-text change (grid)**: same data, different rendering. Don't build two `ChangePercentage` components — build one with a `variant: {pill, plain}` prop.

### Pro Markets tab — full capture (2026-04-21 batch 3, live-app)

Dedicated Markets tab (bottom-nav selected = Markets). Confirms and extends the Figma capture from batch 1.

**Header (same across all category tabs)**
- Search pill: `🔍 Search coin pair and trend` placeholder (same news-ticker-style rotation behaviour likely applies).
- Right: `⋯` overflow icon (probably access to market-wide settings, notifications filter, etc.).

**Primary category tabs** (horizontal scroll, yellow-underline active indicator):
`Favorites · Market · Alpha · Prediction · Grow · Square · Data`

Each is a fundamentally different view — not just a filter of the same list. Captured below:

---

**Category: Market** (default)

- **Market-type sub-tabs**: `Crypto · Spot · USDⓈ-M · COIN-M · Options` (secondary row, underline indicator).
- **Chain/category chips** (third row, horizontal scroll): `ALL · BNB Chain · Solana · RWA · MEME · Payment · ≡` (overflow). Yellow-filled pill = active (`BNB Chain` observed). Inactive = plain text.
  - **This is the ecosystem-filter row** — lets user slice by blockchain or narrative category without changing market type.
- **Column headers**: `Name ⇅ · Last Price · 24h chg% ⇅`.
- **Row structure**:
  - Circular coin icon (24–32px, brand-coloured per token).
  - Ticker bold + name caption beneath (e.g., `BNB / BNB`, `ASTER / Aster`, `CAKE / PancakeSwap`, `币安人生 / 币安人生`, `INJ / Injective`, `FLOKI / FLOKI`, `TWT / Trust Wallet Token`, `SFP / SafePal`, `GALA / ...`).
  - Last Price prominent, USD approximation (`$631.35`) grey below.
  - **Filled change pill** right: green for positive (`+1.18%`, `+1.04%`, `+0.59%`, `+11.57%`, `+0.26%`, `+1.35%`), red for negative (`-0.52%`, `-0.10%`, `-0.62%`).

---

**Category: Alpha** (Binance Alpha — early-stage token listings pre-official-listing)

- **Chain sub-tabs**: `All · Point+ · BSC · Ethereum · Solana · Base · Arbitrum`. Multi-chain — Alpha spans across L1s/L2s.
- **Column headers**: `Name ⇅ / Vol ⇅ · Last Price · 24h chg% ⇅` (Vol appears as a secondary sort key here).
- **Row structure** (denser than Market):
  - Coin icon (often quirky/meme-style) + ticker + **yellow `v4` or similar badge** next to ticker (a *version* or *Alpha-tier* badge — observed on OPG, PRL, BASED, EDGE).
  - **Fire emoji 🔥** next to some tickers (OPG 🔥 — trending within Alpha).
  - Market cap / volume caption below ticker (`$40.64M`, `$914.62M`, `$448.68M`, etc.).
  - Last Price + USD-approx below.
  - Filled change pill right (green/red).
- Observed: `OPG 🔥 v4 $40.64M · 0.248 · +148.42%`, `PRL v4 $914.62M · 0.22396 · +1.96%`, `quq $448.68M · 0.0020565 · -0.09%`, `RAVE $208.87M · 1.72049 · +143.66%`, `GENIUS $198.37M · 0.56895 · -6.94%`, `BASED v4 $74.22M · 0.12598 · +18.01%`, `PIEVERSE $54.74M · 0.89864 · -12.10%`, `EDGE v4 $27.44M · 1.33676 · -4.01%`, `BLESS $24.24M · 0.0061523 · +10.35%`, `KOGE ... 37.79 ...`.
- **Extreme price volatility tolerated** — `+148%` and `+143%` in a single day shown without special handling. Alpha = speculative surface.

---

**Category: Prediction** (prediction markets — NEW SURFACE, not previously captured)

- **Sub-tabs**: `Watchlist · All · Sports · Crypto · Esports · Politics` + `⇅` sort icon.
- **Prediction market cards** (full-width):
  - Circular icon left (market-specific — Bitcoin logo for BTC market, avatar for CZ-apology market).
  - Title: question format — **"Bitcoin Up or Down - April 21, 9AM ET"**, **"Will Star publicly apologize to CZ?"**.
  - Top-right per card: **share icon** + **star (watchlist) icon**.
  - **Two-option prediction display**:
    - Left option = **green pill fill** with percentage above (`26%`) and label (`Up` / `Yes`).
    - Right option = **red/pink pill fill** with percentage (`73%`, `96%`) and label (`Down` / `No`).
    - Percentages are **market-implied probabilities**, sum to ~99–100% (not exactly 100 due to spread).
  - **Metadata row** bottom: `👤 102` (participants/holders) + `📊 $3,048.1` (pool size / volume).
- **Binary-outcome prediction markets** — not multi-choice. Polymarket-style implementation.
- **Disclaimer modal** (bottom sheet dismissible `×`): *"Prediction Markets are not provided by Binance ADGM entities and can only be accessed if you hold a Binance Wallet. The Binance Wallet Services are provided by Binance Barbados Limited. The Binance Wallet Services are not under the supervision of the Financial Services Regulatory Authority or any other regulatory authority."*
  - **Compliance-gated** — the Prediction Markets product is NOT provided by Binance's main regulated entity; it's under a separate sub-entity (Barbados) and requires the Binance Wallet companion product to participate. First-time visit surfaces this disclaimer.

---

**Category: Grow** (Earn hub surfaced within Markets)

- **"Earn 2.67% APR on ETH"** hero banner (yellow-ish fill, Ethereum icon right) + `View More →`.
- **Start Earning Today** section:
  - Two outlined cards (2-column grid): **USDC · 5.61% Max APR** + **ETH · 238.38% Max APR**. Each card has a mini line chart in the background + icon top-right.
  - Below: **SOL · 113.01% Max APR** (third card, same format).
  - Max APR is **prominently displayed**, tiny sparkline behind it suggesting historical APR trend.
- **Top Traders to Copy** section (copy-trading promotion):
  - Row format: avatar + handle + tier badge + stats:
    - `船长2013` + `Futures` tag · `+192.11% · 7D ROI` (green).
    - `superallin 1994` + `Futures` tag · `+135.87%`.
    - `鸿蒙资本 Primordial Capital` + `Futures` tag · partial visible.
  - Copy-trading leaderboard — Pro feature, clearly labeled with ROI timeframe.

---

**Category: Square** (Square embedded in Markets — same as Home embed)

- **Feed tabs**: `Discover · Following · Hot · News · Academy · Live`.
- Post cards same as Home's embedded feed:
  - Example: `KM signal · 7h — 🔥 BREAKING: 🇺🇸 PRESIDENT TRUMP WILL SIGN A "HUGE" EXECUTIVE ORDER TODAY AT 3:00 PM ET INSIDERS EXPECT HIM TO END THE CEASEFIRE WITH IRAN AND LAUNCH NEW ...` + attached image + ticker chip `BTC +1.04%` + engagement bar `💬 4 · 🔁 · 👍 7 · 📊 3.9K · ↗`.
  - Example: `William-ETH · Apr 20 · Bullish — 🛑 WAIT... DON'T SCROLL 🛑 ⏳ Give me 5 minutes... this setup is heating up fast 👀🔥 💎 $COS Update 💎 📉 Price: 0.001161 (-9.01%) ...`.
- **Floating compose FAB** with red `4` unread dot (same as Home).
- Full Square product also has sub-tabs `News` and `Academy` here that weren't in the Home embed — Academy is Binance's educational content surface.

---

**Category: Data** (market data insights — NEW SURFACE)

- **AI Select card**:
  - Header: `AI Select ✨ Powered by AI  ›`.
  - Body: large diamond/gem visual with a **sentiment score** centered (`7.78` — scale presumably 0–10) + label `Strong Positive`.
  - Asset: `XRP · 1.4321 +0.87%` + small `sentiment` tag.
  - **AI-derived sentiment score per asset**, paginated (pagination dots below card indicating carousel).
- **Price Change Distribution**:
  - Horizontal bar split into green (up) / grey (flat?) / red (down) segments.
  - Labels below: `Up: 569` (left, green) + `Down: 456` (right, red). Likely counting assets with positive/negative 24h change.
- **Hot Coins** section with `›` chevron:
  - 3-column grid of outlined cards: `BNB · 631.60 · +1.13%`, `BTC · 75,852.00 · +1.08%`, `ETH · 2,308.93 · +0.16%`. Icon top-right of each card.
- **Zones** section with `›` chevron:
  - 2-column grid of ecosystem-themed cards with **"New" yellow corner ribbons**:
    - `Launchpool [New]` — `NEWT +19.87%` (featured pair from this zone).
    - `Megadrop [New]` — `KERNEL +7.37%`.
    - `Solana` (partial).
    - `Yzi` (partial).
  - Zones = thematic groupings (matches RESEARCH.md section 1 "Zones" list: Innovation, Monitoring, Seed, Meme, AI, Gaming, DeFi, L1/L2).

---

### Pro Coin Detail — full capture (BNB/USDT, 2026-04-21 batch 3)

Reached by tapping a row in Markets. Full-screen route with sticky Buy/Sell bar at bottom. Dark theme.

**Header (shared across all sub-tabs)**
- `← back` + **ticker symbol `BNB/USDT ▼`** (tappable for pair switcher) + price + 24h change (red for neg, green for pos — observed `-1.10%` on Price tab).
- Right cluster: **AI icon (purple sparkle glyph)** — opens AI analysis overlay + **star** (favorite) + **bell** (price alert).
- **Sub-tabs row** (yellow-underline active): `Price · Info · Trading Data · Square · Trade-X`.

**Sub-tab: Price** (default, TradingView-style candlestick chart)

- **Price header block**:
  - Large price `631.63` (tabular figures).
  - Below: `$631.63` USD + `+1.10%` (red for negative in capture).
  - Row: `Layer 1 / Layer 2 · Vol · Price Protection` (tag chips showing the asset's category tags and a Price Protection feature badge).
  - Right-aligned stats: `24h High 640.70 · 24h Vol(BNB) 108,724.08 · 24h Low 620.87 · 24h Vol(USDT) 68.74M`.
- **Chart toolbar**:
  - Timeframe selector: `Time · 15s · 1h · 4h · 1d · More ▼ · Depth`. **"Depth"** toggles to orderbook depth chart instead of candles.
  - Icons right: layout/fullscreen toggle, drawing-tools, chart-style toggle (candles vs line vs area), indicator selector.
- **Main chart**:
  - **Candlestick chart** (green up / red down, semantic colours).
  - **Overlaid moving averages**: yellow line (MA60 labeled top-left `MA60 631.68`).
  - **Price axis** on right (`630.94`, `631.40`, `631.86`, `632.31`, `632.77`, `633.23`).
  - **Current price highlight**: black-bg pill with `631.70` on right axis at current price level.
  - Faint grey `BINANCE` watermark diagonal.
- **Volume panel** below main chart:
  - Bar chart (semantic green/red) + overlay moving averages: `Vol: 29.748 · MA(5): 53.239 · MA(10): 62.886`.
  - X-axis timestamps: `2026-04-21 14:10 · 14:26 · 14:42`.
- **Indicator selector row**: `MA · EMA · BOLL · SAR · AVL · SUPER · VOL · MACD · 📈` (chart-type toggle).
- **Historical performance** strip:
  - `Today · 7 Days · 30 Days · 90 Days · 180 Days · 1 Year`
  - Values below: `0.50% · 2.62% · -1.66% · -29.13% · -40.41% · 7.06%` (red for negative).
- **Toggle** below chart: `Order Book · Trades · Network` (switches the bottom panel).
- **Bottom sticky bar**:
  - 4 icon buttons: `More` (`…`), `Hub` (grid icon), `Margin` (exchange-arrows icon), then **Buy** (green pill, primary) + **Sell** (red pill, primary) — side-by-side 50/50.
  - **Buy/Sell duo is the standard Pro coin-detail CTA** — both are primary, not one-primary-one-secondary.

**Sub-tab: Info** (Coin Info / Trading Parameters)

- Secondary tabs: `Coin Info · Trading Parameters`.
- Disclaimer banner (grey, small text): *"Underlying data is sourced and provided by CoinMarketCap (CMC) and is for reference only. This information is presented on an 'as is' basis and does not serve as any form of representation or guarantee by Binance. General Risk Warning here."*
  - **Data attribution**: CMC for coin-info data. Plan to use CoinMarketCap API or a similar source when cloning.
- **Coin header**: yellow BNB logo + `BNB` name + **rank badge `No. 5`** right (market cap rank).
- **Stats grid** (label + value, 2-column):
  - `Market Cap · $85.13B` + `Fully Diluted Market Cap · $85.13B`
  - `Market Dominance · 3.36%` + `Volume · $1.64B`
  - `Vol/Market Cap · 1.92%` + `Circulation Supply · 134.79M BNB`
  - `Max Supply · 134.79M BNB` + `Total Supply · 134.79M BNB`
  - `Platform Concentration · 2.42` + `Issue Date · 2017-07-08`
  - `Issue Price · $0.15`
  - `All Time High · $1,370.546 · 2025-10-13` + `All Time Low · $0.09610939770937 · 2017-08-01`
- **Links** section:
  - `Website · Official Website`
  - `Block Explorer · bscscan.com` (partial)

**Sub-tab: Trading Data** (on-chain + orderflow analytics)

- Secondary tabs: `Money Flow · Margin Data`.
- **Money flow analysis** (`ⓘ`):
  - **Timeframe chips**: `15m · 30m · 1h · 2h · 4h · 1d` (active = yellow pill).
  - **Donut chart** centered with percentage segments (green wedges = inflow, red = outflow):
    - `+5.61%`, `+12.74%`, `+29.43%` (red/outflow wedges on left).
    - `+32.44%`, `+13.57%`, `+6.22%` (green/inflow wedges on right).
  - **Orders table**:
    - Columns: `Orders · Buy (BNB) · Sell (BNB) · Inflow`.
    - Rows: `Large · 70,520.31 (green) · 63,966.84 (red) · 6,553.46`; `Medium · 29,489.03 · 27,702.59 · 1,786.44`; `Small · 13,511.04 · 12,196.38 · 1,314.66`; `Total · 113,520.37 · 103,865.81 · 9,654.57`.
    - **Institutional-vs-retail breakdown** — large orders = whales, small = retail.
- **5 x 24 hours Large Inflow (BNB)** section:
  - `5 days Large Inflow: 23,412.19` summary.
  - Bar chart visualizing daily large inflows (`16,751.91` observed on one bar).

**Sub-tab: Square** (coin-specific Square feed)

- Secondary tabs: `Community · News · Project Updates · Financial` + yellow dot on Project Updates (unread indicator).
- Feed-chip row: `Latest · Hot` (mini filter).
- **Post card** (coin-filtered Square view):
  - Author: `Binance Angels` + verified checkmark + `213.2K followers` below.
  - Body: "Gm / Good day from the Gates to Heaven 🌴😄✨ cc @Arianny Infantes #Binance $BNB" + attached photo.
  - Engagement: `💬 6 · 🔁 1 · 👍 24 · 📊 1.8K · ↗`.
- **Livestream promo card**: `AgentWXO · 47m · 🔴 LIVE — Crypto Talk 🎙 | Analytics 📊 & Algorithms 🎲 Live trading sessions` + thumbnail with `🔴 LIVE 👤 131` viewer badge.
- **Bottom sticky composer**: `Join the discussion` grey input + emoji + image icons.

**Sub-tab: Trade-X** (copy trading + bots + futures pairs for this asset)

- **Copy** section:
  - Row: avatar + handle `TikDarkCoder` + `👥 197/300` (copy slots filled/total) + **yellow Copy pill** right.
  - Stats below: `30D PnL (USD) · +$104,759.76` · `30D ROI · +11.05%`.
- **Bots** section:
  - Row: `BNB/USDT · 👥 86` + yellow Copy pill.
  - Stats: `PnL (USD) · +$2,636.19` · `ROI · +1.64%`.
- **USDⓈ-M Futures** section (related futures pairs):
  - Row: star (favorite) + `BNBUSDT Perp · Vol 268.18M · 632.05 · +1.11%`.
  - Row: star + `BNBUSDC Perp · Vol 31.59M · 632.48 · +1.12%`.
- **Margin** section:
  - Row: star + `BNB/USDT 10x · Vol 68.73M · 631.69 · +1.16%` (10x leverage tag).

---

### Pro Trade tab — orderbook + order form (2026-04-21 batch 3)

Reached via bottom-nav Trade tab. BNB/USDT observed.

**Header**
- `Convert · Spot · Alpha` tabs (yellow underline on Spot).
- Right: overflow `≡`.

**Pair + change row**
- `BNB/USDT ▼` + `+1.08%` (green, live-updating across captures — `+1.15%`, `+1.16%` observed).
- Right: chart/indicator icons + overflow `⋯`.

**Orderbook (left ~60% column)**

- Column headers: `Price (USDT) · Amount ⇌ (BNB)`.
- **Ask rows** (red-tinted bg, top section, prices descending toward mark):
  - `631.40 · 6.144`, `631.39 · 1.403`, `631.38 · 0.017`, `631.37 · 1.395`, `631.36 · 4.257`, `631.35 · 15.560` (row backgrounds have subtle red-pink tint indicating sell-side).
- **Mark price** (center, prominent):
  - `631.35` (black, large) + `≈ $631.35` (grey caption).
- **Bid rows** (green-tinted bg, bottom section, prices descending):
  - `631.34 · 16.164`, `631.33 · 2.036`, `631.32 · 0.043`, `631.31 · 4.750`, `631.30 · 2.856`, `631.29 · 0.095`.
- **Spread pressure bar**: `55.38% ↔ 44.62%` (red / green) — buy/sell imbalance ratio.
- **Granularity selector** (bottom of orderbook): `0.01 ▼` + histogram icon + depth-view toggle icon.

**Order form (right ~40% column)**

- **Margin toggle**: `Margin ☐` (off) — tap to switch from spot to margin trading inline.
- **Buy / Sell segmented pill**: green `Buy` active / red `Sell`.
- **Order type**: `Limit ▼` dropdown (Market / Stop-Limit / OCO / Trailing / Iceberg via this).
- **Price field**: `Price (USDT)` label + **numeric field `631.45`** + `−` / `+` spinner buttons on either side + `BBO` button (autofills best bid/offer).
- **Amount field**: `Amount (BNB)` + `−` / `+` spinners + `+` add button.
- **%-slider**: horizontal track with diamond markers at 0/25/50/75/100.
- **Total (USDT)** computed read-only field.
- **Flag checkboxes**: `☐ TP/SL` + `☐ Iceberg` (stacked vertically).
- **Info row**:
  - `Avbl ▼ · 0 USDT ⊕` (available balance + add-funds shortcut inline).
  - `Max Buy · 0 BNB`
  - `Est. Fee · -- BNB`
- **Primary CTA**: green filled **`Buy BNB`** pill (full-width, ~48px tall). Text dynamically shows `{action} {base-currency}`.

**Below order form**: `Open Orders (0) · Holdings (1) · Bots · ⊕` tabs. The `⊕` at the end is a new-bot-creation shortcut.

**Zero-state footer**: `Available Funds: 0.00 USDT` (shown when user has no balance — motivates Add Funds).

**Add Funds bottom sheet** (triggered by `⊕` or when user tries to place an order without funds)

- Sheet appears with rounded top corners overlaying a **dimmed orderbook/form background**.
- Title `Add Funds` + close `×`.
- **You Need** label + **`1,262.9 USDT`** (large display — computed from the attempted order size).
- **Option rows** (outlined rounded rectangles, each with icon + title + caption + `→`):
  - `🔒 Buy with USD — Embrace the variety of payment methods!`
  - `👥 P2P Trading — Bank Transfer, Digital Wallet Transfer, Mobile Payment and more` (partial in capture).
- Funnels order-entry-without-funds into on-ramp/P2P flows — **friction-minimizing**, doesn't just throw an error.

---

### New Pro-specific design tokens (Markets/Coin-Detail/Trade batch)

- **Filled-pill active category chip**: yellow-filled pill with black text = active ecosystem/chain filter (e.g., `BNB Chain` in Markets). Distinct from underline-active used on sub-tabs.
- **Version/tier badge**: small yellow-filled `v4` pill inline next to ticker in Alpha listings. Indicates version or tier within Alpha.
- **Prediction market card**: two-option binary pill layout with green `Up/Yes` left + red `Down/No` right, each showing market-implied probability %. Metadata row (participant count + pool size).
- **"New" ribbon** on Zones cards: yellow corner tag indicating recently-launched zones/products.
- **AI sentiment score card**: gem/diamond visual + numeric score (e.g., `7.78 Strong Positive`) + asset row + `Powered by AI ✨` attribution. Carousel with pagination dots.
- **Price Change Distribution bar**: split horizontal bar (green/red) with `Up: N / Down: N` counts below. Market-breadth indicator.
- **Compliance disclaimer modal**: bottom sheet with title + body explaining which legal entity provides the feature + Binance Wallet requirement. Shown on first visit to regulation-gated products (Prediction Markets observed).
- **Candlestick chart with overlaid MAs**: yellow `MA60` line over red/green candles, with current-price black pill on the right axis. Standard TradingView-like visual.
- **Volume histogram with MA overlay**: lower panel with volume bars + `MA(5) / MA(10)` lines color-coded.
- **Indicator-selector strip**: horizontal list of technical indicator abbreviations (`MA · EMA · BOLL · SAR · AVL · SUPER · VOL · MACD`) with an active underline. Let user swap indicator without menu dive.
- **Historical performance strip**: horizontal row of `Today / 7D / 30D / 90D / 180D / 1Y` labels with percentage values below (coloured by sign). At-a-glance multi-timeframe return.
- **Money-flow donut chart**: multi-segment donut with green=inflow / red=outflow wedges, each labeled with percentage. Used on Trading Data sub-tab.
- **Institutional-size order breakdown table**: `Large / Medium / Small / Total` rows with Buy / Sell / Inflow columns. Whale-watcher view.
- **Copy-trading leader card**: avatar + handle + tier + Copy pill + 30D PnL + ROI stacked stats. Used on Grow category and Coin Detail's Trade-X tab.
- **Ask/Bid tinted orderbook rows**: subtle red-pink bg for ask rows, green for bid rows, mark price row plain in the middle. Row bg gradient from high-intensity at the outside to faint near the mark.
- **Inline balance shortcut**: `Avbl ▼ · 0 USDT ⊕` — available-balance readout with an inline `⊕` that opens Add Funds. Removes need to navigate away to fund before placing an order.
- **Add Funds bottom sheet with "You Need" amount**: surfaces the exact deficit the user needs to cover the order, routes to on-ramp options. Frictionless retry pattern.
- **Bottom sticky 4-icon + 2-CTA bar**: `More · Hub · Margin · [green Buy] [red Sell]` on Coin Detail. The left 3 icons are utility shortcuts, right 2 are the semantic-coloured primary actions.
- **Pair switcher dropdown `{PAIR} ▼`**: tappable dropdown in Coin Detail header that opens a pair-picker sheet without leaving the detail context.
- **Rank badge `No. 5`**: outlined pill on Coin Info showing market-cap rank (from CMC data).

### Implementation flags (Markets/Coin-Detail/Trade batch)

- **Markets tab is NOT a single list** — it's a category router: `Favorites / Market / Alpha / Prediction / Grow / Square / Data`. Each category is a separate screen/route sharing only the top header (search + overflow). Don't model Markets as one list with filters — model it as a `PageView` or `IndexedStack` of category screens.
- **Market category has a 3-level nested filter**: `market-type (Crypto/Spot/USDⓈ-M/COIN-M/Options)` → `ecosystem (ALL/BNB Chain/Solana/RWA/MEME/Payment)` → sort. Plan a `MarketsFilter` model that composes.
- **Alpha rows are fundamentally different data shape** (market cap, volume, tier badges, extreme volatility) — separate DTO and row widget from Market rows. Don't shoehorn.
- **Prediction Markets are legally distinct from core Binance** — regulated by a different entity (Binance Barbados), require the Binance Wallet companion product. For a clone, likely out of scope or deeply stubbed. First-visit disclaimer modal is mandatory.
- **Data category aggregates AI sentiment + market breadth + hot coins + zones**. The AI Select card implies a backend ML service producing per-asset sentiment scores. Stub with static data for a clone.
- **Coin Detail has 5 sub-tabs (`Price / Info / Trading Data / Square / Trade-X`)** — each is a full sub-screen with its own data needs. Use a `TabBarView` or nested router. Price is the only one that needs live streaming; others can be lazy-fetched on tab tap.
- **Trading Data requires a backend analytics service** — money flow, large-order breakdown, etc. are derived data not available from public Binance endpoints. Likely CMC or a dedicated analytics provider. Stub or skip for Phase 1.
- **Coin Detail's Trade-X tab ties copy-trading, bots, futures, and margin surfaces** — cross-product references. Model as conditional sections based on availability per asset.
- **Candlestick chart with indicators (`MA / EMA / BOLL / SAR / AVL / SUPER / VOL / MACD`)** needs a capable chart lib. `k_chart_plus` supports most of these; confirm indicator coverage before committing. TradingView webview is Phase 2+ contingency.
- **Orderbook needs live WS @depth streaming with local snapshot merge** — RESEARCH.md section 2 documents the correct algorithm (snapshot + buffered diffs). Run merge in an isolate for hot pairs. Plan: start with `@depth20@100ms` for low-frequency updates, upgrade to full diff merging in Phase 3.
- **Orderbook row bg tinting intensifies with depth from mid-price** — not a flat colour. Likely a gradient or per-row opacity. Test with `fl_chart` or custom `CustomPainter`.
- **Order type dropdown (`Limit / Market / Stop-Limit / OCO / Trailing / Iceberg`)** changes the form fields shown. Limit = price+amount; Market = amount only (or quote amount); Stop-Limit adds a trigger price; OCO adds a second order; Trailing adds a callback %; Iceberg adds visible-size field. Use a sealed class per order type.
- **`BBO` button autofills best-bid/best-offer** — needs a live subscription to `@bookTicker` on the current pair. Keep cheap (small payload stream).
- **Margin toggle inside the order form** converts a spot order to a cross/isolated margin order inline — affects max-buy calculation, borrow-interest display, liquidation-price indicator. Margin mode switches the entire backend endpoint (`/api/v3/order` → `/sapi/v1/margin/order`). Phase 3+ scope.
- **Add Funds sheet computes `You Need` from the current order draft** — needs an order-draft state that the sheet can read. Don't pass the amount as an argument to the sheet; use a shared Riverpod provider.
- **Coin Info attributes data to CoinMarketCap** — plan to use the CMC API (free tier exists) for Coin Info + rank + ATH/ATL + supply stats. Binance's own endpoints don't expose all of this.
- **Historical performance (`Today / 7D / 30D / 90D / 180D / 1Y`)** needs pre-computed returns per timeframe — likely derived from `/api/v3/klines` with various `startTime`/`endTime` calcs. Cache aggressively.

### Still to capture (Pro)

- Pro hamburger drawer contents (Settings, Security, Mode toggle, Profile, Referrals).
- Pro login happy path (password + 2FA, with Pro chrome).
- Pro Futures tab interior — activation flow, filled position, TP/SL attach, cross vs isolated.
- Pro Assets/Wallets interior — sub-wallet list, Deposit flow, Withdraw flow, Transfer sheet, Transaction History.
- Pro Earn hub interior (Simple Earn, Staking, Dual Investment, Auto-Invest).
- Pro Profile / Settings / Mode toggle (Lite ↔ Pro switch point).
- Pro notifications center.
- Pro Live/Space pill → active livestream screen.
- Pro post compose flow.
- Pro Options trading interface.
- Pro Alpha tab interior (when tapped from Trade).
- Pro Convert tab interior (when tapped from Trade).
- **Prediction market detail** (tapping a prediction card) — how a position is placed, odds mechanics.
- **Grow/Earn product detail** (tapping ETH 238% APR card).
- **Launchpool / Megadrop** detail views.
- Pair-switcher sheet (when tapping `BNB/USDT ▼` in Coin Detail header).
- AI (purple-sparkle) icon in Coin Detail header → AI analysis overlay.
- Bell/price-alert sheet (when tapping bell in Coin Detail header).

---

## 1. Product Map

### Auth & Onboarding
- Sign-up: email / phone / Google / Apple / Telegram. 6-digit OTP + slider CAPTCHA.
- KYC tiers: **Verified** (ID + selfie liveness) → **Verified Plus** (proof of address) → **Verified Pro** (corporate).
- 2FA: Email, SMS, Google Authenticator, Binance Authenticator push, Passkey (WebAuthn), YubiKey/FIDO2. Plus app-level biometric unlock.
- Security: anti-phishing code, withdrawal whitelist (24h cooldown), device management, activity log, API keys with per-permission scope.

### Navigation — 5 bottom tabs
`Home · Markets · Trade (center) · Futures · Wallets`
Top chrome: search, support chat, QR scan, notifications bell.

### Home (vertical feed, customizable modules)
Greeting header → total balance card (eye toggle, 24h PnL, Deposit/Withdraw/Transfer/Pay actions) → quick-action grid → announcements carousel → top movers → markets snapshot → Earn card → Tasks/Reward hub → Learn & Earn → Binance Square feed → Gift Card/Referral strips → recently visited.

### Markets
Tabs: Favorites / Spot (grouped by quote: USDT/USDC/FDUSD/BTC/ETH/BNB/TUSD/EUR/TRY) / Futures / Alpha / New / Gainers / Losers / Volume / Market Cap / Zones (Innovation, Monitoring, Seed, Meme, AI, Gaming, DeFi, L1/L2).
Row: symbol + price + 24h % change (colored).
Coin Detail tabs: Chart (TradingView) · Info · Order Book · Trades · News · Earn shortcut.

### Trading Interfaces
- **Spot**: Limit · Market · Stop-Limit · OCO · Trailing Stop · Iceberg. Post Only / GTC / IOC / FOK flags. %-selector (25/50/75/100). TP/SL attach.
- **Margin**: Cross vs Isolated. Auto-Borrow/Auto-Repay toggles, liquidation price indicator, up to 10× on majors. Portfolio Margin for VIPs.
- **Futures**: USDⓈ-M (linear) + COIN-M (inverse). Leverage 1–125×, Cross/Isolated, One-way/Hedge position mode, Reduce-Only, attached TP/SL, Multi-Assets Mode, funding countdown + rate.
- **Options**: European, USDT-settled; option chain + Greeks.
- **Convert**: quote → swap with 10s countdown; Limit Convert + Recurring Buy.
- **P2P**: escrow flow with advertiser filters (payment method, completion rate, online status), chat, merchant program, Block Trade.
- **Binance Pay**: QR/Pay ID/email/phone transfers; Red Packets; merchant payments.

### Wallet Sub-wallets
Overview · Spot · Funding · Cross Margin · Isolated Margin · USDⓈ-M Futures · COIN-M Futures · Earn · Options · Copy Trading · Fiat.

Actions: Deposit (coin → network selector → address + QR, memo warning for XRP/XLM/EOS/TON) · Withdraw (whitelisted address book, network fee varies, internal transfer by email/phone/Pay ID) · Transfer between sub-wallets (instant) · Transaction History (filter + CSV export) · Dust Convert.

### Earn
Simple Earn Flexible · Simple Earn Locked · ETH Staking (WBETH) · SOL/DOT/ADA/ATOM staking · DeFi Staking · **Launchpool** · **Launchpad** · **Megadrop** · Dual Investment · Range Bound · Liquidity Farming · Auto-Invest (DCA) · Yield Arena.

### Other Products
Launchpad/Launchpool/Megadrop · NFT Marketplace · Copy Trading (Spot + Futures) · Trading Bots (Spot Grid, Futures Grid, DCA, Rebalancing, Arbitrage, Smart Trade) · Binance Card (Visa, BNB cashback 1–8%) · Gift Card · Referral (commission split 0–40%) · VIP 1–9 · Fee tiers (Spot 0.1/0.1%, Futures 0.02/0.05%) · BNB fee discount toggle (25% spot / 10% futures) · Binance Square social feed · Tax reports · 24/7 support.

### UX Conventions
- Dark default; light & system options.
- **Up/Down color preference** toggle (Western green-up/red-down vs Asian red-up/green-down).
- Smart price precision per tick size; subscript-zero notation for tiny prices (`0.0₆2345`).
- Gestures: swipe chart pan, pinch zoom, long-press orderbook row to autofill price, swipe row to favorite/cancel, pull-to-refresh, drag-to-reorder home modules.
- Haptics on order placement, price alert, biometric auth.

### Notifications
Categories: Price Alerts (user + smart AI) · Orders (filled/canceled/liquidation warning) · Deposits/Withdrawals (with confirmation counter) · Transfers · Security (new device, password/2FA change, API key) · Funding payments · Earn · P2P · Pay · Square/social · Campaigns · Announcements.
Channels: push, email (with anti-phishing code), SMS, in-app badge.

---

## 2. APIs & Data

### REST (Spot)
- **Base URLs:** `api.binance.com` (+ `api1-4` mirrors), `data-api.binance.vision` (market-data-only mirror — use this from the app).
- **Auth model:** public endpoints need no key. Private endpoints need `X-MBX-APIKEY` header + HMAC-SHA256 signature over query string + `timestamp` + optional `recvWindow` (default 5000ms). Ed25519/RSA keys also supported.
- **Rate limits (weight-based, from `exchangeInfo`):** REQUEST_WEIGHT 6000/min/IP, ORDERS 100/10s and 200k/day/UID, RAW_REQUESTS 61000/5min/IP. Headers: `X-MBX-USED-WEIGHT-1M`, `X-MBX-ORDER-COUNT-*`. `429` → back off, `418` → IP ban.

**Key public endpoints:**

| Endpoint | Weight | Purpose |
|---|---|---|
| `/api/v3/exchangeInfo` | 20 | symbols, filters, rate limits |
| `/api/v3/ticker/24hr` | 2/80 | 24h rolling stats |
| `/api/v3/ticker/price` | 2/4 | last price |
| `/api/v3/ticker/bookTicker` | 2/4 | best bid/ask |
| `/api/v3/klines` | 2 | candles. Intervals: `1s/1m/3m/5m/15m/30m/1h/2h/4h/6h/8h/12h/1d/3d/1w/1M`, limit max 1000 |
| `/api/v3/depth` | 5–250 | order book, limits 5/10/20/50/100/500/1000/5000 |
| `/api/v3/trades` / `/aggTrades` | 25 / 4 | recent trades |
| `/api/v3/avgPrice` | 2 | 5-min avg |

**Symbol filters (enforce client-side):** `PRICE_FILTER` (tickSize), `LOT_SIZE` (stepSize), `MIN_NOTIONAL`/`NOTIONAL`, `PERCENT_PRICE_BY_SIDE`, `MARKET_LOT_SIZE`, `ICEBERG_PARTS`, `MAX_NUM_ORDERS`. Derive price display decimals from `tickSize`.

### WebSocket Streams
- **Base URLs:** `wss://stream.binance.com:9443` (or `:443`), `wss://data-stream.binance.vision`.
- **Naming:** lowercase `<symbol>@<stream>`.
- **Streams:** `@trade · @aggTrade · @kline_<interval> · @ticker · @miniTicker · @bookTicker · @depth · @depth@100ms · @depth5/10/20(@100ms)` + `!ticker@arr` / `!miniTicker@arr` (all markets).
- **Modes:** single `/ws/btcusdt@trade` or combined `/stream?streams=a/b/c` (messages wrapped `{stream, data}`).
- **Limits:** 24h hard disconnect (reconnect mandatory), 5 client msg/sec, 1024 streams/connection, 300 connections/5min/IP. Server pings every 3min — pong within 10min.
- **Order book maintenance:** open `@depth` → buffer → fetch `/depth?limit=1000` snapshot → drop buffered where `u < lastUpdateId` → apply where `U <= lastUpdateId+1 <= u` → apply subsequent deltas, restart on gap.

### Futures
- **USDⓈ-M:** `fapi.binance.com` + `wss://fstream.binance.com`.
- **COIN-M:** `dapi.binance.com` + `wss://dstream.binance.com`.
- Extra endpoints: `/fapi/v1/premiumIndex` (mark/index/funding), `/fapi/v1/fundingRate`, `/fapi/v1/openInterest`, `/futures/data/topLongShortAccountRatio`, `/futures/data/takerlongshortRatio`.
- Unique streams: `@markPrice(@1s) · @forceOrder (liquidations) · !markPrice@arr · !forceOrder@arr`.

### Private — route through backend proxy
Never ship the API secret. Proxy these: `/api/v3/account`, `POST/DELETE /api/v3/order`, `/openOrders`, `/allOrders`, `/myTrades`. User Data Stream: `POST /api/v3/userDataStream` → `listenKey` → WS `/ws/<listenKey>`, keep-alive every 30min (expires 60min). Events: `outboundAccountPosition`, `balanceUpdate`, `executionReport`. A Cloudflare Worker / Fly node / Supabase Edge Function is enough.

### Testnet
- Spot: `testnet.binance.vision` (GitHub signup, faucet).
- Futures: `testnet.binancefuture.com` (email signup, in-browser faucet).
- Thinner liquidity; no margin/earn/savings. Use prod data for market feel, testnet for trading flows.

### Data strategy
- Call directly from app: all public REST + public WS. CORS is fine on mobile/desktop; verify on Flutter web.
- Proxy: anything authenticated; optionally aggregate rate-limit burn.
- **Cache:** `exchangeInfo` 1–6h · closed klines aggressively in Hive keyed `(symbol, interval, openTime)` · `!ticker@arr` once vs polling N symbols · order book never cached across sessions · recent trades ring buffer 500/symbol.
- **Reconnect:** exp backoff with jitter (1–5s), resubscribe all streams, re-snapshot order book. Plan for the 24h forced disconnect.

---

## 3. Visual Design

### Brand
- **Binance Yellow (current):** `#FCD535` (2022 rebrand).
- **Legacy yellow:** `#F0B90B` — use as pressed/hover variant.
- Logo: rotated-square chevron mark; pair with wordmark only in splash.

### Dark Theme (default)

| Token | Hex |
|---|---|
| `bg.base` | `#0B0E11` |
| `bg.surface` | `#181A20` |
| `bg.surfaceAlt` | `#1E2026` |
| `bg.line` | `#2B3139` |
| `text.primary` | `#EAECEF` |
| `text.secondary` | `#B7BDC6` |
| `text.tertiary` | `#848E9C` |
| `brand.primary` | `#FCD535` |
| `brand.primaryPressed` | `#F0B90B` |
| `semantic.buy` | `#0ECB81` |
| `semantic.sell` | `#F6465D` |

### Light Theme

| Token | Hex |
|---|---|
| `bg.base` | `#FAFAFA` |
| `bg.surface` | `#FFFFFF` |
| `bg.surfaceAlt` | `#F5F5F5` |
| `bg.line` | `#EAECEF` |
| `text.primary` | `#1E2329` |
| `text.secondary` | `#474D57` |
| `text.tertiary` | `#707A8A` |

Semantic green/red nudged slightly darker on white. Brand yellow unchanged (subtle border on light for contrast).

### Typography
- **Font:** Binance Plex Sans (licensed IBM Plex Sans variant). Fallback: IBM Plex Sans → Inter → system. In Flutter, use `GoogleFonts.ibmPlexSans()`.
- **Scale (px):** Display 28–32/600 · Title L 20/600 · Title M 16/600 · Body 14/400–500 · Caption 12/400 · Micro 10–11/400.
- **Tabular figures** (`FontFeature.tabularFigures()`) on prices/orderbook. De-emphasize trailing decimals with `text.tertiary`.

### Layout
- Spacing: 4/8/12/16/20/24/32/40. Cards padded 16, rows 12v/16h.
- Bottom nav: 5 tabs, ~56px + safe area, label 10–11px, active `#FCD535`.
- App bar: minimal 44–48px, no elevation.
- Cards: radius 8/12/16, no shadow dark / soft shadow light.
- Market row: icon 24 + ticker/name + right-aligned price + change pill, optional 40×20 sparkline.

### Iconography
Outlined, 1.5–2px stroke, rounded joins. Filled for active tab. Flutter: `lucide_icons` or `phosphor_flutter` (stock Material looks too heavy).

### Charts
Candles up `#0ECB81`, down `#F6465D`, wicks match body. Subtle horizontal-only gridlines (`#2B3139` @ 40%). Axis labels 10px tabular, `text.tertiary`. Crosshair dashed with price pill. Volume bars at 50% opacity. TradingView theme override with these hex values.

### Motion
- **Price flash:** cell bg flashes semantic color @15% on tick, fades 400–600ms. Text flashes full-opacity green/red. Critical to "feeling live."
- Tab transitions instant; fade 150ms.
- Bottom sheets slide up 250ms `easeOutCubic` with 4×36 drag handle.
- Odometer digit roll on home balance.
- Button press scales 0.97 / 80ms.

### Components
- **Primary btn:** fill `#FCD535`, text `#0B0E11`, 600, h48, r8. Pressed `#F0B90B`.
- **Secondary:** transparent, 1px border `#2B3139`.
- **Buy/Sell segmented:** active Buy `#0ECB81` fill / active Sell `#F6465D` fill, r4.
- **Input:** `bg.surfaceAlt` fill, no border, focus 1px `#FCD535`, h48, r8. Error border `#F6465D`.
- **Bottom sheets** for context actions; full-screen modals for multi-step (KYC, deposit, order detail).
- **Toast:** top-anchored, `bg.surface` + 3px semantic left bar, 3s auto-dismiss.
- **Chips:** h24, r4, 8h padding, `bg.surfaceAlt` / `text.secondary`.

Implementation: define `BinanceColors` and `BinanceTypography`, build `ThemeData` for both brightnesses, `useMaterial3: true` with fully overridden `ColorScheme` — Binance is flatter/denser than M3 defaults.

---

## 4. Flutter Stack

### Headline picks
1. **State:** `flutter_riverpod` — `StreamProvider.family` per symbol auto-disposes when unobserved.
2. **Network:** `dio` + `web_socket_channel` + `freezed`/`json_serializable`. Single multiplexed `BinanceStreamClient` in `core/websocket/`.
3. **Charts:** `k_chart_plus` for main candle view, `fl_chart` for sparklines/depth/funding lines. TradingView via webview = V2.
4. **Storage:** `hive_ce` (typed objects) + `drift` (queryable) + `flutter_secure_storage` (secrets) + `shared_preferences` (prefs). Four stores, clear jobs.
5. **Nav:** `go_router` with `ShellRoute` for tabs + deep linking (coin pages, referrals, push taps).
6. **Structure:** feature-first with fat `core/`.
7. **Testing:** `mocktail` + `patrol` for realtime flow confidence.

### pubspec shopping list

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  dio: ^5.7.0
  web_socket_channel: ^3.0.1
  connectivity_plus: ^6.1.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  fl_chart: ^0.69.0
  k_chart_plus: ^2.0.0
  hive_ce: ^2.0.0
  hive_ce_flutter: ^2.0.0
  drift: ^2.21.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.5
  shared_preferences: ^2.3.3
  flutter_secure_storage: ^9.2.2
  go_router: ^14.6.0
  flutter_svg: ^2.0.14
  cached_network_image: ^3.4.1
  shimmer: ^3.0.0
  flutter_slidable: ^3.1.2
  qr_flutter: ^4.1.0
  mobile_scanner: ^5.2.3
  local_auth: ^2.3.0
  intl: ^0.19.0
  firebase_core: ^3.8.0
  firebase_messaging: ^15.1.5
  flutter_local_notifications: ^18.0.1

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  drift_dev: ^2.21.0
  mocktail: ^1.0.4
  patrol: ^3.13.0
  alchemist: ^0.12.0
```

Verify versions on pub.dev before pinning.

### Project layout

```
lib/
  main.dart
  app.dart
  core/
    config/        endpoints, env, flags
    theme/         BinanceColors, BinanceTypography, ThemeData
    network/       Dio client + interceptors (auth sign, rate-limit parse, retry)
    websocket/     BinanceStreamClient (single multiplexed connection, reconnect)
    storage/       hive/drift/secure_storage/prefs facades
    routing/       go_router config, route names
    l10n/          generated + ARB
    widgets/       CoinIcon, PriceText, ChangePill, shimmer primitives
    utils/         formatters (price, decimal), validators
  features/
    auth/          login, 2FA, biometric
    markets/       list, search, favorites, sparklines
    coin_detail/   candle chart, depth, trades, info
    trade/         spot order entry, orderbook widget
    futures/       perps (post-MVP)
    orders/        open/history/filled
    wallet/        balances, deposit, withdraw, history
    alerts/        price alert CRUD
    profile/       settings, security, referrals
    onboarding/
  features/<feature>/
    data/          repositories, DTOs, data sources
    domain/        entities, use cases (optional)
    presentation/  providers, screens, widgets
```

Features own their providers. Raw WebSocket access only inside `core/websocket/`.

### Specific patterns
- **Decimal safety:** use the `decimal` package + parse strings straight from Binance. Never `double` for prices.
- **Price flash:** wrap `PriceText` in an `AnimatedContainer` keyed on last price; compare new vs old to pick flash color.
- **Per-symbol subscription lifecycle:** `StreamProvider.family<Ticker, String>` — when list scrolls off-screen, autoDispose tears down subscription; the multiplexed client batches subscribe/unsubscribe messages over the single WS.
- **Order book diff apply:** separate isolate (`compute`) for the `<symbol>@depth` merge if hot pairs get heavy.
- **Icon caching:** `CoinIcon` resolves top-200 SVGs from assets → falls back to `cached_network_image` — saves the markets list from N cold fetches.

---

## Suggested MVP Scoping

**Phase 1 (UI shell + live public data):**
Theme + nav skeleton · Home (balance mocked, markets snapshot live) · Markets tab (Favorites/Spot/Gainers/Losers with `!ticker@arr`) · Coin Detail (candle chart + trades + order book, public WS only) · Wallet scaffold (mock balances) · Settings (theme, up/down color preference, language).

**Phase 2 (paper trading backend):**
Backend proxy → simulated account + orders → User Data-style WS → open orders/history/balances feel real without touching real exchange state.

**Phase 3 (auth + real trading):**
KYC-lite, 2FA, biometric, user-supplied API keys (secure storage) → proxy signs requests → real spot trading.

**Phase 4+ (the long tail):**
Futures · Margin · Earn · Convert · P2P · Pay · Copy Trading · Bots · Launchpool · Square · Notifications infra · Referral program.

References: https://developers.binance.com/docs/binance-spot-api-docs · https://developers.binance.com/docs/derivatives · https://testnet.binance.vision · https://testnet.binancefuture.com
