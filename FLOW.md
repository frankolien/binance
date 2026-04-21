# Lite UX / System Flow — captured state (2026-04-21)

Mermaid diagrams of the Binance Lite flows captured in RESEARCH.md so far.
Covers: auth/signup → KYC → post-KYC landing → coin detail. Screens labelled with their chrome, primary action, and any async/external-system handoff.

---

## 1. High-level flow (screen graph)

```mermaid
flowchart TD
    classDef sheet fill:#FFF8DC,stroke:#B8971A,color:#1E2329
    classDef fullscreen fill:#FFFFFF,stroke:#2B3139,color:#1E2329
    classDef sdk fill:#E0ECFF,stroke:#1E6FD9,color:#0B1F4B
    classDef async fill:#F5F5F5,stroke:#707A8A,color:#1E2329,stroke-dasharray: 4 3
    classDef celebration fill:#D1FAE5,stroke:#10B981,color:#064E3B
    classDef landing fill:#FFF3B0,stroke:#FCD535,color:#1E2329
    classDef dialog fill:#FFFFFF,stroke:#F6465D,color:#1E2329

    Markets[Markets tab<br/>logged-out<br/>public WS tickers]:::fullscreen
    Markets -->|tap Log in or Sign up| AuthEntry

    subgraph AuthSheet[AuthSheet bottom sheet hosts nested Navigator]
        direction TB
        AuthEntry{{Entry<br/>Login or Signup<br/>identifier + consent}}:::sheet
        AuthEntry -->|login path + no password| NoPwAlert
        AuthEntry -->|login path + has password| PwEntry[Password entry]:::sheet
        AuthEntry -->|Cant log in| NeedHelp
        AuthEntry -->|signup path| VerifyEmail

        NoPwAlert[No password alert dialog<br/>OK]:::dialog --> ResetIntro
        NeedHelp{{Need help to log in<br/>2 filled option cards}}:::sheet
        NeedHelp -->|I remember| ResetIntro
        NeedHelp -->|I forgot| ForgotAppeal{{Forgot Account Appeal<br/>Submit or Check Previous}}:::sheet
        ResetIntro[Reset Password intro<br/>shield illustration<br/>Cancel or Continue]:::sheet --> EmailVerify
        EmailVerify[Email Verification<br/>6-digit + Risk footer]:::sheet --> PwEntry
        PwEntry --> Done2FA[2FA -> Done]:::celebration

        VerifyEmail[Verify your email<br/>6-digit 30min TTL<br/>iOS autofill, yellow caret]:::sheet
        VerifyEmail --> CreatePw[Create a password<br/>3 live rules]:::sheet
        CreatePw --> Welcome[Welcome aboard<br/>confetti hero<br/>inviter Yes or No]:::celebration

        Welcome --> KycStep1
    end

    subgraph KYC[KYC flow — yellow step progress bar pinned top]
        direction TB
        KycStep1[Step 1 — Lets Get You Verified<br/>residence + nationality + BVN/NIN<br/>gated-yellow Continue]:::sheet
        KycStep1 --> KycStep2
        KycStep2[Step 2 — Verifying Data<br/>line-art ID + yellow badge<br/>Estimated time 26s countdown]:::async
        KycStep2 --> KycStep3[Step 3 — Liveness Check intro<br/>face-scan illustration<br/>diamond-bullet rules]:::sheet
        KycStep3 --> KycStep4

        subgraph LivenessSDK[Third-party SDK takeover — full-bleed, Binance yellow suppressed]
            direction TB
            KycStep4[Step 4 — Framing<br/>dark bg + white oval<br/>grey circular close]:::sdk
            KycStep4 --> ChallengeNod[Challenge — Nod head<br/>white bg + white hex<br/>17s countdown]:::sdk
            ChallengeNod --> ChallengeTurn[Challenge — Turn head<br/>blue hex = advancing<br/>19s countdown]:::sdk
            ChallengeTurn --> KycStep4b[Step 4b — Verifying...<br/>blue hex + blurred capture]:::sdk
        end

        KycStep4b --> KycStep5[Step 5 — Processing Liveness Check...<br/>dark mark + yellow dots<br/>no countdown]:::async
        KycStep5 --> KycStep6[Step 6 — Confirm Information<br/>read-only Full Name, NIN, DOB, Address<br/>Try again rescue link]:::sheet
        KycStep6 -->|Try again| KycStep1
        KycStep6 --> KycStep7[Step 7 — Employment status<br/>7-radio list AML question]:::sheet
        KycStep7 -. likely more AML questions .-> KycStep8
        KycStep8[Step 8 — Under Review<br/>hourglass + yellow sand<br/>Estimated time 15 Minute s]:::async
    end

    KycStep8 -->|Go to Homepage| MarketsAuth

    subgraph PostKyc[Post-KYC Markets landing — persistent chrome while pending]
        direction TB
        MarketsAuth[Markets tab — logged in + KYC pending<br/>3-step tracker Sign up OK -> Verification 2 -> Deposit 3<br/>Your Verification is Under Review + Check Details]:::landing
        MarketsAuth --> StayInformed[Stay Informed dialog<br/>struck-through bell<br/>No or Yes push opt-in]:::dialog
        StayInformed -->|Yes| OSPushPerm[OS push-permission prompt]:::dialog
        StayInformed -->|No| MarketsIdle[Markets idle]:::landing
        OSPushPerm --> MarketsIdle

        MarketsAuth -->|Check Details| KycDetail[KYC status detail<br/>avatar + User-handle + ID + Unverified pill<br/>Under Review card + Account Limits with padlocks]:::fullscreen
        MarketsAuth -->|tap coin row| CoinDetail[Coin Detail BNB<br/>line chart + directional color<br/>1H 1D 1W 1M 1Y<br/>Your balance + About + Buy pill]:::fullscreen
    end

    KycStatusUpdate((push/WS event<br/>kyc.status_updated)):::async
    KycStatusUpdate -. async verdict .-> MarketsAuth
```

