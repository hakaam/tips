import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShareMyCurrentLocation extends StatefulWidget {
  const ShareMyCurrentLocation({Key? key}) : super(key: key);

  @override
  State<ShareMyCurrentLocation> createState() => MapSampleState();
}

class MapSampleState extends State<ShareMyCurrentLocation> {
  final TextEditingController _textController = TextEditingController();
  String currentLocation = '';
  String manuallyEnteredLocation = '';
  Set<Marker> _markers = {}; // Initialize the markers set

  // Define your initial camera position
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.488047, 74.297542),
    zoom: 14.4746,
  );

  // Define your GoogleMapController completer
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Add a marker to the _markers set
      _markers.add(
        Marker(
          markerId: MarkerId('current_location_marker'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
          ),
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];

        // Construct the complete address from placemark components
        String address = placemark.name ?? '';
        if (placemark.thoroughfare != null) {
          address += ', ${placemark.thoroughfare}';
        }
        if (placemark.subThoroughfare != null) {
          address += ', ${placemark.subThoroughfare}';
        }
        if (placemark.locality != null) {
          address += ', ${placemark.locality}';
        }
        if (placemark.subLocality != null) {
          address += ', ${placemark.subLocality}';
        }
        if (placemark.administrativeArea != null) {
          address += ', ${placemark.administrativeArea}';
        }
        if (placemark.postalCode != null) {
          address += ', ${placemark.postalCode}';
        }
        if (placemark.country != null) {
          address += ', ${placemark.country}';
        }

        setState(() {
          currentLocation = address;
          _textController.text = currentLocation;
        });

        // Update the map to show the new location
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ));
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers, // Set the markers on the map
            ),
            Container(
              height: 65,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 13),
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            filled: true,
                            contentPadding: EdgeInsets.all(10.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  manuallyEnteredLocation = ''; // Clear manually entered location
                                  _textController.clear();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Enable the text field for manual entry
                        setState(() {
                          manuallyEnteredLocation = ''; // Clear manually entered location
                        });
                        _textController.clear(); // Clear the current location
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 700,
              left: 20,
              right: 20,
              child: CustomButton(
                text: 'Confirm',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        location: manuallyEnteredLocation.isNotEmpty
                            ? manuallyEnteredLocation
                            : currentLocation, products:products,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
