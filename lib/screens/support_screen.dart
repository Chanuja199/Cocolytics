import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/localization_provider.dart';
import '../utils/app_colors.dart';

// ── Data model ───────────────────────────────────────────────────────────────

class _AgriCenter {
  final String name;
  final String type;
  final String district;
  final double lat;
  final double lng;
  final String phone;

  const _AgriCenter({
    required this.name,
    required this.type,
    required this.district,
    required this.lat,
    required this.lng,
    this.phone = '',
  });
}

const List<_AgriCenter> _centers = [
  // ── Department of Agriculture – Main & Regional Centers ──
  _AgriCenter(
    name: 'Dept. of Agriculture – Head Office',
    type: 'Head Office',
    district: 'Peradeniya',
    lat: 7.2675,
    lng: 80.5989,
    phone: '+94 81 238 8011',
  ),
  _AgriCenter(
    name: 'Rice Research & Development Institute',
    type: 'Research Institute',
    district: 'Kurunegala',
    lat: 7.5324,
    lng: 80.4340,
    phone: '+94 37 228 7291',
  ),
  _AgriCenter(
    name: 'Horticultural Crops Research & Dev. Institute (HORDI)',
    type: 'Research Institute',
    district: 'Kandy',
    lat: 7.2731,
    lng: 80.5980,
    phone: '+94 81 238 8316',
  ),
  _AgriCenter(
    name: 'Field Crops Research & Development Institute',
    type: 'Research Institute',
    district: 'Anuradhapura',
    lat: 8.3300,
    lng: 80.4200,
    phone: '+94 25 226 6200',
  ),
  _AgriCenter(
    name: 'Regional Agri. Research & Dev. Centre – Bombuwala',
    type: 'Regional Centre',
    district: 'Kalutara',
    lat: 6.6230,
    lng: 80.1020,
  ),
  _AgriCenter(
    name: 'Regional Agri. Research & Dev. Centre – Aralaganwila',
    type: 'Regional Centre',
    district: 'Polonnaruwa',
    lat: 7.9667,
    lng: 81.0667,
    phone: '+94 27 225 5060',
  ),
  _AgriCenter(
    name: 'Regional Agri. Research & Dev. Centre – Ambalantota',
    type: 'Regional Centre',
    district: 'Hambantota',
    lat: 6.1124,
    lng: 81.0234,
  ),
  _AgriCenter(
    name: 'Regional Agri. Research & Dev. Centre – Labuduwa',
    type: 'Regional Centre',
    district: 'Galle',
    lat: 6.1630,
    lng: 80.2460,
  ),
  _AgriCenter(
    name: 'Regional Agri. Research & Dev. Centre – Girandurukotte',
    type: 'Regional Centre',
    district: 'Kandy',
    lat: 7.8270,
    lng: 81.0000,
  ),

  // ── Specialty Research Institutes ──
  _AgriCenter(
    name: 'Tea Research Institute of Sri Lanka',
    type: 'Research Institute',
    district: 'Nuwara Eliya',
    lat: 6.9497,
    lng: 80.6350,
    phone: '+94 52 222 2301',
  ),
  _AgriCenter(
    name: 'Rubber Research Institute of Sri Lanka',
    type: 'Research Institute',
    district: 'Kalutara',
    lat: 6.4380,
    lng: 80.0730,
    phone: '+94 34 224 7426',
  ),
  _AgriCenter(
    name: 'Coconut Research Institute of Sri Lanka',
    type: 'Research Institute',
    district: 'Kurunegala',
    lat: 7.4333,
    lng: 79.9333,
    phone: '+94 37 226 1393',
  ),
  _AgriCenter(
    name: 'Sugarcane Research Institute',
    type: 'Research Institute',
    district: 'Monaragala',
    lat: 6.4400,
    lng: 80.9000,
    phone: '+94 47 223 3317',
  ),
  _AgriCenter(
    name: 'Central Research Station – Matale (Dept. of Export Agriculture)',
    type: 'Export Agri. Research',
    district: 'Matale',
    lat: 7.4700,
    lng: 80.6230,
    phone: '+94 66 222 2822',
  ),
  _AgriCenter(
    name: 'National Spice Garden',
    type: 'Botanical Garden',
    district: 'Matale',
    lat: 7.4675,
    lng: 80.6231,
  ),

  // ── Provincial / District Agriculture Offices ──
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – Western Province',
    type: 'Provincial Office',
    district: 'Colombo',
    lat: 6.9271,
    lng: 79.8612,
    phone: '+94 11 269 4416',
  ),
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – Central Province',
    type: 'Provincial Office',
    district: 'Kandy',
    lat: 7.2906,
    lng: 80.6337,
    phone: '+94 81 222 3897',
  ),
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – Southern Province',
    type: 'Provincial Office',
    district: 'Galle',
    lat: 6.0535,
    lng: 80.2210,
    phone: '+94 91 222 2146',
  ),
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – Northern Province',
    type: 'Provincial Office',
    district: 'Jaffna',
    lat: 9.6615,
    lng: 80.0255,
    phone: '+94 21 222 2494',
  ),
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – Eastern Province',
    type: 'Provincial Office',
    district: 'Trincomalee',
    lat: 8.5874,
    lng: 81.2152,
    phone: '+94 26 222 2044',
  ),
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – North Western Province',
    type: 'Provincial Office',
    district: 'Kurunegala',
    lat: 7.4867,
    lng: 80.3647,
    phone: '+94 37 222 2033',
  ),
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – North Central Province',
    type: 'Provincial Office',
    district: 'Anuradhapura',
    lat: 8.3114,
    lng: 80.4037,
    phone: '+94 25 222 2374',
  ),
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – Uva Province',
    type: 'Provincial Office',
    district: 'Badulla',
    lat: 6.9934,
    lng: 81.0550,
    phone: '+94 55 222 2051',
  ),
  _AgriCenter(
    name: 'Provincial Dept. of Agriculture – Sabaragamuwa Province',
    type: 'Provincial Office',
    district: 'Ratnapura',
    lat: 6.6828,
    lng: 80.3992,
    phone: '+94 45 222 2319',
  ),
];

