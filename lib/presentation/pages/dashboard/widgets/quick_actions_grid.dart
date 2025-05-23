import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/blocs/issue/issue_bloc.dart';
import 'package:firebase_parking/presentation/blocs/issue/issue_event.dart';
import 'package:firebase_parking/presentation/blocs/issue/issue_state.dart';
import 'package:firebase_parking/presentation/pages/vehicles/widgets/vehicle_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        QuickActionCard(title: 'Add Vehicle', icon: Icons.add_box, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VehicleFormScreen()))),
        QuickActionCard(title: 'Report Issue', icon: Icons.report_problem, onTap: () => _showReportDialog(context)),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController issueController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocConsumer<IssueBloc, IssueState>(
            listener: (context, state) {
              if (state is IssueCreated) {
                // Close the dialog
                Navigator.pop(dialogContext);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Issue reported successfully!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (state is IssueError) {
                // Show error message but keep dialog open
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: ${state.message}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            builder: (context, state) {
              return AlertDialog(
                title: const Text('Report an Issue'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: issueController, maxLines: 5, decoration: const InputDecoration(hintText: 'Describe the issue...', border: OutlineInputBorder())),
                    if (state is IssueLoading) ...[
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 12), Text('Submitting...')],
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(onPressed: state is IssueLoading ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                  ElevatedButton(onPressed: state is IssueLoading ? null : () => _submitIssue(context, issueController.text), child: const Text('Submit')),
                ],
              );
            },
          ),
    );
  }

  void _submitIssue(BuildContext context, String issueText) {
    if (issueText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please describe the issue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get user info from AuthBloc
    final authState = context.read<AuthBloc>().state;
    String? userId = '';
    String userName = '';

    if (authState is Authenticated) {
      userId = authState.user.id;
      userName = authState.user.name ?? 'Anonymous';
    } else if (authState is ProfileIncomplete) {
      userId = authState.user.id;
      userName = authState.user.name ?? 'Anonymous';
    }

    if (userId!.isNotEmpty) {
      context.read<IssueBloc>().add(CreateIssueEvent(userId: userId, userName: userName, issueText: issueText.trim()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔐 Please log in to report issues', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
