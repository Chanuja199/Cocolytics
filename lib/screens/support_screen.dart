import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';


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

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color bgColor,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            if (!isPrimary)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white : const Color(0xFF006527),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                color: isPrimary ? const Color(0xFF006527) : Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
                const Icon(
                  Icons.help_outline,
                  color: Color(0xFF006527),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  color: Color(0xFF171D14),
                ),
                decoration: InputDecoration(
                  hintText: 'Search topics, FAQs, experts...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF8A9792),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12.0, right: 8.0),
                    child: Icon(Icons.search, color: Color(0xFF006527)),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildSupportCard(
              icon: Icons.phone_in_talk_outlined,
              title: 'Government Hotline',
              subtitle: 'රාජ්‍ය ක්ෂණික ඇමතුම',
              iconColor: const Color(0xFF006527),
              bgColor: Colors.white,
              textColor: const Color(0xFF171D14),
              subtitleColor: const Color(0xFF5F6F68),
              onTap: () => context.push('/hotlines'),
            ),
            _buildSupportCard(
              icon: Icons.psychology_outlined,
              title: 'Expert Consultation',
              subtitle: 'විශේෂඥ උපදෙස්',
              iconColor: Colors.white,
              bgColor: const Color(0xFF1B7A38), // dark green
              textColor: Colors.white,
              subtitleColor: Colors.white.withOpacity(0.8),
              isPrimary: true,
              onTap: () => context.push('/hotlines'),
            ),
            _buildSupportCard(
              icon: Icons.settings_outlined,
              title: 'Technical Support',
              subtitle: 'තාක්ෂණික සහාය',
              iconColor: const Color(0xFF006527),
              bgColor: Colors.white,
              textColor: const Color(0xFF171D14),
              subtitleColor: const Color(0xFF5F6F68),
              onTap: () => context.push('/hotlines'),
            ),

            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agricultural Centers',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF171D14),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'කෘෂිකාර්මික මධ්‍යස්ථාන',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: Color(0xFF5F6F68),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${filtered.length} centers available',
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF006527),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _getTypes().length,
                clipBehavior: Clip.none,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final t = _getTypes()[i];
                  final selected = _selectedType == t;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFA4F48A) // Active Green
                            : const Color(0xFFE4EBDD), // Inactive Grey
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? const Color(0xFF171D14)
                              : const Color(0xFF3F4A3E),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    'No centers match your search.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: Color(0xFF5F6F68),
                    ),
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

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFFD6F6CC), // banner green
                borderRadius: BorderRadius.circular(36),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Join the Farming\nCommunity',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF185121),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Get real-time updates and\nexpert tips from other coconut\nfarmers.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: Color(0xFF4C7D51),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {}, // Community routing logic could go here
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006527),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Join Community',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }
}


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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/icon.png'), // Fallback
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    center.name,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF171D14),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${center.district}${center.type != center.district ? ', ${center.district}' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: Color(0xFF5F6F68),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onMaps,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF5E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: Color(0xFF006527),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


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
