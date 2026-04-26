import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/active_plan_provider.dart';
import '../providers/auth_provider.dart';
import '../models/active_plan_model.dart';
import '../utils/app_colors.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<ActivePlanProvider>();
    final authProvider = context.read<AuthProvider>();
    final plan = planProvider.activePlan;
    final userId = authProvider.currentUser?.id ?? 'temp_user_id';

    if (plan == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, null, userId),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: AppColors.primaryLight),
              SizedBox(height: 16),
              Text(
                'No active treatment plan',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
              SizedBox(height: 8),
              Text(
                'Scan a leaf and save a treatment plan to get started',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, plan, userId),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease header card
            _buildDiseaseCard(plan),
            const SizedBox(height: 20),

            // Progress card
            _buildProgressCard(plan),
            const SizedBox(height: 24),

            // Full treatment detail banner
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Want full details, chemicals & where to buy?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/treatment'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'View full plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Short-term steps
            if (plan.shortTermSteps.isNotEmpty) ...[
              _sectionHeader(
                'Short-Term Steps',
                Icons.flash_on,
                AppColors.warning,
              ),
              const SizedBox(height: 12),
              ...plan.shortTermSteps.asMap().entries.map(
                (e) => _buildRoadmapStep(
                  context: context,
                  step: e.value,
                  index: e.key,
                  userId: userId,
                  planProvider: planProvider,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Chemical steps
            if (plan.chemicalSteps.isNotEmpty) ...[
              _sectionHeader(
                'Chemical Treatment',
                Icons.science,
                AppColors.error,
              ),
              const SizedBox(height: 12),
              ...plan.chemicalSteps.asMap().entries.map(
                (e) => _buildRoadmapStep(
                  context: context,
                  step: e.value,
                  index: e.key,
                  userId: userId,
                  planProvider: planProvider,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Long-term steps
            if (plan.longTermSteps.isNotEmpty) ...[
              _sectionHeader('Long-Term Steps', Icons.eco, AppColors.primary),
              const SizedBox(height: 12),
              ...plan.longTermSteps.asMap().entries.map(
                (e) => _buildRoadmapStep(
                  context: context,
                  step: e.value,
                  index: e.key,
                  userId: userId,
                  planProvider: planProvider,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Completed banner
            if (plan.isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success),
                ),
                child: const Column(
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 8),
                    Text(
                      'All steps completed!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your coconut leaf treatment is complete. '
                      'Scan again to monitor recovery.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    ActivePlanModel? plan,
    String userId,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Treatment Roadmap',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (plan != null)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _showDeleteDialog(context, plan, userId),
          ),
      ],
    );
  }

  Widget _buildDiseaseCard(ActivePlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Leaf image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              plan.scanImageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: AppColors.background,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset('assets/cocolytic-logo.png'),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.diseaseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _severityColor(plan.severity).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.severity.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _severityColor(plan.severity),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Started ${_formatDate(plan.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ActivePlanModel plan) {
    final percent = plan.progressPercent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${plan.doneCount} / ${plan.totalCount} steps',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 12,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                _progressColor(percent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percent * 100).toInt()}% complete',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _progressColor(percent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapStep({
    required BuildContext context,
    required PlanStep step,
    required int index,
    required String userId,
    required ActivePlanProvider planProvider,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => planProvider.toggleStep(userId: userId, stepId: step.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line + dot
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: step.isDone ? AppColors.success : Colors.white,
                    border: Border.all(
                      color: step.isDone ? AppColors.success : color,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: step.isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Step content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: step.isDone
                      ? AppColors.success.withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: step.isDone
                        ? AppColors.success.withOpacity(0.3)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  step.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: step.isDone
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: step.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ActivePlanModel plan,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Treatment Plan?'),
        content: Text(
          'This will delete your current plan for "${plan.diseaseName}". '
          'Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context), // dialog close — this is fine
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog — this is fine
              await context.read<ActivePlanProvider>().deletePlan(userId);
              if (context.mounted) {
                context.go('/home'); // ← use context.go not Navigator.pop
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  Color _progressColor(double percent) {
    if (percent >= 0.8) return AppColors.success;
    if (percent >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
