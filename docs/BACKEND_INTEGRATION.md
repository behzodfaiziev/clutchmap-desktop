# Backend Integration

How to run the desktop app against the real backend (Clutchmap Backend).

## Backend auth contract

The backend exposes:

- **POST /api/v1/auth/login**  
  Body: `{ "email": string, "password": string }`  
  Response: `{ "token": string, "user": { "id": string (UUID), "email": string, "displayName": string | null } }`

- **GET /api/v1/auth/me**  
  Headers: `Authorization: Bearer <token>`  
  Response: `{ "id": string (UUID), "email": string, "displayName": string | null }`  
  Returns 401/403 when not authenticated.

- **POST /api/v1/auth/register**  
  Body: `{ "email": string, "password": string, "displayName": string }`  
  (Used for registration; login is used by the app for sign-in.)

## Running with the real backend

1. **Start the backend** (e.g. on port 8080):
   ```bash
   cd clutchmap-backend && mvn spring-boot:run
   ```

2. **Point the app at the backend and disable mock auth:**
   ```bash
   cd clutchmap-desktop
   flutter run --dart-define=USE_MOCK_AUTH=false
   ```
   Default base URL is `http://localhost:8080/api/v1`. No need to set `API_BASE_URL` for local backend.

3. **Use a different API base URL** (e.g. staging/production):
   ```bash
   flutter run --dart-define=USE_MOCK_AUTH=false --dart-define=API_BASE_URL=https://api.example.com/api/v1
   ```

## Configuration

| Dart define          | Default                      | Description                          |
|----------------------|-----------------------------|--------------------------------------|
| `USE_MOCK_AUTH`      | `true`                      | Use mock auth when `true`.           |
| `API_BASE_URL`       | `http://localhost:8080/api/v1` | Backend API base URL (no trailing slash). |

- **Mock auth on** (`USE_MOCK_AUTH=true`, default): no backend required; login always succeeds with mock user.
- **Mock auth off** (`USE_MOCK_AUTH=false`): app uses real login and GET /auth/me; backend must be running and reachable at `ApiConfig.baseUrl`.

## Timeouts

Configured in `lib/core/config/api_config.dart`:

- Connect timeout: 30s  
- Receive timeout: 30s  

## Public and system endpoints

- **Public share link** (no auth): `GET /public/v1/match/{token}`  
  The app uses `ApiClient.getPublic()` so this is requested against the backend root (e.g. `http://localhost:8080/public/v1/match/{token}`), not under `/api/v1`. When generating a share link (Export → Generate Share Link), the displayed URL uses **ApiConfig.publicRootUrl** so it matches the configured backend.

- **System health**: `GET /api/v1/system/health` — **SystemRemoteDataSource.getHealth()**; used by Test Connectivity page (Settings → Dev Tools). Returns `{ "data": { "status": "UP" }, ... }`.

- **System capabilities**: `GET /api/v1/system/capabilities`  
  Used by the Test Connectivity page (Settings → Test).

## X-Team-Id header

Many backend endpoints (match-plans, opponents, folders, templates, search, rounds) require the **X-Team-Id** header with the active team’s UUID. The app:

- Registers **ActiveTeamService** (see `lib/core/team/active_team_service.dart`) and injects it into the Dio request interceptor.
- Sends **X-Team-Id** on every request when `ActiveTeamService.activeTeamId` is set.
- Clears the active team on logout.

- **Team resolution:** When the user is authenticated, **AppShell** calls **ActiveTeamService.ensureResolved()**, which fetches **GET /api/v1/teams/me**, sets the first team as active, and caches the future so it only runs once. **Dashboard** and **Matches** wait for this (or run it) and show "No team" or an error if the user has no teams.
- To set the active team manually: `getIt<ActiveTeamService>().setActiveTeamId(teamId);` (UUID string). Clear on logout is done in **AuthRepositoryImpl**.

## WebSocket

Strategy updates use a WebSocket at **/ws/strategy**. The URL is derived from **ApiConfig** (same host as API, `http`→`ws`, `https`→`wss`). Token is sent as a query parameter. See **WebSocketService** and **ApiConfig.webSocketUrl** / **wsStrategyPath**.

## Error responses

Backend returns **ApiError** (e.g. `{ "requestId", "code", "message", "fields", "timestamp" }`). **ErrorInterceptor** parses `message` for 400, 401, 403, 409, 5xx and attaches it to **ValidationError**, **AuthError**, **ConflictError**, or **ServerError**. The app uses **`messageFromException(e, fallback: '...')`** from `lib/core/errors/backend_error_helper.dart` in all feature blocs so the UI shows the backend message (e.g. "Invalid email or password" on login, validation messages, 403 text).

