import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supporttickets_app/features/work_sessions/viewmodels/work_session_viewmodel.dart';

/// A reusable UI component that displays the current work session's time.
class WorkSessionTimerWidget extends StatelessWidget {
  const WorkSessionTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkSessionViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.currentSession == null) {
          return _OffTheClockCard(viewModel: viewModel);
        }

        if (viewModel.isCompleted) {
          return _CompletedShiftCard(durationSeconds: viewModel.currentDurationSeconds);
        }

        return _ActiveShiftCard(viewModel: viewModel);
      },
    );
  }
}

/// Helper function utilized by multiple sub-components
String _formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
}

/// Sub-component for when the user hasn't started a shift
class _OffTheClockCard extends StatelessWidget {
  final WorkSessionViewModel viewModel;

  const _OffTheClockCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
        side: BorderSide(color: colorScheme.outlineVariant)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.work_off_outlined, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Text('Off the clock', style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
              ],
            ),
            viewModel.isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: Icon(Icons.play_circle_fill, color: colorScheme.primary, size: 32),
                  onPressed: () => viewModel.startSession(),
                  tooltip: 'Start Shift',
                ),
          ],
        ),
      ),
    );
  }
}

/// Sub-component for a finished daily shift
class _CompletedShiftCard extends StatelessWidget {
  final int durationSeconds;

  const _CompletedShiftCard({required this.durationSeconds});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
        side: BorderSide(color: Colors.green.shade200)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shift Completed', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                    Text('Already worked today.', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                  ],
                ),
              ],
            ),
            Text(
              _formatDuration(durationSeconds),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sub-component for an active or paused shift
class _ActiveShiftCard extends StatelessWidget {
  final WorkSessionViewModel viewModel;

  const _ActiveShiftCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isWorking = viewModel.isActive;
    final timeString = _formatDuration(viewModel.currentDurationSeconds);

    return Card(
      elevation: 2,
      color: isWorking ? Colors.blue.shade50 : Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isWorking ? Colors.blue.shade200 : Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isWorking ? Icons.timer : Icons.timer_off,
                  color: isWorking ? Colors.blue.shade700 : Colors.orange.shade700,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: isWorking ? Colors.blue.shade900 : Colors.orange.shade900,
                      ),
                    ),
                    Text(
                      isWorking ? 'Working' : 'Paused',
                      style: TextStyle(fontSize: 12, color: isWorking ? Colors.blue.shade700 : Colors.orange.shade700),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (viewModel.isLoading)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                else ...[
                  IconButton(
                    icon: Icon(
                      isWorking ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: isWorking ? Colors.blue.shade700 : Colors.orange.shade700,
                      size: 32,
                    ),
                    onPressed: () {
                      if (isWorking) {
                        viewModel.pauseSession();
                      } else {
                        viewModel.resumeSession();
                      }
                    },
                    tooltip: isWorking ? 'Pause Shift' : 'Resume Shift',
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop_circle, color: Colors.redAccent, size: 32),
                    onPressed: () => viewModel.endSession(),
                    tooltip: 'End Shift',
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}