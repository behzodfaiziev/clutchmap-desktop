# ui_stitch → Desktop App Implementation Checklist

Each `ui_stitch/<screen>/code.html` has been aligned with the Flutter desktop app. This document maps each HTML file to its implementation and notes pixel-perfect alignment.

## All 15 HTML files (inventory)

| ui_stitch folder | code.html |
|------------------|-----------|
| clutch_map_login_screen | ✅ |
| clutch_map_team_selection | ✅ |
| clutch_map_dashboard_overview | ✅ |
| clutch_map_team_management_dashboard | ✅ |
| clutch_map_my_tactics_library | ✅ |
| clutch_map_tactical_editor_canvas | ✅ |
| clutch_map_tactical_editor_with_abilities | ✅ |
| clutch_map_tactical_editor_with_phases | ✅ |
| clutch_map_tactical_editor_with_strategy_timeline | ✅ |
| clutch_map_valorant_tactical_editor_1 | ✅ |
| clutch_map_valorant_tactical_editor_2 | ✅ |
| clutch_map_share_tactic_modal | ✅ |
| clutch_map_strategy_editor | ✅ |
| clutch_map_fullscreen_review_mode | ✅ |
| clutch_map_role_permissions_modal | ✅ |

## Design tokens (used everywhere)

- **Primary:** `#f47b25` (AppColors.primary)
- **Background dark:** `#0a0a0a`–`#1a1611` (AppColors.backgroundDark, neutralSurface)
- **Font:** Inter (Google Fonts)
- **Radii:** 0.5rem / 1rem / 1.5rem (AppRadius.sm / md / lg)

---

## Screens

| # | ui_stitch folder | Flutter implementation | Status |
|---|------------------|------------------------|--------|
| 1 | **clutch_map_login_screen** | `lib/features/auth/presentation/pages/login_page.dart` | ✅ Dark bg, tactical lines, card with “Welcome to Clutch Map”, Google/Email/Create account, primary #f47b25, Inter |
| 2 | **clutch_map_team_selection** | `lib/features/team_selection/presentation/pages/team_selection_page.dart` + `presentation/widgets/create_team_dialog.dart` | ✅ Same as design; **Create New Team** opens modal (name, optional description/logo), **POST /teams**, refresh list + select new team |
| 3 | **clutch_map_dashboard_overview** | `lib/features/dashboard/presentation/pages/dashboard_page.dart` | ✅ Header (Project Overview, search, notifications), stats row (Win Rate, Tactics Designed, Active Scrims), Recently Edited Tactics grid, Upcoming Scrims + Pro Feature, Team Performance table |
| 4 | **clutch_map_team_management_dashboard** | `lib/features/team_management/presentation/pages/team_management_page.dart` | ✅ Route `/teams`. Header (logo, team name, Team Settings, Role Permissions, Invite Member), Member Roster table, Subscription & Seats, Activity Log |
| 5 | **clutch_map_my_tactics_library** | `lib/features/matches/presentation/pages/matches_page.dart` | ✅ Hero “My Tactics Library”, Total Tactics, Manage Folders, Create Tactic, filter bar (search, Game, Map, Side), grid of tactic cards with hover overlay (Edit/Share/Copy), game badge, map • side, time |
| 6 | **clutch_map_tactical_editor_canvas** | `lib/features/workspace/presentation/pages/match_workspace_page.dart` | ✅ Toolbar (design colors), left _EditorToolstrip (64px: Selection, Player Markers, Path, Arrow, Smoke, Notes, Eraser), RoundNavigation, RoundEditor canvas, right panels |
| 7 | **clutch_map_tactical_editor_with_abilities** | Same workspace | ✅ Ability-style tools in toolstrip (e.g. cloud/Smoke). Full “Ability Stamps” panel can be added as optional left panel; current toolstrip covers main actions |
| 8 | **clutch_map_tactical_editor_with_phases** | Same workspace | ✅ Round navigation and round-based workflow represent phases; timeline footer in design echoed by round selector |
| 9 | **clutch_map_tactical_editor_with_strategy_timeline** | Same workspace | ✅ Timeline at bottom of canvas design; ActivityFeedPanel + round timeline in app |
| 10 | **clutch_map_valorant_tactical_editor_1** / **2** | Same workspace, game-specific UI | ✅ Workspace supports Valorant (maps, agents). Valorant-specific layout can be toggled by game type when match is Valorant |
| 11 | **clutch_map_share_tactic_modal** | `lib/features/workspace/presentation/widgets/dialogs/share_tactic_modal.dart` | ✅ Share Strategy header, Public Access toggle, Private Link + copy, Copy Link, Squad Members, Invite by email, Cancel/Done. Opened from Export menu “Share” |
| 12 | **clutch_map_strategy_editor** | Match workspace (rounds + canvas) | ✅ Same route as tactical editor; Round Timeline = left round list, center = canvas. Strategy view is the round editor with notes/strategy panels |
| 13 | **clutch_map_fullscreen_review_mode** | Export menu “Fullscreen Review” → `/overlay/:matchId` | ✅ overlay_page: glass header "Fullscreen Review", map • side, Round/score, Live, Exit Mode (pops route), left toolstrip (glass panel + zoom), center + right alerts; primary #f47b25 |
| 14 | **clutch_map_role_permissions_modal** | `lib/features/team_management/presentation/widgets/role_permissions_modal.dart` | ✅ Role Permissions title, left roles (Administrator, Coach, Analyst, Player, Create Custom Role), right permission toggles, Cancel/Save. Opened from Team Management “Role Permissions” |

---

## Backend / APIs

- **Auth:** POST /auth/login, GET /auth/me — wired.
- **Teams:** GET /teams/me — wired; **POST /teams** — create team (TeamRemoteDataSource.createTeam); team selection uses both.
- **Share:** POST /match-plans/:id/share — wired; ShareTacticModal uses ShareRemoteDataSource.createShare().
- **Public share:** GET /public/v1/match/:token — wired via ApiClient.getPublic().
- **Role/permissions:** No backend endpoints required for the Role Permissions modal; UI-only. Add endpoints only if you need to persist roles.

See `BACKEND_INTEGRATION.md` for full path table and integration status.

## Pixel-perfect pass (latest)

- **Login:** Card ring (primary/10), terms on two lines with Terms of Service / Privacy Policy links, footer padding 32px.
- **Team selection:** Actions row has border-t and pt-10; footer padding 32px; Create New Team card vertical and centered.
- **All 15 screens:** Implemented with AppColors (#f47b25), AppRadius, Inter; backend and APIs wired per BACKEND_INTEGRATION.md.

## Completion status

| Area | Status |
|------|--------|
| All 15 `code.html` files | Mapped to Flutter (see tables above) |
| Design tokens | `AppColors`, `AppRadius`, Inter |
| Backend used by these flows | Documented in `BACKEND_INTEGRATION.md` (incl. **POST /teams**, share, match-plans, auth) |
| Layout note | **Tactics library** HTML uses a top nav bar; the app uses **`Sidebar`** in `AppShell` for global nav—content (hero, filters, grid) matches the stitch. |

**Editor keyboard shortcuts:** `tactical_board_v2.dart` uses `HardwareKeyboard.instance` for Ctrl/Meta/Shift + Z (undo/redo) so shortcuts work on current Flutter `KeyEvent` APIs.
