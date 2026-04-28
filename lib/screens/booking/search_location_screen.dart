import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  String _searchQuery = '';

  final List<_LocationSuggestion> _allSuggestions = const <_LocationSuggestion>[
    _LocationSuggestion(
      title: 'Home',
      subtitle: '357 Ratchaprarop Rd, Bangkok',
      distance: '4.2 km',
      icon: Icons.home_outlined,
      isPrimary: true,
    ),
    _LocationSuggestion(
      title: 'The Palladium World Shopping',
      subtitle: '555 Ratchaprarop Rd, Bangkok',
      distance: '3.9 km',
      icon: Icons.access_time,
    ),
    _LocationSuggestion(
      title: 'ICONSIAM',
      subtitle: 'ICS: Gate 1 Lotus\'s Prive',
      distance: '6.0 km',
      icon: Icons.access_time,
    ),
    _LocationSuggestion(
      title: 'Indra Square',
      subtitle: 'Ratchathewi, Bangkok',
      distance: '4.1 km',
      icon: Icons.access_time,
    ),
    _LocationSuggestion(
      title: 'Butsabong Apartment',
      subtitle: 'Sukhumvit 87 Alley, Bangkok',
      distance: '5.1 km',
      icon: Icons.access_time,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: '260/5 Sukhumvit Road');
    _destinationController = TextEditingController();
    _destinationController.addListener(() {
      setState(() {
        _searchQuery = _destinationController.text;
      });
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _swapLocations() {
    setState(() {
      final String temp = _pickupController.text;
      _pickupController.text = _destinationController.text;
      _destinationController.text = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final filteredSuggestions = _allSuggestions.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 26),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Route',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _RouteInputCard(
                    pickupController: _pickupController,
                    destinationController: _destinationController,
                    onSwap: _swapLocations,
                  ),
                  const SizedBox(height: 20),
                  if (_searchQuery.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        'Recent Places',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        'Search Results',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                  if (filteredSuggestions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'No locations found for "$_searchQuery"',
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...filteredSuggestions.map(
                      (suggestion) => _SuggestionTile(
                        suggestion: suggestion,
                        onTap: () {
                          _destinationController.text = suggestion.title;
                          // Allow user to see selection quickly before navigating
                          Future.delayed(const Duration(milliseconds: 200), () {
                            if (mounted) {
                              context.pushNamed('rideCategory');
                            }
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteInputCard extends StatelessWidget {
  const _RouteInputCard({
    required this.pickupController,
    required this.destinationController,
    this.onSwap,
  });

  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final VoidCallback? onSwap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFE5C2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1AEB920A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: pickupController,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor,
                        border: Border.all(
                          color: const Color(0xFFFFE9CC),
                          width: 3,
                        ),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 22,
                        color: AppTheme.primaryDark,
                      ),
                      onPressed: () {},
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFF4E5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: destinationController,
                  autofocus: true,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Dropoff location',
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 24,
                      color: AppTheme.primaryDark,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFFCF8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryDark,
                        width: 2.2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    // Add clear button or place icon
                    suffixIcon: destinationController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              destinationController.clear();
                            },
                          )
                        : Container(
                            width: 44,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE9CC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.place,
                              size: 20,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onTap});

  final _LocationSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Color titleColor = suggestion.isPrimary
        ? const Color(0xFF1B2024)
        : const Color(0xFF1F2428);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: const Color(0x1FFE8C00),
      highlightColor: const Color(0x10FE8C00),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Icon(
                suggestion.icon,
                size: 24,
                color: suggestion.isPrimary
                    ? AppTheme.primaryColor
                    : const Color(0xFF787E80),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5A6267),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              suggestion.distance,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF596165),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSuggestion {
  const _LocationSuggestion({
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.icon,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final String distance;
  final IconData icon;
  final bool isPrimary;
}
