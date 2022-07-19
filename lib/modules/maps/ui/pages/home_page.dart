import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  _requestPermission() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    return permission;
  }

  _getLastKnownPosition() async {
    final permission = _requestPermission();

    if (permission != null) {
      Position? position = await Geolocator.getLastKnownPosition();

      setState(() {
        if (position != null) {
          _cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 19,
          );

          print(
              'device lat: ${position.latitude}, long: ${position.longitude}');

          _moveCamera(_cameraPosition);
        }
      });
    } else {
      print("Permissão negada");
    }
  }

  _moveCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _fetchPosition() {
    const localSettings = LocationSettings();

    Geolocator.getPositionStream(locationSettings: localSettings)
        .listen((Position position) {
      print('device lat: ${position.latitude}, long: ${position.longitude}');
      _cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 19,
      );

      //_moveCamera(_cameraPosition);
    });
  }

  @override
  void initState() {
    _getLastKnownPosition();
    _fetchPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('POC To Aqui'),
            backgroundColor: Colors.green[700],
          ),
          bottomNavigationBar: TabBar(
            labelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.share_location_outlined,
                  color: Colors.grey[700],
                ),
                text: 'Mapa',
              ),
              const Tab(
                icon: Icon(Icons.people_outline_outlined),
                text: 'Pessoas',
              ),
              const Tab(
                icon: Icon(Icons.lock),
                text: 'Trava',
              ),
              const Tab(
                icon: Icon(Icons.manage_accounts_outlined),
                text: 'Conta',
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
          )),
    );
  }
}
