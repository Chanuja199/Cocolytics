import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/plan_provider.dart';
import '../utils/app_colors.dart';
import '../providers/scan_provider.dart';
import '../providers/active_plan_provider.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/localization_provider.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  // [NEW] This handles loading the treatment if the user comes from the Roadmap
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final planProvider = context.read<PlanProvider>();

      // If no treatment loaded (e.g., came from Roadmap via 'View full plan')
      if (planProvider.currentTreatment == null) {
        final activePlan = context.read<ActivePlanProvider>().activePlan;
        if (activePlan != null && activePlan.diseaseId.isNotEmpty) {
          planProvider.loadTreatment(activePlan.diseaseId);
        }
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.watch<LocalizationProvider>().translate('treatments'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: plan.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : plan.currentTreatment == null
          ? Center(child: Text(context.watch<LocalizationProvider>().translate('no_treatment_data')))
          : _buildContent(context, plan),
    );
  }

  // --- REPLACED _buildContent METHOD ---
  Widget _buildContent(BuildContext context, PlanProvider plan) {
    final treatment = plan.currentTreatment!;

    // 3. INITIALIZE PROVIDERS: Grab the instances needed for saving the plan
    final scanProvider = context.read<ScanProvider>();
    final activePlanProvider = context.read<ActivePlanProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentScan = scanProvider.currentScan;
    final loc = context.watch<LocalizationProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4. SAVE BUTTON LOGIC
          // This block checks if a scan exists and if it's NOT already the active plan
          if (currentScan != null &&
              activePlanProvider.activePlan?.diseaseName !=
                  currentScan.diseaseName)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final userId = authProvider.currentUser?.id ?? 'temp_user_id';

                  // Logic to handle existing plans (Replace vs Keep)
                  if (activePlanProvider.hasPlan) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(loc.translate('replace_plan')),
                        content: Text(
                          'You already have an active plan for '
                          '"${loc.translate(activePlanProvider.activePlan!.diseaseName) ?? activePlanProvider.activePlan!.diseaseName}". '
                          'Do you want to replace it with this new plan?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Keep existing'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Replace'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                    await activePlanProvider.deletePlan(userId);
                  }

                  // Actually create the plan in the database/provider
                  await activePlanProvider.createPlan(
                    userId: userId,
                    scan: currentScan,
                    treatment: treatment,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Treatment plan saved! Track it on your home screen.',
                      ),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                icon: const Icon(Icons.bookmark_add),
                label: Text(
                  loc.translate('save_plan'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // 5. ROADMAP BUTTON
          // Only shows if the user has ALREADY saved this specific disease plan
          if (activePlanProvider.activePlan?.diseaseName ==
              currentScan?.diseaseName)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              child: OutlinedButton.icon(
                onPressed: () => context.push('/roadmap'),
                icon: const Icon(Icons.map_outlined, color: AppColors.primary),
                label: Text(
                  loc.translate('view_roadmap'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // 6. ORIGINAL CONTENT (Short term, Chemical, Long term)
          _sectionCard(
            icon: '🌿',
            iconColor: AppColors.success,
            title: loc.translate('short_term'),
            subtitle: loc.translate('prevention_tips'),
            subtitleColor: AppColors.success,
            child: Column(
              children: treatment.shortTermSteps
                  .asMap()
                  .entries
                  .map((e) => _numberedItem(e.key + 1, e.value, loc))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loc.translate('chemical_action'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: treatment.chemicalTreatments
                  .asMap()
                  .entries
                  .map((e) => _chemicalItem(e.key + 1, e.value, loc))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          _sectionCard(
            icon: '🌱',
            iconColor: AppColors.primaryLight,
            title: loc.translate('long_term'),
            child: Column(
              children: treatment.longTermSteps
                  .asMap()
                  .entries
                  .map((e) => _numberedItem(e.key + 1, e.value, loc))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor ?? AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _numberedItem(int number, String text, LocalizationProvider loc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              loc.translate(text) ?? text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chemicalItem(int number, chemical, LocalizationProvider loc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ${loc.translate(chemical.name) ?? chemical.name}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${loc.translate('use')}: ${loc.translate(chemical.use) ?? chemical.use}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${loc.translate('where_to_buy')}:',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          ...chemical.whereToBuy.map(
            (place) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Text(
                '• ${loc.translate(place) ?? place}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (chemical.youtubeUrl != null) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _launchUrl(chemical.youtubeUrl!),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_filled, color: Colors.red, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    loc.translate('how_to_use'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