## Path alignment (app ↔ backend)

All API paths are relative to `ApiConfig.baseUrl` (e.g. `http://localhost:8080/api/v1`):

| App path (relative)        | Backend controller              |
|---------------------------|---------------------------------|
| `/auth/login`, `/auth/me` | IdentityController `/api/v1/auth` |
| `/match-plans`, `/match-plans/*`, `/match-plans/{idA}/compare/{idB}` | MatchPlanController `/api/v1/match-plans` |
| `/teams`, `/teams/*`      | TeamController `/api/v1/teams` (POST = create team) |
| `/opponents`              | OpponentController `/api/v1/opponents` |
| `/templates`              | TemplateController `/api/v1/templates` |
| `/rounds/*` (events)      | TacticalEventController `/api/v1/rounds` |
| `/match-plans/rounds/*` (notes, strategy, lock, lock/renew, buy-plan, economy, intelligence) | MatchPlanController `/api/v1/match-plans` |
| `/search`                 | SearchController `/api/v1/search` |
| `/games/config/*`, `/games/config/{gameType}/maps` | GameController `/api/v1/games`   |
| `/system/health`, `/system/capabilities` | SystemController `/api/v1/system` |
| `/export/match/{matchId}/pdf` | ExportController `/api/v1/export` (returns PDF bytes) |
| `POST /match-plans/{id}/share` | MatchPlanController (returns `token`, `shareUrl` for share link) |
| (public) `GET /public/v1/match/{token}` | PublicMatchController `/public/v1` |

## Wired features

- **Auth:** Login, GET /auth/me, logout; token storage; active team cleared on logout.
- **Teams:** GET /teams/me; **POST /teams** (create team: body `{ "name": string, "description?": string }`, returns created team); **ActiveTeamService** with **ensureResolved()**; first team set as active when authenticated. Team selection page "Create New Team" opens a modal and calls **TeamRemoteDataSource.createTeam()**, then refreshes list and selects the new team.
- **Team-scoped pages:** Dashboard, Matches, Opponents, Benchmark, Templates, Comparison all wait for team resolution and show "No team" or an error when the user has no team or the request fails.
- **API client:** **ApiClient** wraps **Dio** and adds **ErrorInterceptor**; all requests (including **getPublic()** for share links) get the same error handling. All requests send **Authorization** and **X-Team-Id** when set; **messageFromException()** used for user-facing error text.
- **DI:** **ApiClient**, **TeamRemoteDataSource**, **ActiveTeamService**, **SystemRemoteDataSource**, and all feature data sources (Dashboard, Matches, Opponents, Workspace, Share, Templates, Comparison, Search, Benchmark, AiCoach, GameConfig) are registered in **GetIt** so the app uses a single shared instance and consistent auth/team/error behavior.
- **Test connectivity:** Settings → Dev Tools → "Test backend connectivity" links to **/test**; Health and Capabilities use **ApiConfig**; errors show backend message via **messageFromException()**.
- **Create match:** After creating a match from the dialog, the app navigates to **/match/{id}** using the ID returned by **POST /match-plans**.
- **Comparison:** Match comparison uses **GET /match-plans/{idA}/compare/{idB}**; errors are surfaced via **ComparisonBloc** and **messageFromException()**.

Optional or backend-dependent: round **strategy** and **buy-plan** may 404 before first save; **WorkspaceRemoteDataSource** returns null in that case so the UI can show empty/initial state.

## Integration status summary

**Fully wired:**
- ✅ Auth (login, /auth/me, logout, token storage, error messages)
- ✅ Teams (GET /teams/me, ActiveTeamService, ensureResolved, team-scoped pages)
- ✅ Dashboard (intelligence, meta-alignment, recent matches)
- ✅ Matches (list with status=ACTIVE/ARCHIVED, create, archive, restore, delete, duplicate, navigate to new match)
- ✅ Opponents (list, create via POST /opponents, update via PUT /opponents/{id}, delete via DELETE /opponents/{id}, matchup, map matchup, team intelligence; Preparation tab loads maps via GET /games/config/{gameType}/maps, fallback if unavailable)
- ✅ Benchmark (benchmark, meta-alignment, trends, snapshots from GET /teams/{id}/evolution history)
- ✅ Templates (list, detail, create from match, apply)
- ✅ Comparison (compare matches, backend errors)
- ✅ Workspace (match detail, rounds, strategy, buy-plan, intelligence, risk, robustness, recommendations with page/size, advisor performance, apply recommendation with matchPlanId)
- ✅ Search, Share, System (capabilities), Test connectivity
- ✅ Error handling (ErrorInterceptor, messageFromException in all blocs)
- ✅ DI (all data sources registered, including ExportRemoteDataSource, shared ApiClient)

