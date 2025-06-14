import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:firebase_parking/presentation/pages/dashboard/widgets/compact_parked_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentlyParkedSection extends StatefulWidget {
  final VoidCallback? onRefreshRequested; // Callback to request dashboard refresh

  const CurrentlyParkedSection({super.key, this.onRefreshRequested});

  @override
  State<CurrentlyParkedSection> createState() => _CurrentlyParkedSectionState();
}

class _CurrentlyParkedSectionState extends State<CurrentlyParkedSection> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadActiveParking();
  }

  void _loadActiveParking() {
    if (_isRefreshing) return;

    print('🚀 Loading active parking...');
    context.read<ParkingBloc>().add(GetActiveParkingEvent());
  }

  // This will be called from the card when parking is extended
  void _handleParkingUpdate() {
    if (_isRefreshing) return;

    print('🔄 Parking updated, refreshing data...');
    _isRefreshing = true;

    // Small delay to ensure backend has processed the extension
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadActiveParking();

        // Also trigger dashboard-wide refresh
        widget.onRefreshRequested?.call();

        // Reset refresh flag
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isRefreshing = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count and single refresh button
        BlocBuilder<ParkingBloc, ParkingState>(
          builder: (context, state) {
            final activeParking = _getActiveParkingFromState(state);
            final isLoading = state is ParkingLoading;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Currently Parked', style: theme.textTheme.titleLarge),
                    if (activeParking.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                        child: Text('${activeParking.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                // Single refresh button
                IconButton(
                  onPressed: (isLoading || _isRefreshing) ? null : _loadActiveParking,
                  icon: (isLoading || _isRefreshing) ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // Cards with proper update handling
        SizedBox(
          height: 210,
          child: BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, state) {
              print('🔍 Current state: ${state.runtimeType}');

              if (state is ParkingLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ParkingError) {
                print('❌ Error: ${state.message}');
                return _buildErrorCard(theme, state.message);
              }

              final activeParking = _getActiveParkingFromState(state);
              print('📊 Found ${activeParking.length} active parking sessions');

              if (activeParking.isEmpty) {
                return _buildEmptyCard(theme);
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: activeParking.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return CompactParkedCard(
                    parking: activeParking[index],
                    onParkingEnded: _handleParkingUpdate, // Refresh when parking ends
                    onParkingUpdate: _handleParkingUpdate, // Refresh when parking is extended
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_parking_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('No Active Parking', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            Text('Your active sessions will appear here', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String message) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text('Error loading data', style: theme.textTheme.titleMedium?.copyWith(color: Colors.red[600])),
            Text('Tap refresh to try again', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _isRefreshing ? null : _handleParkingUpdate, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  List<ParkingEntity> _getActiveParkingFromState(ParkingState state) {
    try {
      if (state.props.isNotEmpty && state.props[0] is List) {
        final list = state.props[0] as List;
        print('📄 Raw list length: ${list.length}');

        // Filter only active parking using ParkingEntity and isActive property
        final activeParkingList = list.where((parking) => parking is ParkingEntity && parking.isActive).cast<ParkingEntity>().toList();

        print('✅ Active parking found: ${activeParkingList.length}');
        return activeParkingList;
      }
    } catch (e) {
      print('❌ Error getting active parking from state: $e');
    }
    return [];
  }
}
