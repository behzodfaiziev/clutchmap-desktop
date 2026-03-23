import 'dart:async';
import '../logging/app_logger.dart';
import 'team_remote_data_source.dart';

/// Holds the currently selected team ID for API requests.
///
/// The backend expects [X-Team-Id] on many endpoints (match-plans, opponents,
/// folders, templates, search, rounds). Set [activeTeamId] when the user
/// selects a team (e.g. from GET /teams/me). Clear on logout.
class ActiveTeamService {
  ActiveTeamService(this._logger, this._teamRemote);

  final AppLogger _logger;
  final TeamRemoteDataSource _teamRemote;

  String? _activeTeamId;
  Future<void>? _resolveFuture;
  final StreamController<String?> _controller = StreamController<String?>.broadcast();

  /// Current active team ID (UUID string), or null if none selected.
  String? get activeTeamId => _activeTeamId;

  /// Stream of active team ID changes (null when cleared).
  Stream<String?> get stream => _controller.stream;

  /// Set the active team. Pass null to clear.
  void setActiveTeamId(String? teamId) {
    if (_activeTeamId == teamId) return;
    _activeTeamId = teamId;
    _controller.add(_activeTeamId);
    _logger.info('Active team: ${teamId ?? "none"}');
  }

  /// Clear active team (e.g. on logout). Also clears cached resolve future so next call refetches.
  void clear() {
    _resolveFuture = null;
    setActiveTeamId(null);
  }

  /// Ensures we have tried to load teams. Does not auto-set active team; user must
  /// select on team-select screen (mandatory after login).
  /// Returns a future that completes when done; safe to call multiple times (same future).
  Future<void> ensureResolved() async {
    if (_activeTeamId != null && _activeTeamId!.isNotEmpty) return;
    _resolveFuture ??= _resolveOnce();
    await _resolveFuture;
  }

  Future<void> _resolveOnce() async {
    try {
      await _teamRemote.getMyTeams();
      // Do not auto-set first team; user selects on /team-select.
    } catch (e) {
      _logger.error('Failed to load teams', e);
    }
  }

  void dispose() {
    _controller.close();
  }
}