**Partially wired / notes:**
- **Match detail** (GET /match-plans/{id}): Flutter parses `id`, `title`, `mapName`, `archived`, `gameCode`, `gameName`, `startingSide`, `createdAt` from backend **MatchDetailResponse**. Backend doesn't include `opponentId`, so matchup loading in workspace is skipped (teamId comes from ActiveTeamService).
- **Template detail**: When opening a template from the list, the app passes **templateFromList** so detail is built from list data without calling GET /templates/{id} (backend has no single-template endpoint). If no templateFromList is passed, GET /templates/{id} is attempted and may 404.
- **AI Coach**: Wired to **POST /ai/coach** with `teamId`, `gameType`, `scope` (e.g. `MATCH_PLAN`), `scopeId` (matchId), `question`. Response `headline`/`bullets`/`confidence` mapped to app model. Mock response only when no active team or 404.
- **Recommendation feedback**: After applying a recommendation, the app calls **POST /teams/recommendations/{id}/feedback** with `applied: true`, `rating: 5`, `notes: ''`. Failures are ignored so apply success is not affected.
- **Preview apply**: **WorkspaceRemoteDataSource.previewApplyRecommendation(recommendationId, matchPlanId)** calls **POST /teams/recommendations/{id}/preview-apply**. The Advisory panel recommendation cards have a **Preview** button that fetches the preview and shows it in a dialog before applying.
- **Export**: **ExportRemoteDataSource.getMatchPdf(matchId)** calls **GET /export/match/{matchId}/pdf**. The Export menu (Workspace) includes **"Download PDF from server"**, which fetches the PDF from the backend and opens the platform share/save dialog via `Printing.sharePdf`.
- ⚠️ **Recommendation impact** (getRecommendationImpact) returns null as placeholder (no dedicated endpoint yet).

## Match list filter

**GET /match-plans** accepts `status`: `ACTIVE` (default), `ARCHIVED`, or `ALL`. The app sends `status=ACTIVE` or `status=ARCHIVED` when filtering matches (active vs archived). Optional params: `folderId`, `gameId`, `mapId`, `opponentId`, `q` (text search), `page`, `size`. The Matches page includes a **Search** field; on Submit or "Search" button the app sends `q` with the search text. **MatchesLoaded** and **MatchesRemoteDataSource.getMatches** pass optional `folderId`, `gameId`, `mapId`, `opponentId` when provided. **Opponent filter:** From the Opponents page, each opponent has a "View matches" action (gamepad icon) that navigates to `/matches?opponentId=<id>`; the Matches page loads with `opponentId` and shows a "By opponent" chip that clears the filter and navigates back to `/matches` when dismissed. Filter/query/opponentId are preserved on Retry and when reloading after archive/restore/delete.

## Duplicate match

**POST /match-plans/{matchPlanId}/duplicate** creates a copy of the match and returns the new match (MatchPlanResponse). **MatchesRemoteDataSource.duplicateMatch(matchId)** returns the new match summary; UI can then navigate to `/match/{newId}` (e.g. when a "Duplicate" action is added).

## Lock renew

**POST /match-plans/rounds/{roundPlanId}/lock/renew** extends the current user's lock. **WorkspaceRemoteDataSource.renewLock(roundId)** is called automatically every 2 minutes while the current user holds the lock on the selected round (keep-alive). The workspace page starts a timer when the loaded state shows the selected round locked by the current user and cancels it when the round changes or the lock is released.

## Apply recommendation

**POST /teams/recommendations/{recommendationId}/apply** expects body `{ "matchPlanId": "<uuid>" }`. The app sends the current match plan ID when applying from the workspace so the backend can update the correct plan.

## CORS

Backend allows all origins in development. For production, restrict in `SecurityConfig` (CORS) and use HTTPS.

## Quick verify checklist

When running against a real backend:

1. Start backend: `cd clutchmap-backend && mvn spring-boot:run`
2. Run app: `flutter run --dart-define=USE_MOCK_AUTH=false`
3. Log in with a backend user; confirm Dashboard/Matches load (team resolved via GET /teams/me).
4. Create a match; confirm redirect to match detail.
5. In Workspace: open a match, apply a recommendation; confirm no 400 (matchPlanId is sent).
6. Settings → Dev Tools → Test backend connectivity: Health and Capabilities should succeed.
