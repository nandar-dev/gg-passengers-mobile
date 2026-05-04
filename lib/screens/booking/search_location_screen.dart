import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../features/booking/domain/entities/booking_stop.dart';
import '../../features/booking/domain/entities/geocoded_location.dart';
import '../../features/booking/domain/use_cases/get_geocoded_location_use_case.dart';
import '../../features/booking/presentation/models/booking_args.dart';
import '../../shared/widgets/app_message.dart';

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

    setState(() {
      _isPickupFocused = focused;
    });

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

    setState(() {
      _isWaypointFocused = focused;
    });

    if (focused) {
      _activeField = _RouteField.waypoint;
      _scheduleSearch(_waypointController.text);
    }
  }

  void _handleDropoffFocus() {
    final bool focused = _dropoffFocusNode.hasFocus;
    if (_isDropoffFocused == focused) return;

    setState(() {
      _isDropoffFocused = focused;
    });

    if (focused) {
      _activeField = _RouteField.dropoff;
      _scheduleSearch(_dropoffController.text);
    }
  }

  TextEditingController get _activeController {
    switch (_activeField) {
      case _RouteField.pickup:
        return _pickupController;
      case _RouteField.waypoint:
        return _waypointController;
      case _RouteField.dropoff:
        return _dropoffController;
    }
  }

  String _fieldLabel(_RouteField field) {
    switch (field) {
      case _RouteField.pickup:
        return 'Pickup location';
      case _RouteField.waypoint:
        return 'Waypoint (optional)';
      case _RouteField.dropoff:
        return 'Dropoff location';
    }
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _remoteSuggestions = const [];
        _isSearching = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
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
        setState(() {
          _recentSuggestions = items;
        });
      }
    } catch (_) {
      // Ignore cache parse errors.
    }
  }

  Future<void> _saveRecentPlace(_LocationSuggestion suggestion) async {
    final prefs = await SharedPreferences.getInstance();
    final List<_LocationSuggestion> updated = [
      suggestion,
      ..._recentSuggestions.where((item) => item.key != suggestion.key),
    ];

    final trimmed = updated.take(6).toList(growable: false);
    setState(() {
      _recentSuggestions = trimmed;
    });

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
    } catch (_) {
      // Ignore prefill failures.
    }
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

    setState(() {
      _isResolvingPickup = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          AppMessage.info(context, 'Please enable location services.');
        }
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
          AppMessage.info(
            context,
            'Location permission is denied. Please enter a pickup address instead.',
          );
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
      } catch (_) {
        // Keep fallback label if reverse geocode fails.
      }

      _currentPosition = position;
      _currentLocationLabel = pickupLabel;

      if (mounted) {
        setState(() {
          _pickupController.text = pickupLabel;
        });
      }

      if (_activeField == _RouteField.pickup) {
        _scheduleSearch(pickupLabel);
      }
    } catch (_) {
      if (mounted) {
        AppMessage.error(
          context,
          'Unable to access current location. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingPickup = false;
        });
      }
    }
  }

  Future<BookingStop?> _resolvePickupStop() async {
    if (_isResolvingPickup) return null;

    setState(() {
      _isResolvingPickup = true;
    });

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

        if (permission == LocationPermission.deniedForever && mounted) {
          AppMessage.info(
            context,
            'Location permission is denied. Using typed pickup address instead.',
          );
        }
      }

      if (pickupText.isEmpty) {
        if (mounted) {
          AppMessage.info(context, 'Please enter a pickup address.');
        }
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
      if (mounted) {
        AppMessage.error(
          context,
          'Unable to resolve pickup location. Please try again.',
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingPickup = false;
        });
      }
    }
  }

  Future<BookingStop?> _resolveTextStop({
    required TextEditingController controller,
    required BookingStopType stopType,
    required String emptyMessage,
  }) async {
    final String text = controller.text.trim();
    if (text.isEmpty) {
      if (stopType == BookingStopType.waypoint) {
        return null;
      }
      if (mounted) {
        AppMessage.info(context, emptyMessage);
      }
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
        AppMessage.error(
          context,
          'Unable to resolve ${stopType.apiValue} location. Please try again.',
        );
      }
      return null;
    }
  }

  Future<BookingStop?> _resolveWaypointStop() {
    return _resolveTextStop(
      controller: _waypointController,
      stopType: BookingStopType.waypoint,
      emptyMessage: 'Please enter a waypoint address or leave it blank.',
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

    setState(() {
      _isResolvingRoute = true;
    });

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
        setState(() {
          _isResolvingRoute = false;
        });
      }
    }
  }

  Future<void> _searchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await getIt<GetGeocodedLocationUseCase>().search(
        query: trimmed,
        lat: _currentPosition?.latitude,
        lng: _currentPosition?.longitude,
      );

      final items = results.map(_LocationSuggestion.fromGeocoded).toList();
      if (mounted) {
        setState(() {
          _remoteSuggestions = items;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _remoteSuggestions = const [];
          _isSearching = false;
        });
      }
    }
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
    final List<_LocationSuggestion> displaySuggestions = [
      if (currentSuggestion != null) currentSuggestion,
      ...suggestions,
    ];

    return Scaffold(
      backgroundColor: AppTheme.scaffoldPageBackground,
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
                  if (_isResolvingPickup || _isResolvingRoute)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  _RouteInputCard(
                    pickupController: _pickupController,
                    waypointController: _waypointController,
                    dropoffController: _dropoffController,
                    pickupFocusNode: _pickupFocusNode,
                    waypointFocusNode: _waypointFocusNode,
                    dropoffFocusNode: _dropoffFocusNode,
                    onSwap: _swapLocations,
                    onUseCurrentLocation: _useCurrentLocationForPickup,
                    onPickupChanged: (value) => _scheduleSearch(value),
                    onWaypointChanged: (value) {
                      if (_activeField == _RouteField.waypoint) {
                        _scheduleSearch(value);
                      }
                    },
                    onDropoffChanged: (value) {
                      if (_activeField == _RouteField.dropoff) {
                        _scheduleSearch(value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  if (query.isEmpty) ...[
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
                        _isSearching
                            ? 'Searching ${_fieldLabel(_activeField).toLowerCase()}...'
                            : 'Search Results',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                  if (displaySuggestions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          query.isEmpty
                              ? 'Search to see places nearby.'
                              : 'No locations found for "$query"',
                          style: textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...displaySuggestions.map(
                      (suggestion) => _SuggestionTile(
                        suggestion: suggestion,
                        onTap: () => _handleSuggestionTap(suggestion),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isResolvingRoute ? null : _handleContinue,
                    child: _isResolvingRoute
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
    required this.waypointController,
    required this.dropoffController,
    required this.pickupFocusNode,
    required this.waypointFocusNode,
    required this.dropoffFocusNode,
    this.onSwap,
    this.onUseCurrentLocation,
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
  final VoidCallback? onSwap;
  final VoidCallback? onUseCurrentLocation;
  final ValueChanged<String>? onPickupChanged;
  final ValueChanged<String>? onWaypointChanged;
  final ValueChanged<String>? onDropoffChanged;

  Widget _routeField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    required Color fillColor,
    required Widget? suffixIcon,
    required ValueChanged<String>? onChanged,
  }) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return TextField(
      focusNode: focusNode,
      controller: controller,
      onChanged: onChanged,
      style: textTheme.bodyLarge?.copyWith(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppTheme.textSecondary,
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 22,
          color: AppTheme.primaryDark,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFFFE5C2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.primaryDark,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                _routeField(
                  context: context,
                  controller: pickupController,
                  focusNode: pickupFocusNode,
                  hintText: 'Pickup location',
                  prefixIcon: Icons.trip_origin_rounded,
                  fillColor: const Color(0xFFFFF4E5),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.my_location_rounded,
                      size: 22,
                      color: AppTheme.primaryDark,
                    ),
                    onPressed: onUseCurrentLocation,
                  ),
                  onChanged: onPickupChanged,
                ),
                const SizedBox(height: 10),
                _routeField(
                  context: context,
                  controller: waypointController,
                  focusNode: waypointFocusNode,
                  hintText: 'Waypoint (optional)',
                  prefixIcon: Icons.pin_drop_outlined,
                  fillColor: const Color(0xFFFFFCF8),
                  suffixIcon: waypointController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            waypointController.clear();
                            onWaypointChanged?.call('');
                          },
                        )
                      : const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                  onChanged: onWaypointChanged,
                ),
                const SizedBox(height: 10),
                _routeField(
                  context: context,
                  controller: dropoffController,
                  focusNode: dropoffFocusNode,
                  hintText: 'Dropoff location',
                  prefixIcon: Icons.flag_outlined,
                  fillColor: const Color(0xFFFFFCF8),
                  suffixIcon: dropoffController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            dropoffController.clear();
                            onDropoffChanged?.call('');
                          },
                        )
                      : const Icon(
                          Icons.place,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                  onChanged: onDropoffChanged,
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
      icon: Icons.place_outlined,
      lat: location.lat,
      lng: location.lng,
    );
  }

  factory _LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return _LocationSuggestion(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      icon: Icons.history,
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
