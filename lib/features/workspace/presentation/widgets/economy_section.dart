import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/buy_type.dart';
import '../../domain/entities/player_buy.dart';
import '../bloc/workspace_bloc.dart';
import '../bloc/workspace_event.dart';

class EconomySection extends StatelessWidget {
  final String roundId;
  final BuyType? buyType;
  final List<PlayerBuy> playerBuys;
  final bool canEdit;

  const EconomySection({
    super.key,
    required this.roundId,
    this.buyType,
    required this.playerBuys,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Economy",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (buyType != null) _EconomyBadge(buyType: buyType!),
              ],
            ),
            const SizedBox(height: 12),
            _BuyTypeSelector(
              current: buyType,
              canEdit: canEdit,
              onChanged: (type) {
                context.read<WorkspaceBloc>().add(
                      BuyTypeChanged(roundId: roundId, buyType: type),
                    );
              },
            ),
            const SizedBox(height: 16),
            _PlayerBuyList(
              playerBuys: playerBuys,
              canEdit: canEdit,
              onChanged: (playerId, weapon) {
                context.read<WorkspaceBloc>().add(
                      PlayerBuyChanged(
                        roundId: roundId,
                        playerId: playerId,
                        weapon: weapon,
                      ),
                    );
              },
            ),
            if (buyType == BuyType.forceBuy)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "High economy risk",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BuyTypeSelector extends StatelessWidget {
  final BuyType? current;
  final bool canEdit;
  final Function(BuyType) onChanged;

  const _BuyTypeSelector({
    required this.current,
    required this.canEdit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<BuyType>(
      value: current,
      decoration: const InputDecoration(
        labelText: "Buy Type",
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: BuyType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name.toUpperCase().replaceAll("_", " ")),
        );
      }).toList(),
      onChanged: canEdit
          ? (value) {
              if (value != null) {
                onChanged(value);
              }
            }
          : null,
    );
  }
}

class _PlayerBuyList extends StatelessWidget {
  final List<PlayerBuy> playerBuys;
  final bool canEdit;
  final Function(String playerId, String weapon) onChanged;

  const _PlayerBuyList({
    required this.playerBuys,
    required this.canEdit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPlayers = ["P1", "P2", "P3", "P4", "P5"];
    final weapons = [
      "VANDAL",
      "PHANTOM",
      "OPERATOR",
      "SHERIFF",
      "NONE",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Player Buys",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        ...defaultPlayers.map((playerId) {
          final buy = playerBuys.firstWhere(
            (b) => b.playerId == playerId,
            orElse: () => PlayerBuy(playerId: playerId, weapon: "NONE"),
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    playerId,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: buy.weapon,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: weapons.map((weapon) {
                      return DropdownMenuItem(
                        value: weapon,
                        child: Text(weapon),
                      );
                    }).toList(),
                    onChanged: canEdit
                        ? (value) {
                            if (value != null) {
                              onChanged(playerId, value);
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _EconomyBadge extends StatelessWidget {
  final BuyType buyType;

  const _EconomyBadge({required this.buyType});

  Color _economyColor(BuyType type) {
    switch (type) {
      case BuyType.fullBuy:
        return Colors.green;
      case BuyType.halfBuy:
        return Colors.orange;
      case BuyType.forceBuy:
        return Colors.redAccent;
      case BuyType.eco:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _economyColor(buyType),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        buyType.name.toUpperCase().replaceAll("_", " "),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}



