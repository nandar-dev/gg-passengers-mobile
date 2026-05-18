import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gg/shared/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/booking/domain/entities/booking_stop.dart';
import '../../../../features/booking/domain/entities/geocoded_location.dart';
import '../../../../features/booking/domain/use_cases/get_geocoded_location_use_case.dart';
import '../../../../features/booking/presentation/models/booking_args.dart';
import '../../../../shared/widgets/app_message.dart';

enum _RouteField { pickup, waypoint, dropoff }

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key, this.serviceId});

  final String? serviceId;

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  static const String _recentPlacesKey = 'booking.recent_places';
  static const String _defaultPickupText = '';

  late final TextEditingController _pickupController;
  late final TextEditingController _waypointController;
  late final TextEditingController _dropoffController;
  late final FocusNode _pickupFocusNode;
  late final FocusNode _waypointFocusNode;
  late final FocusNode _dropoffFocusNode;
  late final String _serviceId;
  bool _isResolvingPickup = false;
  bool _isResolvingRoute = false;
  bool _isSearching = false;
  bool _isPickupFocused = false;
  bool _isWaypointFocused = false;
  bool _isDropoffFocused = false;
  _RouteField _activeField = _RouteField.dropoff;
  Position? _currentPosition;
  String? _currentLocationLabel;
  Timer? _searchDebounce;
  List<_LocationSuggestion> _recentSuggestions = const [];
  List<_LocationSuggestion> _remoteSuggestions = const [];
  bool _showWaypoint = false;
  String _lastSearchQuery = '';
  int _searchSequence = 0;

  @override
  void initState() {
    super.initState();
    _serviceId = widget.serviceId?.trim() ?? '';
    _pickupController = TextEditingController(text: _defaultPickupText);
    _waypointController = TextEditingController();
    _dropoffController = TextEditingController();
    _pickupFocusNode = FocusNode()..addListener(_handlePickupFocus);
    _waypointFocusNode = FocusNode()..addListener(_handleWaypointFocus);
    _dropoffFocusNode = FocusNode()..addListener(_handleDropoffFocus);
    _loadRecentPlaces();
    _prefillCurrentLocation();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _pickupFocusNode
      ..removeListener(_handlePickupFocus)
      ..dispose();
    _waypointFocusNode
      ..removeListener(_handleWaypointFocus)
      ..dispose();
    _dropoffFocusNode
      ..removeListener(_handleDropoffFocus)
      ..dispose();
    _pickupController.dispose();
    _waypointController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  void _handlePickupFocus() {
    final bool focused = _pickupFocusNode.hasFocus;
    if (_isPickupFocused == focused) return;

    setState(() { _isPickupFocused = focused; });
    if (!focused) return;

    if (_currentLocationLabel != null &&
        (_pickupController.text.trim().isEmpty ||
            _pickupController.text.trim() == _defaultPickupText)) {
      _pickupController.text = _currentLocationLabel!;
    }

    if (focused) {
      _activeField = _RouteField.pickup;
      _scheduleSearch(_pickupController.text);
    }
  }

  void _handleWaypointFocus() {
    final bool focused = _waypointFocusNode.hasFocus;
    if (_isWaypointFocused == focused) return;

    setState(() { _isWaypointFocused = focused; });

    if (focused && _showWaypoint) {
      _activeField = _RouteField.waypoint;
      _scheduleSearch(_waypointController.text);
    }
  }

  void _handleDropoffFocus() {
    final bool focused = _dropoffFocusNode.hasFocus;
    if (_isDropoffFocused == focused) return;

    setState(() { _isDropoffFocused = focused; });

    if (focused) {
      _activeField = _RouteField.dropoff;
      _scheduleSearch(_dropoffController.text);
    }
  }

  TextEditingController get _activeController {
    return switch (_activeField) {
      _RouteField.pickup => _pickupController,
      _RouteField.waypoint => _waypointController,
      _RouteField.dropoff => _dropoffController,
    };
  }

  String _fieldLabel(_RouteField field) {
    return switch (field) {
      _RouteField.pickup => 'Pickup location',
      _RouteField.waypoint => 'Waypoint',
      _RouteField.dropoff => 'Dropoff location',
    };
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length < 2) {
      setState(() {
        _remoteSuggestions = const [];
        _isSearching = false;
      });
      return;
    }

    if (trimmed.toLowerCase() == _lastSearchQuery.toLowerCase() &&
        _remoteSuggestions.isNotEmpty) {
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchSuggestions(value);
    });
  }

  void _setFieldText(_RouteField field, String value) {
    final controller = switch (field) {
      _RouteField.pickup => _pickupController,
      _RouteField.waypoint => _waypointController,
      _RouteField.dropoff => _dropoffController,
    };

    controller.text = value;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );

    if (_activeField == field) {
      _scheduleSearch(value);
    }
  }

  Future<void> _loadRecentPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_recentPlacesKey);
    if (raw == null || raw.trim().isEmpty) return;

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .whereType<Map<String, dynamic>>()
          .map(_LocationSuggestion.fromJson)
          .toList(growable: false);
      if (mounted) {
        setState(() { _recentSuggestions = items; });
      }
    } catch (_) {}
  }

  Future<void> _saveRecentPlace(_LocationSuggestion suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    final List<_LocationSuggestion> updated = [
      suggestion,
      ..._recentSuggestions.where((item) => item.key != suggestion.key),
    ];

    final trimmed = updated.take(6).toList(growable: false);
    setState(() { _recentSuggestions = trimmed; });

    final encoded = jsonEncode(trimmed.map((item) => item.toJson()).toList());
    await prefs.setString(_recentPlacesKey, encoded);
  }

  Future<void> _prefillCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    final bool granted =
        permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    if (!granted) return;

    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      final position = lastKnown ?? await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      _currentPosition = position;
      final location = await getIt<GetGeocodedLocationUseCase>().reverse(
        lat: position.latitude,
        lng: position.longitude,
      );
      _currentLocationLabel = location.displayName;

      if (_pickupController.text.trim() == _defaultPickupText && mounted) {
        setState(() {
          _pickupController.text = _currentLocationLabel ?? 'Current location';
        });
      }
    } catch (_) {}
  }

  void _swapLocations() {
    setState(() {
      final String temp = _pickupController.text;
      _pickupController.text = _dropoffController.text;
      _dropoffController.text = temp;
    });

    if (_activeField == _RouteField.pickup || _activeField == _RouteField.dropoff) {
      _scheduleSearch(_activeController.text);
    }
  }

  Future<void> _useCurrentLocationForPickup() async {
    if (_isResolvingPickup) return;

    setState(() { _isResolvingPickup = true; });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) AppMessage.info(context, 'Please enable location services.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final bool granted =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!granted) {
        if (mounted) {
          AppMessage.info(context, 'Location permission is denied.');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String pickupLabel = 'Current location';
      try {
        final location = await getIt<GetGeocodedLocationUseCase>().reverse(
          lat: position.latitude,
          lng: position.longitude,
        );
        if (location.displayName.trim().isNotEmpty) {
          pickupLabel = location.displayName;
        }
      } catch (_) {}

      _currentPosition = position;
      _currentLocationLabel = pickupLabel;

      if (mounted) {
        setState(() { _pickupController.text = pickupLabel; });
      }

      if (_activeField == _RouteField.pickup) {
        _scheduleSearch(pickupLabel);
      }
    } catch (_) {
      if (mounted) {
        AppMessage.error(context, 'Unable to access current location.');
      }
    } finally {
      if (mounted) {
        setState(() { _isResolvingPickup = false; });
      }
    }
  }

  Future<BookingStop?> _resolvePickupStop() async {
    if (_isResolvingPickup) return null;
    setState(() { _isResolvingPickup = true; });

    final String pickupText = _pickupController.text.trim();

    try {
      if (_currentPosition != null &&
          pickupText.isNotEmpty &&
          pickupText == (_currentLocationLabel ?? pickupText)) {
        return BookingStop(
          address: pickupText,
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
          stopType: BookingStopType.pickup,
        );
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        final bool granted =
            permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;

        if (granted && pickupText.isEmpty) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          _currentPosition = position;

          return BookingStop(
            address: _currentLocationLabel ?? 'Current location',
            lat: position.latitude,
            lng: position.longitude,
            stopType: BookingStopType.pickup,
          );
        }
      }

      if (pickupText.isEmpty) {
        if (mounted) AppMessage.info(context, 'Please enter a pickup address.');
        return null;
      }

      final location = await getIt<GetGeocodedLocationUseCase>().call(pickupText);
      return BookingStop(
        address: location.displayName.isNotEmpty ? location.displayName : pickupText,
        lat: location.lat,
        lng: location.lng,
        stopType: BookingStopType.pickup,
      );
    } catch (_) {
      if (mounted) AppMessage.error(context, 'Unable to resolve pickup location.');
      return null;
    }
  }

  Future<BookingStop?> _resolveTextStop({
    required TextEditingController controller,
    required BookingStopType stopType,
    required String emptyMessage,
  }) async {
    final String text = controller.text.trim();
    if (text.isEmpty) {
      if (stopType == BookingStopType.waypoint) return null;
      if (mounted) AppMessage.info(context, emptyMessage);
      return null;
    }

    try {
      final location = await getIt<GetGeocodedLocationUseCase>().call(text);
      return BookingStop(
        address: location.displayName.isNotEmpty ? location.displayName : text,
        lat: location.lat,
        lng: location.lng,
        stopType: stopType,
      );
    } catch (_) {
      if (mounted) {
        AppMessage.error(context, 'Unable to resolve ${stopType.apiValue} location.');
      }
      return null;
    }
  }

  Future<BookingStop?> _resolveWaypointStop() {
    return _resolveTextStop(
      controller: _waypointController,
      stopType: BookingStopType.waypoint,
      emptyMessage: 'Please enter a waypoint address.',
    );
  }

  Future<BookingStop?> _resolveDropoffStop() {
    return _resolveTextStop(
      controller: _dropoffController,
      stopType: BookingStopType.dropoff,
      emptyMessage: 'Please enter a dropoff address.',
    );
  }

  Future<void> _handleContinue() async {
    if (_isResolvingRoute) return;

    setState(() { _isResolvingRoute = true; });

    try {
      final pickupStop = await _resolvePickupStop();
      if (pickupStop == null || !mounted) return;

      final waypointStop = await _resolveWaypointStop();
      if (!mounted) return;

      final dropoffStop = await _resolveDropoffStop();
      if (dropoffStop == null || !mounted) return;

      context.pushNamed(
        'rideCategory',
        extra: RideCategoryArgs(
          serviceId: _serviceId,
          pickup: pickupStop,
          waypoint: waypointStop,
          dropoff: dropoffStop,
        ),
      );
    } finally {
      if (mounted) {
        setState(() { _isResolvingRoute = false; });
      }
    }
  }

  Future<void> _searchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || trimmed.length < 2) return;

    _lastSearchQuery = trimmed;
    final int requestId = ++_searchSequence;

    setState(() { _isSearching = true; });

    try {
      final results = await getIt<GetGeocodedLocationUseCase>().search(
        query: trimmed,
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
      );

      if (requestId != _searchSequence) return;

      final items = results.map(_LocationSuggestion.fromGeocoded).toList();
      if (mounted) {
        setState(() {
          _remoteSuggestions = items;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (requestId != _searchSequence) return;
      if (mounted) {
        setState(() {
          _remoteSuggestions = const [];
          _isSearching = false;
        });
      }
    }
  }

  void _showWaypointField() {
    if (_showWaypoint) return;
    setState(() {
      _showWaypoint = true;
      _activeField = _RouteField.waypoint;
    });
    _waypointFocusNode.requestFocus();
  }

  void _hideWaypointField() {
    if (!_showWaypoint) return;
    setState(() {
      _showWaypoint = false;
      _waypointController.clear();
      if (_activeField == _RouteField.waypoint) {
        _activeField = _RouteField.dropoff;
      }
    });
    _scheduleSearch(_activeController.text);
  }

  bool _matchesQuery(_LocationSuggestion suggestion, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return suggestion.title.toLowerCase().contains(normalized) ||
        suggestion.subtitle.toLowerCase().contains(normalized);
  }

  _LocationSuggestion? _currentLocationSuggestion() {
    final position = _currentPosition;
    if (position == null) return null;

    return _LocationSuggestion(
      title: 'Current location',
      subtitle: _currentLocationLabel ?? 'Use your GPS location',
      distance: 'Now',
      icon: Icons.my_location_rounded,
      lat: position.latitude,
      lng: position.longitude,
      isPrimary: true,
      isCurrentLocation: true,
    );
  }

  Future<void> _handleSuggestionTap(_LocationSuggestion suggestion) async {
    if (_isResolvingPickup || _isResolvingRoute) return;

    if (suggestion.isCurrentLocation && _activeField == _RouteField.pickup) {
      await _useCurrentLocationForPickup();
      return;
    }

    final String locationLabel = suggestion.subtitle.isNotEmpty
        ? suggestion.subtitle
        : suggestion.title;

    _setFieldText(_activeField, locationLabel);

    if (!suggestion.isCurrentLocation) {
      await _saveRecentPlace(suggestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String query = _activeController.text.trim();
    
    final List<_LocationSuggestion> suggestions = query.isEmpty
        ? _recentSuggestions
        : _remoteSuggestions;
        
    final currentSuggestion = _activeField == _RouteField.pickup
      ? _currentLocationSuggestion()
      : null;
      
    final List<_LocationSuggestion> displaySuggestions = query.isEmpty
        ? [if (currentSuggestion != null) currentSuggestion, ...suggestions]
        : [
            if (currentSuggestion != null) currentSuggestion,
            ..._recentSuggestions.where((item) => _matchesQuery(item, query)),
            ...suggestions,
          ].fold<List<_LocationSuggestion>>([], (items, suggestion) {
            if (items.any((existing) => existing.key == suggestion.key)) return items;
            return [...items, suggestion];
          });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Plan Route',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        bottom: (_isResolvingPickup || _isResolvingRoute)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Structural modern card input container
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: _RouteInputCard(
                pickupController: _pickupController,
                waypointController: _waypointController,
                dropoffController: _dropoffController,
                pickupFocusNode: _pickupFocusNode,
                waypointFocusNode: _waypointFocusNode,
                dropoffFocusNode: _dropoffFocusNode,
                showWaypoint: _showWaypoint,
                onSwap: _swapLocations,
                onUseCurrentLocation: _useCurrentLocationForPickup,
                onAddWaypoint: _showWaypointField,
                onRemoveWaypoint: _hideWaypointField,
                onPickupChanged: _scheduleSearch,
                onWaypointChanged: (value) {
                  if (_activeField == _RouteField.waypoint && _showWaypoint) {
                    _scheduleSearch(value);
                  }
                },
                onDropoffChanged: (value) {
                  if (_activeField == _RouteField.dropoff) {
                    _scheduleSearch(value);
                  }
                },
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            
            // Suggestion list
            Expanded(
              child: Container(
                color: const Color(0xFFF9FAFB), // Soft modern background shift for lists
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        query.isEmpty
                            ? 'Recent Places'
                            : _isSearching
                                ? 'Searching ${_fieldLabel(_activeField).toLowerCase()}...'
                                : 'Search Results',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    if (displaySuggestions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Text(
                            query.isEmpty
                                ? 'Search to see places nearby.'
                                : 'No locations found for "$query"',
                            style: textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displaySuggestions.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1, 
                            indent: 52, 
                            color: Color(0xFFF3F4F6),
                          ),
                          itemBuilder: (context, index) {
                            final suggestion = displaySuggestions[index];
                            return _SuggestionTile(
                              suggestion: suggestion,
                              onTap: () => _handleSuggestionTap(suggestion),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: _isResolvingRoute
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            : PrimaryButton(label: "Confirm Route", onPressed: _isResolvingRoute ? null : _handleContinue),
      ),
    );
  }
}

class _RouteInputCard extends StatelessWidget {
  const _RouteInputCard({
    required this.pickupController,
    required this.waypointController,
    required this.dropoffController,
    required this.pickupFocusNode,
    required this.waypointFocusNode,
    required this.dropoffFocusNode,
    required this.showWaypoint,
    this.onSwap,
    this.onUseCurrentLocation,
    this.onAddWaypoint,
    this.onRemoveWaypoint,
    this.onPickupChanged,
    this.onWaypointChanged,
    this.onDropoffChanged,
  });

  final TextEditingController pickupController;
  final TextEditingController waypointController;
  final TextEditingController dropoffController;
  final FocusNode pickupFocusNode;
  final FocusNode waypointFocusNode;
  final FocusNode dropoffFocusNode;
  final bool showWaypoint;
  final VoidCallback? onSwap;
  final VoidCallback? onUseCurrentLocation;
  final VoidCallback? onAddWaypoint;
  final VoidCallback? onRemoveWaypoint;
  final ValueChanged<String>? onPickupChanged;
  final ValueChanged<String>? onWaypointChanged;
  final ValueChanged<String>? onDropoffChanged;

  Widget _minimalField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required Widget? suffixIcon,
    required ValueChanged<String>? onChanged,
  }) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
        suffixIcon: suffixIcon,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Premium Timeline Graphics Panel
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 1.5,
              height: showWaypoint ? 42 : 32,
              color: const Color(0xFFD1D5DB),
            ),
            if (showWaypoint) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6B7280), width: 1.5),
                ),
              ),
              Container(
                width: 1.5,
                height: 42,
                color: const Color(0xFFD1D5DB),
              ),
            ],
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        
        // Input Fields Stack Panel
        Expanded(
          child: Column(
            children: [
              _minimalField(
                context: context,
                controller: pickupController,
                focusNode: pickupFocusNode,
                hintText: 'Where from?',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF4B5563)),
                  onPressed: onUseCurrentLocation,
                ),
                onChanged: onPickupChanged,
              ),
              const Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
              
              if (showWaypoint) ...[
                _minimalField(
                  context: context,
                  controller: waypointController,
                  focusNode: waypointFocusNode,
                  hintText: 'Add stop...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                    onPressed: onRemoveWaypoint,
                  ),
                  onChanged: onWaypointChanged,
                ),
                const Divider(height: 1, thickness: 0.8, color: Color(0xFFE5E7EB)),
              ],
              
              _minimalField(
                context: context,
                controller: dropoffController,
                focusNode: dropoffFocusNode,
                hintText: 'Where to?',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!showWaypoint)
                      IconButton(
                        icon: const Icon(Icons.add_rounded, size: 20, color: Colors.black87),
                        onPressed: onAddWaypoint,
                      ),
                    if (dropoffController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                        onPressed: () {
                          dropoffController.clear();
                          onDropoffChanged?.call('');
                        },
                      ),
                  ],
                ),
                onChanged: onDropoffChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        
        // Independent Swap Button
        IconButton(
          icon: const Icon(Icons.swap_vert_rounded, color: Colors.black87, size: 22),
          onPressed: onSwap,
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: suggestion.isCurrentLocation 
                    ? const Color(0xFFEEF2F6) 
                    : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                suggestion.icon,
                size: 18,
                color: suggestion.isCurrentLocation 
                    ? AppTheme.primaryColor 
                    : const Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              suggestion.distance,
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF9CA3AF),
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
    required this.lat,
    required this.lng,
    this.isPrimary = false,
    this.isCurrentLocation = false,
  });

  factory _LocationSuggestion.fromGeocoded(GeocodedLocation location) {
    final String display = location.displayName;
    final String title = display.split(',').first.trim();
    return _LocationSuggestion(
      title: title.isEmpty ? 'Selected location' : title,
      subtitle: display,
      distance: 'Nearby',
      icon: Icons.location_on_rounded,
      lat: location.lat,
      lng: location.lng,
    );
  }

  factory _LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return _LocationSuggestion(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      icon: Icons.history_rounded,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'distance': distance,
      'lat': lat,
      'lng': lng,
    };
  }

  final String title;
  final String subtitle;
  final String distance;
  final IconData icon;
  final double lat;
  final double lng;
  final bool isPrimary;
  final bool isCurrentLocation;

  String get key => '$title|$subtitle|$lat|$lng';
}