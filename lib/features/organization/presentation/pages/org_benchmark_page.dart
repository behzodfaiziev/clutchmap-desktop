import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../infrastructure/datasources/organization_remote_data_source.dart';

class OrgBenchmarkPage extends StatefulWidget {
  final String? orgIdFromRoute;

  const OrgBenchmarkPage({super.key, this.orgIdFromRoute});

  @override
  State<OrgBenchmarkPage> createState() => _OrgBenchmarkPageState();
}

class _OrgBenchmarkPageState extends State<OrgBenchmarkPage> {
  final _orgIdController = TextEditingController();
  OrgBenchmarkModel? _benchmark;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.orgIdFromRoute != null &&
        widget.orgIdFromRoute!.isNotEmpty) {
      _orgIdController.text = widget.orgIdFromRoute!;
      _loadBenchmark();
    }
  }

  @override
  void dispose() {
    _orgIdController.dispose();
    super.dispose();
  }

  Future<void> _loadBenchmark() async {
    final orgId = _orgIdController.text.trim();
    if (orgId.isEmpty) {
      setState(() {
        _error = 'Enter organization ID';
        _benchmark = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
      _benchmark = null;
    });
    try {
      final dataSource = getIt<OrganizationRemoteDataSource>();
      final result = await dataSource.getBenchmark(orgId);
      setState(() {
        _benchmark = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
        _benchmark = null;
        _loading = false;
      });
    }
  }

  Color _percentileColor(int p) {
    if (p >= 80) return Colors.green.shade400;
    if (p >= 50) return Colors.amber.shade400;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Org Benchmark',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Compare teams in your organization by TPI and percentiles.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _orgIdController,
                  decoration: InputDecoration(
                    labelText: 'Organization ID',
                    hintText: 'UUID',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => _loadBenchmark(),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: _loading ? null : _loadBenchmark,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(_loading ? 'Loading...' : 'Load'),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red.shade300, fontSize: 14),
            ),
          ],
          if (_benchmark != null) ...[
            const SizedBox(height: 24),
            Text(
              'Org averages: TPI ${_benchmark!.orgAverages.tpi}  |  '
              'Execution ${_benchmark!.orgAverages.execution}  |  '
              'Stability ${_benchmark!.orgAverages.stability}',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade900),
                  columns: const [
                    DataColumn(label: Text('Team', style: TextStyle(color: Colors.white70))),
                    DataColumn(label: Text('TPI', style: TextStyle(color: Colors.white70))),
                    DataColumn(label: Text('Status', style: TextStyle(color: Colors.white70))),
                    DataColumn(label: Text('TPI %', style: TextStyle(color: Colors.white70))),
                    DataColumn(label: Text('Exec %', style: TextStyle(color: Colors.white70))),
                    DataColumn(label: Text('Stability %', style: TextStyle(color: Colors.white70))),
                  ],
                  rows: _benchmark!.teams.map((row) {
                    return DataRow(
                      cells: [
                        DataCell(Text(row.teamName, style: const TextStyle(color: Colors.white))),
                        DataCell(Text('${row.tpi}', style: const TextStyle(color: Colors.white))),
                        DataCell(Text(row.status, style: TextStyle(color: Colors.white70))),
                        DataCell(Text(
                          '${row.tpiPercentile}',
                          style: TextStyle(color: _percentileColor(row.tpiPercentile)),
                        )),
                        DataCell(Text(
                          '${row.executionPercentile}',
                          style: TextStyle(color: _percentileColor(row.executionPercentile)),
                        )),
                        DataCell(Text(
                          '${row.stabilityPercentile}',
                          style: TextStyle(color: _percentileColor(row.stabilityPercentile)),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
