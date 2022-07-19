import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({Key? key}) : super(key: key);

  @override
  _MapHomePageState createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  var _androidAppRetain = MethodChannel("android_app_retain");
  CameraPosition _cameraPosition =
      const CameraPosition(target: LatLng(-23.563999, -46.653256));
  final Map<String, Marker> _markers = {};
  final Completer<GoogleMapController> _controller = Completer();
  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);

    setState(() {
      _markers.clear();
    });
  }

  Location location = Location();

  void _requestPermission() async {
    final _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      final _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<LocationData> _getLocationData() async {
    LocationData _locationData = await location.getLocation();
    setState(() {
      if (_locationData != null) {
        _cameraPosition = CameraPosition(
          target: LatLng(_locationData.latitude ?? 123456,
              _locationData.longitude ?? 123456),
          zoom: 19,
        );

        print(
            'device lat: ${_locationData.latitude}, long: ${_locationData.longitude}');

        _moveCamera(_cameraPosition);
      }
    });
    return _locationData;
  }

  _onChangeLocation() {
    location.onLocationChanged.listen((LocationData currentLocation) {
      print(
          'posicao: ${currentLocation.latitude} , ${currentLocation.longitude}');
      _cameraPosition = CameraPosition(
        target: LatLng(currentLocation.latitude ?? 48.8584,
            currentLocation.longitude ?? 2.2945),
        zoom: 19,
      );

      _moveCamera(_cameraPosition);
    });
  }

  void _fakeMove() async {
    LocationData location = await _getLocationData();
    int i = 0;
    do {
      double newLat = location.latitude! + 0.00003;
      double newLong = location.longitude! + 0.00003;
      LocationData newPos = LocationData.fromMap(
          {'latitude': newLat, 'longitude': newLong, 'accuracy': 1.0});
      location = newPos;
      i += 1;
    } while (i < 10);
  }

  _moveCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.enableBackgroundMode(enable: true);
    //_fakeMove();
    _onChangeLocation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return Future.value(true);
          } else {
            _androidAppRetain.invokeMethod("sendToBackground");
            return Future.value(false);
          }
        } else {
          return Future.value(true);
        }
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('POC To Aqui'),
            backgroundColor: Colors.indigo,
          ),
          bottomNavigationBar: const TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(
                icon: Icon(Icons.share_location_outlined),
                text: 'MAPA',
              ),
              Tab(
                icon: Icon(Icons.people_outline_outlined),
                text: 'PESSOAS',
              ),
              Tab(
                icon: Icon(Icons.lock),
                text: 'TRAVA',
              ),
              Tab(
                icon: Icon(Icons.manage_accounts_outlined),
                text: 'CONTA',
              ),
            ],
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _cameraPosition,
                //markers: _markers.values.toSet(),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                mapType: MapType.normal,
              ),
              Container(
                color: Colors.amber,
              ),
              Container(
                color: Colors.amber,
              ),
              Container(
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