---

## 2. Auth sheet — state machine

```mermaid
stateDiagram-v2
    [*] --> MarketsLoggedOut
    MarketsLoggedOut --> Login: tap Log in
    MarketsLoggedOut --> Signup: tap Sign up

    state Login {
        [*] --> IdentifierL
        IdentifierL --> CheckPw: Continue
        CheckPw --> PwEntry: password exists
        CheckPw --> NoPwAlert: no password set
        NoPwAlert --> ResetIntro: OK
        ResetIntro --> EmailOtp: Continue
        EmailOtp --> NewPw: valid code
        NewPw --> Done
        PwEntry --> TwoFa
        TwoFa --> Done
        IdentifierL --> NeedHelp: Cant log in
        NeedHelp --> ResetIntro: I remember
        NeedHelp --> ForgotAppeal: I forgot
        ForgotAppeal --> [*]: async manual review
    }

    state Signup {
        [*] --> IdentifierS
        IdentifierS --> VerifyEmail: Continue
        VerifyEmail --> CreatePw: valid code
        CreatePw --> Welcome
        Welcome --> Kyc: inviter Yes or No + Next
    }

    Done --> MarketsLoggedIn
    Kyc --> KycUnderReview
    KycUnderReview --> MarketsLoggedIn
    MarketsLoggedIn --> [*]
```

---

## 3. KYC — sequence (with external systems)

```mermaid
sequenceDiagram
    autonumber
    participant U as User
    participant App as Binance Lite app
    participant API as Binance backend
    participant Gov as Public gov database<br/>(NIMC / NIBSS for NIN/BVN)
    participant SDK as Liveness SDK<br/>(Sumsub-like)

    U->>App: Enter residence + nationality + BVN/NIN
    App->>API: submit identifier
    API->>Gov: lookup NIN/BVN
    Gov-->>API: name, DOB, address
    API-->>App: pending verdict
    Note over App: Step 2 — Verifying Data<br/>~26s ETA countdown

    App->>U: Show Liveness Check intro (rules)
    U->>App: Continue
    App->>SDK: start liveness session
    Note over App,SDK: Step 4 — full-bleed takeover<br/>Binance yellow suppressed; SDK blue accent

    SDK->>U: Put your face in the oval (framing)
    SDK->>U: Please nod your head (17s)
    U-->>SDK: gesture detected
    SDK->>U: Please turn your head (19s)<br/>hex border turns blue = advancing
    U-->>SDK: gesture detected
    SDK-->>App: Verifying... (hex + blurred capture)
    SDK-->>API: liveness result (score, frames)
    API-->>App: ingested

    Note over App: Step 5 — Processing Liveness Check...<br/>dark mark + yellow dots (transient)

    App->>U: Confirm Information<br/>(read-only: Name, NIN, DOB, Address)
    U->>App: Continue
    App->>U: Employment status (AML)
    U->>App: select option + Continue
    App->>API: submit full KYC bundle
    API-->>App: Under Review (15min ETA)

    par async verdict
        API-->>App: push/email kyc.status_updated
    and user explores
        U->>App: Markets / Coin Detail / etc.
    end
```

