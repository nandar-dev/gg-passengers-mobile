import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_message.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../domain/entities/saved_place.dart';
import '../../domain/use_cases/create_saved_place_use_case.dart';
import '../../domain/use_cases/delete_saved_place_use_case.dart';
import '../../domain/use_cases/get_saved_places_use_case.dart';
import '../../domain/use_cases/set_default_saved_place_use_case.dart';
import '../../domain/use_cases/update_saved_place_use_case.dart';
import '../../../booking/domain/entities/geocoded_location.dart';
import '../../../booking/domain/use_cases/get_geocoded_location_use_case.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final List<_SuggestionPlace> _fallbackPlaces = const [
    _SuggestionPlace('Airport', 'Nearest airport terminal'),
    _SuggestionPlace('Shopping Mall', 'Popular shopping destination'),
    _SuggestionPlace('Railway Station', 'Main city station'),
  ];

  List<SavedPlace> _places = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPlaces({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);

    try {
      final items = await getIt<GetSavedPlacesUseCase>().call(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _places = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppMessage.error(context, 'Unable to load saved places.');
    }
  }

  Future<void> _savePlace({SavedPlace? existing}) async {
    if (_isSaving) return;

    _searchDebounce?.cancel();
    final controllerLabel = TextEditingController(text: existing?.label ?? '');
    final controllerAddress = TextEditingController(text: existing?.addressName ?? '');
    final controllerLat = TextEditingController(
      text: existing == null ? '' : existing.latitude.toStringAsFixed(6),
    );
    final controllerLng = TextEditingController(
      text: existing == null ? '' : existing.longitude.toStringAsFixed(6),
    );
    final controllerSearch = TextEditingController();
    List<GeocodedLocation> suggestions = const [];
    bool isSearching = false;
    bool isDefault = existing?.isDefault ?? false;

    final result = await showModalBottomSheet<_SavedPlaceFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, viewInsets.bottom + 20),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> handleSearch(String value) async {
                _searchDebounce?.cancel();
                final trimmed = value.trim();
                if (trimmed.length < 2) {
                  setModalState(() {
                    suggestions = const [];
                    isSearching = false;
                  });
                  return;
                }

                _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
                  setModalState(() => isSearching = true);
                  try {
                    final results = await getIt<GetGeocodedLocationUseCase>().search(
                      query: trimmed,
                    );
                    if (!mounted) return;
                    setModalState(() {
                      suggestions = results;
                      isSearching = false;
                    });
                  } catch (_) {
                    if (!mounted) return;
                    setModalState(() {
                      suggestions = const [];
                      isSearching = false;
                    });
                  }
                });
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        existing == null ? 'Add saved place' : 'Edit saved place',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: controllerSearch,
                    label: 'Search address',
                    hint: 'Search nearby places',
                    onChanged: handleSearch,
                    suffixIcon: IconButton(
                      onPressed: () async {
                        final selected = await _showMapPicker(
                          initialLat: double.tryParse(controllerLat.text.trim()),
                          initialLng: double.tryParse(controllerLng.text.trim()),
                        );
                        if (selected == null) return;
                        controllerAddress.text = selected.displayName;
                        controllerLat.text = selected.lat.toStringAsFixed(6);
                        controllerLng.text = selected.lng.toStringAsFixed(6);
                        controllerSearch.text = '';
                        setModalState(() {
                          suggestions = const [];
                        });
                      },
                      icon: const Icon(Icons.map_rounded),
                    ),
                  ),
                  if (isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    )
                  else if (suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6, bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: suggestions
                            .map(
                              (item) => ListTile(
                                dense: true,
                                title: Text(
                                  item.displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  controllerAddress.text = item.displayName;
                                  controllerLat.text = item.lat.toStringAsFixed(6);
                                  controllerLng.text = item.lng.toStringAsFixed(6);
                                  controllerSearch.text = '';
                                  setModalState(() {
                                    suggestions = const [];
                                  });
                                },
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  _InputField(
                    controller: controllerLabel,
                    label: 'Label',
                    hint: 'Home, Office, Gym',
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: controllerAddress,
                    label: 'Address',
                    hint: 'No(123), Pyay Road, Yangon',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InputField(
                          controller: controllerLat,
                          label: 'Latitude',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InputField(
                          controller: controllerLng,
                          label: 'Longitude',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Set as default'),
                    value: isDefault,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) => setModalState(() => isDefault = value),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final label = controllerLabel.text.trim();
                        final address = controllerAddress.text.trim();
                        final lat = double.tryParse(controllerLat.text.trim());
                        final lng = double.tryParse(controllerLng.text.trim());

                        if (label.isEmpty || address.isEmpty || lat == null || lng == null) {
                          AppMessage.info(context, 'Fill out all fields with valid coordinates.');
                          return;
                        }

                        Navigator.pop(
                          context,
                          _SavedPlaceFormResult(
                            label: label,
                            addressName: address,
                            latitude: lat,
                            longitude: lng,
                            isDefault: isDefault,
                          ),
                        );
                      },
                      child: Text(existing == null ? 'Save place' : 'Update place'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    _searchDebounce?.cancel();
    if (result == null || !mounted) return;

    setState(() => _isSaving = true);

    try {
      SavedPlace saved;
      if (existing == null) {
        saved = await getIt<CreateSavedPlaceUseCase>().call(
          label: result.label,
          addressName: result.addressName,
          latitude: result.latitude,
          longitude: result.longitude,
          isDefault: result.isDefault,
        );
        _upsertPlace(saved);
      } else {
        saved = await getIt<UpdateSavedPlaceUseCase>().call(
          id: existing.id,
          label: result.label,
          addressName: result.addressName,
          latitude: result.latitude,
          longitude: result.longitude,
          isDefault: result.isDefault,
        );
        _upsertPlace(saved);
      }

      if (result.isDefault) {
        await getIt<SetDefaultSavedPlaceUseCase>().call(saved.id);
      }
    } catch (_) {
      if (mounted) {
        AppMessage.error(context, 'Unable to save place.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<GeocodedLocation?> _showMapPicker({
    double? initialLat,
    double? initialLng,
  }) async {
    final LatLng defaultCenter = await _resolveInitialCenter(
      initialLat: initialLat,
      initialLng: initialLng,
    );

    return showModalBottomSheet<GeocodedLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        LatLng selected = defaultCenter;
        String addressLabel = '';
        bool isResolving = false;

        Future<void> reverseGeocode(LatLng point, StateSetter setModalState) async {
          setModalState(() {
            isResolving = true;
          });
          try {
            final location = await getIt<GetGeocodedLocationUseCase>().reverse(
              lat: point.latitude,
              lng: point.longitude,
            );
            setModalState(() {
              addressLabel = location.displayName;
              isResolving = false;
            });
          } catch (_) {
            setModalState(() {
              addressLabel = 'Selected location';
              isResolving = false;
            });
          }
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pick a location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      addressLabel.isEmpty
                          ? 'Tap on the map to set a pin.'
                          : addressLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF5F6368)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isResolving)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: defaultCenter,
                          initialZoom: 15,
                          onTap: (tapPosition, point) {
                            setModalState(() {
                              selected = point;
                            });
                            reverseGeocode(point, setModalState);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.gg.taxi',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: selected,
                                width: 36,
                                height: 36,
                                child: const Icon(
                                  Icons.location_on,
                                  color: AppTheme.primaryColor,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          final displayName = addressLabel.isNotEmpty
                              ? addressLabel
                              : 'Selected location';
                          Navigator.pop(
                            context,
                            GeocodedLocation(
                              lat: selected.latitude,
                              lng: selected.longitude,
                              displayName: displayName,
                            ),
                          );
                        },
                        child: const Text('Use this location'),
                      ),
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

  Future<LatLng> _resolveInitialCenter({
    double? initialLat,
    double? initialLng,
  }) async {
    if (initialLat != null && initialLng != null) {
      return LatLng(initialLat, initialLng);
    }

    try {
      final permission = await Geolocator.checkPermission();
      final bool granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted) {
        return const LatLng(16.80528, 96.13611);
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      final position = lastKnown ?? await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return const LatLng(16.80528, 96.13611);
    }
  }

  void _upsertPlace(SavedPlace place) {
    final updated = [place, ..._places.where((item) => item.id != place.id)];
    setState(() {
      _places = place.isDefault
          ? updated
              .map((item) => item.copyWith(isDefault: item.id == place.id))
              .toList(growable: false)
          : updated;
    });
  }

  Future<void> _deletePlace(SavedPlace place) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete saved place'),
          content: Text('Remove ${place.label}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await getIt<DeleteSavedPlaceUseCase>().call(place.id);
      if (!mounted) return;
      setState(() {
        _places = _places.where((item) => item.id != place.id).toList(growable: false);
      });
    } catch (_) {
      if (mounted) {
        AppMessage.error(context, 'Unable to delete place.');
      }
    }
  }

  Future<void> _setDefault(SavedPlace place) async {
    if (place.isDefault) return;

    try {
      await getIt<SetDefaultSavedPlaceUseCase>().call(place.id);
      if (!mounted) return;
      setState(() {
        _places = _places
            .map((item) => item.copyWith(isDefault: item.id == place.id))
            .toList(growable: false);
      });
    } catch (_) {
      if (mounted) {
        AppMessage.error(context, 'Unable to set default place.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldPageBackground,
      appBar: AppBar(
        title: const Text('Saved Places'),
        backgroundColor: AppTheme.scaffoldPageBackground,
        foregroundColor: const Color(0xFF202124),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPlaces(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                const Text(
                  'Your places',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isSaving ? null : () => _savePlace(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const SkeletonList(
                itemCount: 4,
                padding: EdgeInsets.symmetric(vertical: 4),
              )
            else if (_places.isEmpty)
              _EmptyState(
                suggestions: _fallbackPlaces,
                onAddPlace: _savePlace,
              )
            else
              ..._places.map(
                (place) => _SavedPlaceCard(
                  place: place,
                  onEdit: () => _savePlace(existing: place),
                  onDelete: () => _deletePlace(place),
                  onMakeDefault: () => _setDefault(place),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SavedPlaceCard extends StatelessWidget {
  final SavedPlace place;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;

  const _SavedPlaceCard({
    required this.place,
    required this.onEdit,
    required this.onDelete,
    required this.onMakeDefault,
  });

  @override
  Widget build(BuildContext context) {
    final Color chipColor = place.isDefault ? const Color(0xFFFFF1DF) : const Color(0xFFF6F7F9);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  place.label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  place.isDefault ? 'Default' : 'Saved',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(place.addressName, style: const TextStyle(color: Color(0xFF5F6368))),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: onEdit,
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: onDelete,
                child: const Text('Delete', style: TextStyle(color: Color(0xFFC62828))),
              ),
              const Spacer(),
              TextButton(
                onPressed: onMakeDefault,
                child: const Text('Set default'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final List<_SuggestionPlace> suggestions;
  final VoidCallback onAddPlace;

  const _EmptyState({
    required this.suggestions,
    required this.onAddPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No saved places yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a place to get faster pickups. You can start with popular spots.',
            style: TextStyle(color: Color(0xFF5F6368)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(item.label),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: onAddPlace,
              child: const Text('Add saved place'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF6F7F9),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SavedPlaceFormResult {
  final String label;
  final String addressName;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const _SavedPlaceFormResult({
    required this.label,
    required this.addressName,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });
}

class _SuggestionPlace {
  final String label;
  final String subtitle;

  const _SuggestionPlace(this.label, this.subtitle);
}

extension _SavedPlaceCopy on SavedPlace {
  SavedPlace copyWith({
    String? id,
    String? label,
    String? addressName,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? createdAt,
  }) {
    return SavedPlace(
      id: id ?? this.id,
      label: label ?? this.label,
      addressName: addressName ?? this.addressName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
