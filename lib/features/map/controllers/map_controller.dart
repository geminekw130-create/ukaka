import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:collection';

import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:motoboy/features/location/controllers/location_controller.dart';
import 'package:motoboy/features/profile/controllers/profile_controller.dart';
import 'package:motoboy/features/ride/controllers/ride_controller.dart';
import 'package:motoboy/features/splash/controllers/splash_controller.dart';
import 'package:motoboy/util/images.dart';

enum RideState {
  initial,
  pending,
  accepted,
  outForPickup,
  ongoing,
  acceptingRider,
  completed,
  fareCalculating
}

class RiderMapController extends GetxController implements GetxService {

  bool _showCancelTripButton = false;
  bool get showCancelTripButton => _showCancelTripButton;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isRefresh = false;
  bool _checkIsRideAccept = false;
  bool get checkIsRideAccept => _checkIsRideAccept;

  bool isTrafficEnable = false;

  Set<Marker> markers = HashSet<Marker>();
  final List<MarkerData> _customMarkers = [];
  List<MarkerData> get customMarkers => _customMarkers;

  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinateList = [];

  GoogleMapController? mapController;

  bool profileOnline = true;
  bool clickedAssistant = false;

  double panelHeightOpen = 0;
  double sheetHeight = 0;

  RideState currentRideState = RideState.initial;

  LatLng _initialPosition = const LatLng(23.83721, 90.363715);
  LatLng _destinationPosition = const LatLng(23.83721, 90.363715);

  LatLng get initialPosition => _initialPosition;
  LatLng get destinationPosition => _destinationPosition;

  @override
  void onInit() {
    initializeData();
    super.onInit();
  }

  void initializeData() {
    if (Get.isRegistered<RideController>()) {
      Get.find<RideController>().polyline = '';
    }
    markers.clear();
    polylines.clear();
    _isLoading = false;
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void setRideCurrentState(RideState newState, {bool notify = true}) {
    currentRideState = newState;
    if (newState == RideState.initial) initializeData();
    if (notify) update();
  }

  void toggleTrafficView() {
    isTrafficEnable = !isTrafficEnable;
    update();
  }

  void _addPolyLine(List<LatLng> coordinates) {
    polylines.clear();
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: coordinates,
        width: 5,
        color: Theme.of(Get.context!).primaryColor,
      ),
    );
    update();
  }

  Future<Uint8List> convertAssetToUnit8List(String path, {int width = 50}) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final frame = await codec.getNextFrame();
    return (await frame.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> setMapPosition() async {
    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPosition,
          zoom: 16, // 🔥 fix: sem AppConstants
        ),
      ),
    );
  }

  bool _isInside = false;
  bool get isInside => _isInside;

  void isInsideCircle(
    double lat,
    double lng,
    double latCenter,
    double lngCenter,
    double radius,
  ) {
    final distance = Geolocator.distanceBetween(
      lat,
      lng,
      latCenter,
      lngCenter,
    );
    _isInside = distance <= radius;
    update();
  }
}
