import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/active_plan_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/localization_provider.dart';
import '../providers/map_provider.dart';
import '../providers/notification_provider.dart';
import '../services/connectivity_service.dart';
import '../services/local_storage_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final planProvider = context.read<ActivePlanProvider>();
      final mapProvider = context.read<MapProvider>();
      final connectivity = context.read<ConnectivityService>();
      final userId = auth.currentUser?.id ?? 'temp_user_id';
      final district = auth.currentUser?.district ?? 'Colombo';
      final isOnline = await connectivity.isOnline();

      await planProvider.loadActivePlan(userId);
      await planProvider.loadDistrictAlert(district);
      await mapProvider.loadDistrictData(isOnline: isOnline);
      await context.read<NotificationProvider>().loadNotifications(userId);
      if (mounted) {
        await _triggerSmartNotifications(
          userId: userId,
          planProvider: planProvider,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<ActivePlanProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final mapProvider = context.watch<MapProvider>();
    final loc = context.watch<LocalizationProvider>();
    final userId = authProvider.currentUser?.id ?? 'temp_user_id';
    final userName = authProvider.currentUser?.name ?? 'Farmer';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset('assets/cocolytic-logo.png'),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Cocolytics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => loc.toggleLocale(),
            icon: const Icon(Icons.language, color: AppColors.primary),
            tooltip: loc.translate('change_language'),
          ),
          IconButton(
            onPressed: () => context.go('/history'),
            icon: const Icon(Icons.history, color: AppColors.primary),
            tooltip: loc.translate('history'),
          ),
          IconButton(
            onPressed: () => _showNotifications(context),
            tooltip: 'Notifications',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: AppColors.primary),
                if (notificationProvider.unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        notificationProvider.unreadCount > 9
                            ? '9+'
                            : '${notificationProvider.unreadCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner, color: AppColors.primary),
            onPressed: () => context.go('/camera'),
            tooltip: 'Scan new coconut leaf',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final district = authProvider.currentUser?.district ?? 'Colombo';
          await planProvider.loadActivePlan(userId);
          await planProvider.loadDistrictAlert(district);
          await _triggerSmartNotifications(
            userId: userId,
            planProvider: planProvider,
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                '${loc.translate('greeting')}, $userName 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.translate('home_summary'),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              _buildAnalysisOverview(
                planProvider: planProvider,
                mapProvider: mapProvider,
                district: authProvider.currentUser?.district ?? 'Colombo',
                loc: loc,
              ),
              const SizedBox(height: 16),

              if (planProvider.state == ActivePlanState.loading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),

              if (planProvider.activePlan != null)
                _buildActivePlanCard(context, planProvider, userId)
              else if (planProvider.state == ActivePlanState.loaded)
                _buildNoPlanCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisOverview({
    required ActivePlanProvider planProvider,
    required MapProvider mapProvider,
    required String district,
    required LocalizationProvider loc,
  }) {
    final plan = planProvider.activePlan;
    final alert = planProvider.districtAlert;
    final allDistricts = mapProvider.districts;
    final topDistrict = allDistricts.isNotEmpty ? allDistricts.first : null;
    final totalCasesCountry = allDistricts.fold<int>(
      0,
      (sum, d) => sum + d.totalCases,
    );
    final activeDistricts = allDistricts.where((d) => d.totalCases > 0).length;
    final int caseCount = (alert?['totalCases'] ?? 0) as int;
    final String risk = _riskLabel(caseCount);
    final Color riskColor = _riskColor(caseCount);
    final int pendingSteps = plan == null
        ? 0
        : plan.steps.where((s) => !s.isDone).length;
    final String severity = plan?.severity ?? 'unknown';
    final String severityLabel = severity.isEmpty
        ? 'Unknown'
        : '${severity[0].toUpperCase()}${severity.substring(1)}';
    final Color severityColor = switch (severity.toLowerCase()) {
      'high' => AppColors.error,
      'medium' => AppColors.warning,
      'low' => AppColors.success,
      _ => AppColors.textSecondary,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('analysis_overview'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Live status for $district district and your current treatment progress.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  title: loc.translate('district_risk'),
                  value: risk,
                  hint: caseCount == 0
                      ? loc.translate('no_active_alerts')
                      : '$caseCount ${loc.translate('cases_in')}',
                  valueColor: riskColor,
                  icon: Icons.shield_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  title: loc.translate('current_severity'),
                  value: severityLabel,
                  hint: plan == null
                      ? loc.translate('no_active_case')
                      : loc.translate('latest_detected'),
                  valueColor: severityColor,
                  icon: Icons.health_and_safety_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  title: loc.translate('top_disease'),
                  value: topDistrict?.mostCommonDisease.isNotEmpty == true
                      ? topDistrict!.mostCommonDisease
                      : loc.translate('no_cases_yet'),
                  hint: topDistrict == null
                      ? loc.translate('waiting_scan')
                      : '${topDistrict.totalCases} ${loc.translate('cases_in')} ${topDistrict.district}',
                  valueColor: AppColors.textPrimary,
                  icon: Icons.analytics_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricTile(
                  title: loc.translate('national_stats'),
                  value: totalCasesCountry == 0
                      ? 'No cases yet'
                      : '$totalCasesCountry ${loc.translate('total')}',
                  hint: activeDistricts == 0
                      ? 'No affected districts'
                      : '$activeDistricts ${loc.translate('districts_reporting')}',
                  valueColor: totalCasesCountry == 0
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  icon: Icons.public_outlined,
                ),
              ),
            ],
          ),
          if (plan != null) ...[
            const SizedBox(height: 10),
            _metricTile(
              title: loc.translate('pending_actions'),
              value: '$pendingSteps',
              hint: pendingSteps == 0
                  ? loc.translate('all_clear')
                  : loc.translate('steps_to_complete'),
              valueColor: pendingSteps == 0
                  ? AppColors.success
                  : AppColors.warning,
              icon: Icons.task_alt_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricTile({
    required String title,
    required String value,
    required String hint,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(
    BuildContext context,
    ActivePlanProvider planProvider,
    String userId,
  ) {
    final plan = planProvider.activePlan!;
    final percent = plan.progressPercent;
    final loc = context.watch<LocalizationProvider>();
    final pendingSteps = plan.steps.where((s) => !s.isDone).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.watch<LocalizationProvider>().translate(
                'active_treatment_plan',
              ),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/roadmap'),
              child: Text(
                context.watch<LocalizationProvider>().translate('view_all'),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Plan summary card
        GestureDetector(
          onTap: () => context.push('/roadmap'),
          child: Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        plan.scanImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: AppColors.background,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/cocolytic-logo.png'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.diseaseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${plan.doneCount}/${plan.totalCount} ${context.watch<LocalizationProvider>().translate('steps_done')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percent >= 0.8
                          ? AppColors.success
                          : percent >= 0.4
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(percent * 100).toInt()}% ${context.watch<LocalizationProvider>().translate('complete')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Today's pending steps (max 3)
        if (pendingSteps.isNotEmpty) ...[
          Text(
            context.watch<LocalizationProvider>().translate('what_to_do_next'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...pendingSteps.map(
            (step) => GestureDetector(
              onTap: () =>
                  planProvider.toggleStep(userId: userId, stepId: step.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.translate(step.text) ?? step.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (plan.steps.where((s) => !s.isDone).length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${plan.steps.where((s) => !s.isDone).length - 3} ${context.watch<LocalizationProvider>().translate('more_steps_roadmap')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],

        if (plan.isCompleted)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All treatment steps completed! 🎉 Scan again to monitor recovery.',
                    style: TextStyle(color: AppColors.success, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),
      ],
    );
  }

  String _riskLabel(int cases) {
    if (cases >= 50) return 'High risk';
    if (cases >= 20) return 'Medium risk';
    return 'Early warning';
  }

  Color _riskColor(int cases) {
    if (cases >= 50) return AppColors.error;
    if (cases >= 20) return AppColors.warning;
    return AppColors.primary;
  }

  Future<void> _triggerSmartNotifications({
    required String userId,
    required ActivePlanProvider planProvider,
  }) async {
    final notificationProvider = context.read<NotificationProvider>();
    final alert = planProvider.districtAlert;
    final plan = planProvider.activePlan;

    if (alert != null) {
      final signature =
          '${alert['district']}_${alert['diseaseName']}_${alert['totalCases']}';
      final last = LocalStorageService.getString(
        AppConstants.userBox,
        'last_alert_$userId',
      );
      if (last != signature) {
        await notificationProvider.addNotificationForUser(
          userId: userId,
          title: 'District Alert',
          body:
              '${alert['diseaseName']} is increasing in ${alert['district']} (${alert['totalCases']} cases).',
          type: 'district_alert',
        );
        await LocalStorageService.saveString(
          AppConstants.userBox,
          'last_alert_$userId',
          signature,
        );
      }
    }

    if (plan != null && !plan.isCompleted) {
      final pending = plan.steps.where((s) => !s.isDone).length;
      if (pending > 0) {
        final today = DateTime.now().toIso8601String().split('T').first;
        final reminderKey = '${plan.id}_$today';
        final lastReminder = LocalStorageService.getString(
          AppConstants.userBox,
          'last_plan_reminder_$userId',
        );
        if (lastReminder != reminderKey) {
          await notificationProvider.addNotificationForUser(
            userId: userId,
            title: 'Treatment Reminder',
            body:
                'You still have $pending pending step${pending > 1 ? 's' : ''} in your treatment plan.',
            type: 'plan_reminder',
          );
          await LocalStorageService.saveString(
            AppConstants.userBox,
            'last_plan_reminder_$userId',
            reminderKey,
          );
        }
      }
    }

    if (plan != null && plan.isCompleted) {
      final lastCompleted = LocalStorageService.getString(
        AppConstants.userBox,
        'last_completed_plan_$userId',
      );
      if (lastCompleted != plan.id) {
        await notificationProvider.addNotificationForUser(
          userId: userId,
          title: 'Plan Completed',
          body:
              'Great job! You completed your ${plan.diseaseName} treatment plan.',
          type: 'plan_complete',
        );
        await LocalStorageService.saveString(
          AppConstants.userBox,
          'last_completed_plan_$userId',
          plan.id,
        );
      }
    }
  }

  void _showNotifications(BuildContext context) {
    final userId =
        context.read<AuthProvider>().currentUser?.id ?? 'temp_user_id';
    final notificationProvider = context.read<NotificationProvider>();
    final items = List<Map<String, dynamic>>.from(
      notificationProvider.notifications,
    );
    notificationProvider.markAllReadForUser(userId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        if (items.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (_, i) {
              final n = items[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                ),
                title: Text(
                  n['title']?.toString() ?? 'Notification',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(n['body']?.toString() ?? ''),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNoPlanCard(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Image.asset('assets/cocolytic-logo.png'),
          ),
          const SizedBox(height: 12),
          Text(
            loc.translate('no_active_plan'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('scan_leaf_start'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/camera'),
            icon: const Icon(Icons.document_scanner),
            label: Text(loc.translate('scan_leaf_now')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ActivePlanProvider planProvider,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Treatment Plan?'),
        content: const Text(
          'This will delete your current plan and all progress. '
          'You can create a new one after scanning a leaf.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // dialog — fine
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog — fine
              await planProvider.deletePlan(userId);
              if (context.mounted) {
                await planProvider.loadActivePlan(userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Plan deleted. Scan a new leaf to start fresh.',
                    ),
                    backgroundColor: AppColors.warning,
                  ),
                );
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
}
