import 'dart:async';
import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:flutter/material.dart';

class ParkingTimerWidget extends StatefulWidget {
  final ParkingEntity parking;
  final VoidCallback? onExtendPressed;
  final bool showExtendButton;

  const ParkingTimerWidget({super.key, required this.parking, this.onExtendPressed, this.showExtendButton = true});

  @override
  State<ParkingTimerWidget> createState() => _ParkingTimerWidgetState();
}

class _ParkingTimerWidgetState extends State<ParkingTimerWidget> {
  Timer? _timer;
  Duration _currentElapsed = Duration.zero;
  Duration _currentRemaining = Duration.zero;
  ParkingTimeStatus _timeStatus = ParkingTimeStatus.safe;

  @override
  void initState() {
    super.initState();
    _updateTimes();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _updateTimes();
      }
    });
  }

  void _updateTimes() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.parking.startedAt);
    final totalTime = widget.parking.totalTimeLimit;
    final remaining = totalTime - elapsed;

    setState(() {
      _currentElapsed = elapsed;
      _currentRemaining = remaining.isNegative ? Duration.zero : remaining;
      _timeStatus = _calculateTimeStatus(remaining);
    });
  }

  ParkingTimeStatus _calculateTimeStatus(Duration remaining) {
    if (remaining.isNegative) {
      return ParkingTimeStatus.expired;
    } else if (remaining.inMinutes <= 5) {
      return ParkingTimeStatus.critical;
    } else if (remaining.inMinutes <= 15) {
      return ParkingTimeStatus.warning;
    } else {
      return ParkingTimeStatus.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Elapsed time display
        _buildTimeRow(
          icon: Icons.access_time,
          label: 'Parked',
          time: _formatDuration(_currentElapsed),
          total: _formatDuration(widget.parking.totalTimeLimit),
          color: Colors.grey[600]!,
        ),

        const SizedBox(height: 4),

        // Remaining time display (color-coded)
        _buildRemainingTimeRow(),

        const SizedBox(height: 6),

        // Progress bar
        _buildProgressBar(),

        // Extend button (shown when needed)
        if (_shouldShowExtendButton()) ...[const SizedBox(height: 8), _buildExtendButton()],
      ],
    );
  }

  Widget _buildTimeRow({required IconData icon, required String label, required String time, String? total, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text('$label: $time${total != null ? ' / $total' : ''}', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRemainingTimeRow() {
    final color = _getStatusColor();
    final remaining = _formatDuration(_currentRemaining);
    final status = _getStatusText();

    return Row(
      children: [
        Icon(_getStatusIcon(), size: 14, color: color),
        const SizedBox(width: 4),
        Text('$remaining $status', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = _calculateProgress();
    final color = _getStatusColor();

    return Container(
      height: 4,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
      child: FractionallySizedBox(
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      ),
    );
  }

  Widget _buildExtendButton() {
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: ElevatedButton.icon(
        onPressed: widget.onExtendPressed,
        icon: const Icon(Icons.add_circle_outline, size: 14),
        label: const Text('Extend', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: _getStatusColor(), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8), elevation: 1),
      ),
    );
  }

  bool _shouldShowExtendButton() {
    return widget.showExtendButton && (_timeStatus == ParkingTimeStatus.warning || _timeStatus == ParkingTimeStatus.critical);
  }

  double _calculateProgress() {
    final totalMinutes = widget.parking.totalTimeLimit.inMinutes;
    final elapsedMinutes = _currentElapsed.inMinutes;

    if (totalMinutes <= 0) return 0.0;

    final progress = elapsedMinutes / totalMinutes;
    return progress.clamp(0.0, 1.0);
  }

  Color _getStatusColor() {
    switch (_timeStatus) {
      case ParkingTimeStatus.safe:
        return Colors.green;
      case ParkingTimeStatus.warning:
        return Colors.orange;
      case ParkingTimeStatus.critical:
        return Colors.red;
      case ParkingTimeStatus.expired:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_timeStatus) {
      case ParkingTimeStatus.safe:
        return Icons.check_circle;
      case ParkingTimeStatus.warning:
        return Icons.warning;
      case ParkingTimeStatus.critical:
        return Icons.error;
      case ParkingTimeStatus.expired:
        return Icons.schedule;
    }
  }

  String _getStatusText() {
    switch (_timeStatus) {
      case ParkingTimeStatus.safe:
        return 'left';
      case ParkingTimeStatus.warning:
        return 'left ⚠️';
      case ParkingTimeStatus.critical:
        return 'left 🚨';
      case ParkingTimeStatus.expired:
        return 'EXPIRED';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

enum ParkingTimeStatus {
  safe, // > 15 minutes left
  warning, // 5-15 minutes left
  critical, // 0-5 minutes left
  expired, // Time's up
}
