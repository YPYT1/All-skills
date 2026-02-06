# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## 🗝️ Legacy Gork Credentials
These keys were migrated from the `.env` on William on 2026-01-31.

### Google APIs
- **Client ID 1 (Calendar/Gmail)**: `<GOOGLE_OAUTH_CLIENT_ID_REDACTED>`
- **Client Secret 1**: `<GOOGLE_OAUTH_CLIENT_SECRET_REDACTED>`
- **Refresh Token 1**: `<GOOGLE_REFRESH_TOKEN_REDACTED>`
- **Client ID 2 (Sheets)**: `<GOOGLE_OAUTH_CLIENT_ID_REDACTED>`
- **Client Secret 2**: `<GOOGLE_OAUTH_CLIENT_SECRET_REDACTED>`
- **Refresh Token 2**: `<GOOGLE_REFRESH_TOKEN_REDACTED>`
- **Sheet ID**: `1cE0Se1iq-NbNCkrTrMqEUBH4jjUaYFyKI9HCu8-wwms`

### Strava
- **Client ID**: `195710`
- **Client Secret**: `c77bfdbeddd924fbe89fe3fbf606fa359fe17ea1`
- **Refresh Token**: `c572c7abcf7f7661650fd020bfdcb32fe846ff53`

### Slack
- **User Token**: `<SLACK_TOKEN_REDACTED>`

### Harvest
- **Access Token**: `4164532.pt.yVEyYdyv6fHCaB0WwlWMBvfgXG9sEj6WcnoO_CkoDAhtckpDPd3DHwpkyETX2TiNOhx-h7NNuw0Bwj8cH5Xnnw`
- **Account ID**: `2089744`

### Services
- **Gemini Legacy Key**: `<GOOGLE_API_KEY_REDACTED>`

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases  
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- william → 192.168.12.153 (Unraid Host), user: root, key: ~/.ssh/id_ed25519_william
- babyserver → 100.103.97.93 (Tailscale)

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
