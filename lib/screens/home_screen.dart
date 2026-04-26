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
      if (!mounted) return;
      await context.read<NotificationProvider>().loadNotifications(userId);
      await _triggerSmartNotifications(
        userId: userId,
        planProvider: planProvider,
      );
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
    final district = authProvider.currentUser?.district ?? 'Colombo';

    return Scaffold(
      backgroundColor: const Color(0xFFF5FCED),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icon.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Cocolytics',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006527),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => loc.toggleLocale(),
                      child: const Icon(
                        Icons.language,
                        color: Color(0xFF006527),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => context.push('/history'),
                      child: const Icon(
                        Icons.history,
                        color: Color(0xFF006527),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => _showNotifications(context),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.notifications_none_outlined,
                            color: Color(0xFF006527),
                            size: 24,
                          ),
                          if (notificationProvider.unreadCount > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFBA1A1A),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  notificationProvider.unreadCount > 9
                                      ? '9+'
                                      : '${notificationProvider.unreadCount}',
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await planProvider.loadActivePlan(userId);
          await planProvider.loadDistrictAlert(district);
          await _triggerSmartNotifications(
            userId: userId,
            planProvider: planProvider,
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName 👋',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF006527),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loc.translate('home_summary'),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  color: Color(0xFF3F4A3E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              if (planProvider.state == ActivePlanState.loading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF006527)),
                ),

              if (planProvider.activePlan != null)
                _buildActivePlanCard(context, planProvider, userId)
              else if (planProvider.state == ActivePlanState.loaded)
                _buildNoPlanCard(context),

              const SizedBox(height: 32),

              Text(
                loc.translate('analysis_overview').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3F4A3E),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnalysisOverview(
                planProvider: planProvider,
                mapProvider: mapProvider,
                district: district,
                loc: loc,
              ),

              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  image: const DecorationImage(
                    image: AssetImage('assets/coconut-tree.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR ESTATE',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$district Region',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
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
    final Color severityColor = switch (severity.toLowerCase()) {
      'high' => const Color(0xFF171D14),
      'medium' => const Color(0xFF171D14),
      'low' => const Color(0xFF171D14),
      _ => const Color(0xFF171D14),
    };

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridCard(
                icon: Icons.location_on_outlined,
                iconColor: const Color(0xFF006527),
                title: loc.translate('district_risk'),
                value: risk,
                valueColor: riskColor,
                subtitle: caseCount == 0
                    ? loc.translate('no_active_alerts')
                    : '$caseCount ${loc.translate('cases_in')} $district',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGridCard(
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFBA1A1A),
                title: loc.translate('current_severity'),
                value: plan != null ? severity.toUpperCase() : 'UNKNOWN',
                valueColor: severityColor,
                subtitle: loc.translate('latest_detected'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildGridCard(
          fullWidth: true,
          icon: Icons.bug_report_outlined,
          iconColor: const Color(0xFF006527),
          title: loc.translate('top_disease'),
          value: topDistrict?.mostCommonDisease.isNotEmpty == true
              ? topDistrict!.mostCommonDisease
              : loc.translate('no_cases_yet'),
          valueColor: const Color(0xFF171D14),
          subtitle: topDistrict == null
              ? loc.translate('waiting_scan')
              : '${topDistrict.totalCases} ${loc.translate('cases_in')} ${topDistrict.district}',
        ),
        const SizedBox(height: 16),
        _buildHorizontalTile(
          icon: Icons.bar_chart_rounded,
          title: loc.translate('national_stats'),
          valueRich: TextSpan(
            children: [
              TextSpan(
                text: '$totalCasesCountry ${loc.translate('total')} ',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF171D14),
                ),
              ),
              TextSpan(
                text: '($activeDistricts districts)',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: Color(0xFF8A9792),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (plan != null)
          _buildHorizontalTile(
            icon: Icons.task_alt_outlined,
            iconColor: const Color(0xFFBA1A1A),
            title: loc.translate('pending_actions'),
            valueRich: TextSpan(
              text: '$pendingSteps ${loc.translate('steps_to_complete')}',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
                color: Color(0xFF171D14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5F6F68),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              color: Color(0xFF8A9792),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalTile({
    required IconData icon,
    Color iconColor = const Color(0xFF006527),
    required String title,
    required TextSpan valueRich,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5E5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5F6F68),
                  ),
                ),
                const SizedBox(height: 4),
                RichText(text: valueRich),
              ],
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: 0,
            child: Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.black.withValues(alpha: 0.03),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('active_treatment_plan').toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF006527),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.diseaseName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF171D14),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA4F48A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Ongoing',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF185121),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${plan.doneCount}/${plan.totalCount} ${loc.translate('steps_done')}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF171D14),
                    ),
                  ),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006527),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => context.push('/roadmap'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE4EBDD),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0A7B3E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlanCard(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 60,
            color: Color(0xFF006527),
          ),
          const SizedBox(height: 16),
          Text(
            loc.translate('no_active_plan'),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171D14),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('scan_leaf_start'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              color: Color(0xFF5F6F68),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/camera'),
            icon: const Icon(Icons.document_scanner),
            label: Text(loc.translate('scan_leaf_now')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006527),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final userId =
        context.read<AuthProvider>().currentUser?.id ?? 'temp_user_id';
    
    context.read<NotificationProvider>().markAllReadForUser(userId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) {
        return Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            final items = List<Map<String, dynamic>>.from(
              notificationProvider.notifications,
            );

            if (items.isEmpty) {
              return const SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'No notifications yet.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Color(0xFF5F6F68),
                    ),
                  ),
                ),
              );
            }

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          notificationProvider.clearAllNotifications(userId);
                        },
                        icon: const Icon(Icons.clear_all, color: Colors.red),
                        label: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(24),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final n = items[i];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5FCED),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_active_outlined,
                                  color: Color(0xFF006527),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['title']?.toString() ?? 'Notification',
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF171D14),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['body']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 13,
                                        color: Color(0xFF5F6F68),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                onPressed: () {
                                  if (n['id'] != null) {
                                    notificationProvider.deleteNotification(userId, n['id']);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _riskLabel(int cases) {
    if (cases >= 50) return 'High risk';
    if (cases >= 20) return 'Medium risk';
    return 'Early warning';
  }

  Color _riskColor(int cases) {
    if (cases >= 50) return const Color(0xFFBA1A1A);
    if (cases >= 20) return const Color(0xFFF29900);
    return const Color(0xFFBA1A1A);
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
}
