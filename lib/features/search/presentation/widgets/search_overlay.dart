import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../infrastructure/datasources/search_remote_data_source.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../domain/entities/search_result.dart';
import 'search_result_tile.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc(
      dataSource: SearchRemoteDataSource(getIt<ApiClient>()),
    );
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _navigateToResult(SearchResult result) {
    Navigator.of(context).pop();
    
    if (result.type == "MATCH_PLAN" || result.type == "MATCH") {
      context.go("/match/${result.id}");
    } else if (result.type == "ROUND" && result.matchId != null) {
      context.go("/match/${result.matchId}");
      // Round selection would be handled by workspace after load
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Dialog(
        backgroundColor: Colors.black87,
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search matches, rounds, tactics...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  _searchBloc.add(SearchQueryChanged(value));
                },
                onSubmitted: (value) {
                  final state = _searchBloc.state;
                  if (state is SearchLoadedState && state.results.isNotEmpty) {
                    final selected = state.results[state.selectedIndex];
                    _navigateToResult(selected);
                  }
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  bloc: _searchBloc,
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return const Center(
                        child: Text(
                          "Start typing to search...",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (state is SearchLoadedState) {
                      if (state.results.isEmpty) {
                        return const Center(
                          child: Text(
                            "No results found",
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final result = state.results[index];
                          final isSelected = index == state.selectedIndex;
                          return SearchResultTile(
                            result: result,
                            isSelected: isSelected,
                            onTap: () => _navigateToResult(result),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