// ── Color map for center types ───────────────────────────────────────────────

Color _typeColor(String type) {
  switch (type) {
    case 'Head Office':
      return Colors.deepOrange;
    case 'Research Institute':
      return const Color(0xFF2E8B57);
    case 'Regional Centre':
      return Colors.blue;
    case 'Export Agri. Research':
      return Colors.teal;
    case 'Botanical Garden':
      return Colors.green;
    case 'Provincial Office':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _selectedType = 'All';
  String _searchQuery = '';
  _AgriCenter? _selectedCenter;

  List<String> _getTypes() {
    return [
      'All',
      'Research Institute',
      'Regional Centre',
      'Provincial Office',
      'Export Agri. Research',
      'Head Office',
      'Botanical Garden',
    ];
  }

  List<_AgriCenter> get _filtered {
    return _centers.where((c) {
      final matchesType = _selectedType == 'All' || c.type == _selectedType;
      final matchesSearch =
          _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.district.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
  }

  Future<void> _openMaps(_AgriCenter center) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${center.lat},${center.lng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callCenter(_AgriCenter center) async {
    if (center.phone.isEmpty) return;
    final uri = Uri.parse('tel:${center.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showCenterSheet(_AgriCenter center) {
    setState(() => _selectedCenter = center);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CenterDetailSheet(
        center: center,
        onOpenMaps: () => _openMaps(center),
        onCall: center.phone.isNotEmpty ? () => _callCenter(center) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final loc = context.watch<LocalizationProvider>();

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
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset('assets/cocolytic-logo.png'),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.watch<LocalizationProvider>().translate('support'),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('how_can_we_help'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ── Search bar ───────────────────────────────────────────────
            TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: loc.translate('search_topics'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Support option cards ─────────────────────────────────────
            ...[
              (
                Icons.account_balance,
                Colors.orange,
                loc.translate('government_hotline'),
                loc.translate('contact_state_agri'),
                '/hotlines',
              ),
              (
                Icons.psychology,
                Colors.blue,
                loc.translate('expert_consultation'),
                loc.translate('chat_with_pathologists'),
                '/hotlines',
              ),
              (
                Icons.headset_mic,
                Colors.purple,
                loc.translate('technical_support'),
                loc.translate('app_issues'),
                '/hotlines',
              ),
            ].map(
              (item) => GestureDetector(
                onTap: () => context.push(item.$5),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.$2.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$1, color: item.$2),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$3,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.$4,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
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
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Agricultural Centers section ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('agricultural_centers'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filtered.length} ${loc.translate('agri_centers_count')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Type filter chips ────────────────────────────────────────
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _getTypes().length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _getTypes()[i];
                  final selected = _selectedType == t;
                  final displayLabel = t == 'All' ? loc.translate('all') : t;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        displayLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Center cards ─────────────────────────────────────────────
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No centers match your search.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...filtered.map(
                (center) => _CenterCard(
                  center: center,
                  onTap: () => _showCenterSheet(center),
                  onMaps: () => _openMaps(center),
                ),
              ),

            const SizedBox(height: 20),

            // ── Legend ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legend',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: _getTypes()
                        .where((t) => t != 'All')
                        .map(
                          (t) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _typeColor(t),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(t, style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── FAQ section ──────────────────────────────────────────────
            const Text(
              'Common Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...[
              (
                'How accurate is the disease detection?',
                'Our AI-powered detection system can identify common plant diseases with high accuracy when the image is clear and well lit. For best results, scan the affected leaf in natural light and keep the camera steady.',
              ),
              (
                'Is my farm data shared with others?',
                'No. Your farm data is kept private and is not shared with other users or third parties without your permission. We use secure storage methods to protect your information.',
              ),
              (
                'What if the scanner doesn\'t recognize a spot?',
                'If the scanner cannot recognize a spot, try taking another photo from a closer angle with better lighting. If the issue continues, you can use Expert Consultation or Technical Support for further help.',
              ),
            ].map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  title: Text(item.$1, style: const TextStyle(fontSize: 14)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Center list card ─────────────────────────────────────────────────────────

class _CenterCard extends StatelessWidget {
  final _AgriCenter center;
  final VoidCallback onTap;
  final VoidCallback onMaps;

  const _CenterCard({
    required this.center,
    required this.onTap,
    required this.onMaps,
  });

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(center.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Row(
          children: [
            // Type badge dot
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.agriculture, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    center.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: color),
                      const SizedBox(width: 3),
                      Text(
                        center.district,
                        style: TextStyle(fontSize: 11, color: color),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          center.type,
                          style: TextStyle(fontSize: 10, color: color),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Open in maps icon
            IconButton(
              icon: const Icon(Icons.map_outlined, color: AppColors.primary),
              onPressed: onMaps,
              tooltip: 'Open in Maps',
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet detail ──────────────────────────────────────────────────────

class _CenterDetailSheet extends StatelessWidget {
  final _AgriCenter center;
  final VoidCallback onOpenMaps;
  final VoidCallback? onCall;

  const _CenterDetailSheet({
    required this.center,
    required this.onOpenMaps,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(center.type);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              center.type,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            center.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                center.district,
                style: TextStyle(color: color, fontSize: 13),
              ),
            ],
          ),

          if (center.phone.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  center.phone,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],

          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.my_location, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${center.lat.toStringAsFixed(4)}°N, ${center.lng.toStringAsFixed(4)}°E',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenMaps,
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