---

## 4. Theme / design-token takeover map

```mermaid
flowchart LR
    classDef binance fill:#FCD535,stroke:#F0B90B,color:#1E2329
    classDef sdk fill:#1E6FD9,stroke:#0B1F4B,color:#FFFFFF
    classDef dim fill:#EAECEF,stroke:#707A8A,color:#474D57

    subgraph Binance[Binance-themed chrome<br/>yellow #FCD535 primary]
        direction TB
        A1[Markets + Lite screens]:::binance
        A2[Auth sheet - bottom sheet chrome]:::binance
        A3[KYC steps 1, 2, 3, 5, 6, 7, 8]:::binance
        A4[Post-KYC Markets + Coin Detail]:::binance
    end

    subgraph SDKOverride[SDK takeover — full-bleed<br/>Binance yellow suppressed, blue accent]
        direction TB
        B1[Framing screen - dark bg]:::sdk
        B2[Challenge - Nod - white bg + white hex]:::sdk
        B3[Challenge - Turn - blue hex = success]:::sdk
        B4[Verifying... - blue hex + blurred capture]:::sdk
    end

    subgraph Disabled[Disabled-yellow variants - two distinct tokens]
        direction TB
        C1[Variant A - yellow at 70% value<br/>used when modal covers sheet]:::dim
        C2[Variant B - yellow at 20% alpha + greyed text<br/>used when required field is empty]:::dim
    end

    A3 -->|Step 4 handoff| B1
    B4 -->|returns to Binance chrome| A3
```

---

## 5. Key chrome variants observed

| Screen context | Header chrome | Notes |
|---|---|---|
| Markets (logged-out) | Binance mark + search + QR + gift | Bottom nav all 5 tabs visible; action-time gating |
| Markets (logged-in, KYC pending) | Same + 3-step tracker below | `Sign up ✓ — Verification [2] — Deposit [3]` persists until first deposit |
| Auth sheet entry | Title + top-right close X (login) / support+X (signup) | Bottom-sheet chrome, no back |
| Mid-auth flow | ← back + 🎧 support + × close | Back only appears past entry |
| Post-commit (Welcome, Under Review) | × close only | Cannot reverse |
| KYC during SDK | Grey circular × on dark / plain × on white | Adapts to background; no support |
| Coin Detail | ← back + 🔔 alert + ⭐ star | Minimal, no title in header |
| KYC status detail | Pill-grouped `⋯ | ×` | Combined action pill — unique to identity/detail screens |

---

## 6. Async ETA pattern — two scales

| Scale | Visual | Used at |
|---|---|---|
| Seconds | Line-art illustration + `Estimated time:` label + **tabular `26s` countdown** | KYC step 2 (public-database lookup) |
| Minutes | Hourglass illustration + stacked `Estimated time` / `15 Minute(s)` static label | KYC step 8 (Under Review full-screen) |
| Minutes, inline | Compact card with `Estimated review time: 15 Minute(s)` one-line bold label+value | KYC status detail card |
| Transient | Dark mark + yellow dots, no countdown | KYC step 5 (post-SDK handoff) |
| SDK-themed | Blue hex + blurred capture + `Verifying...` ellipsis | Step 4b (SDK final verdict) |

---

## 7. Coverage legend

- ✅ Fully captured: signup identifier → email OTP → password → Welcome → KYC step 1-8 → Markets landing → KYC detail → Coin Detail (BNB, zero-balance).
- ⚠️ Partial: Login branch (no-password alert + reset intro + email verify captured; happy-path password entry + 2FA not yet).
- ❌ Not yet captured: Login happy path, 2FA setup, post-KYC-approved state, Deposit flow, Trade bottom sheet, Convert, Portfolio, Square, Discover sub-screens, Profile tab.
