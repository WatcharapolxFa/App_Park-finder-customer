import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:parkfinder_customer/screens/myaddress/my_address_add.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../assets/colors/constant.dart';

class MyAddressMapPage extends StatefulWidget {
  const MyAddressMapPage({super.key, this.addressR, this.latlongR});
  final String? addressR;
  final LatLng? latlongR;
  @override
  MyAddressMapPageState createState() => MyAddressMapPageState();
}

class MyAddressMapPageState extends State<MyAddressMapPage> {
  String? markerAddress;
  LatLng? latlong;
  Position? _currentPosition;
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  TextEditingController textController = TextEditingController();
  final _controller = FloatingSearchBarController();
  String location = 'ค้นหาที่จอดรถ';
  List<dynamic> placesList = [];
  late Map placeLocation;
  bool _showLocationSelect = false;

  @override
  void initState() {
    super.initState();
    if (widget.latlongR == null) {
      getCurrentPosition();
    }
    textController.addListener(() {
      setState(() {
        location = textController.text;
      });
      getSuggestion(textController.text);
    });
    if (widget.addressR != null && widget.latlongR != null) {
      _controller.query = widget.addressR ?? '';
      addMakerPress(widget.latlongR ?? const LatLng(13.736717, 100.523186));
      setState(() {
        markerAddress = widget.addressR;
      });
      _showLocationSelect = true;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) return;
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        setState(() => _currentPosition = position);
      }).catchError((e) {
        debugPrint(e);
      });

      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 18)));
    } catch (e) {
      //Failed to get data from Geocoding
    }
  }

  void addMakerPress(LatLng latlang) {
    setState(() {
      markers.add(
          Marker(markerId: MarkerId(latlang.toString()), position: latlang));
    });
  }

  void getSuggestion(String input) async {
    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&language=th&location=13.736717,100.523186&radius=50000&key=${dotenv.env['placeAPIkey']}';

      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        setState(() {
          placesList = jsonDecode(response.body.toString())['predictions'];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      //Failed to load data from Google Place API
    }
  }

  void searchLocation(String placeId) async {
    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/details/json';
      String request =
          '$baseURL?fields=geometry&place_id=$placeId&key=${dotenv.env['placeAPIkey']}';
      var response = await http.get(Uri.parse(request));

      if (response.statusCode == 200) {
        setState(() {
          placeLocation = jsonDecode(response.body.toString())['result']
              ['geometry']['location'];
        });
      } else {
        throw Exception('Failed to load data');
      }

      final Position searchPosition = Position(
          longitude: placeLocation['lng'],
          latitude: placeLocation['lat'],
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);

      changeCameraGoogleMap(searchPosition);
    } catch (e) {
      //Failed to load data from Google Place API
    }
  }

  void changeCameraGoogleMap(Position latlang) {
    if (markers.isNotEmpty) {
      markers.clear();
    }
    addMakerPress(LatLng(latlang.latitude, latlang.longitude));
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(latlang.latitude, latlang.longitude), zoom: 18)));
  }

  Future<void> _getAddressFromLatLng(LatLng latlang) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        latlang.latitude, latlang.longitude,
        localeIdentifier: 'th_TH');

    setState(() {
      markerAddress = '${placemarks[0].street}';
    });
  }

  Widget locationSelect() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              blurRadius: 5,
              color: Colors.grey.withOpacity(0.5),
              offset: const Offset(0, 3))
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'ที่อยู่ที่เลือก',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 30),
            child: Text(
              markerAddress ?? '',
              style: const TextStyle(height: 1.5, fontSize: 16),
            ),
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5,
                      color: Colors.grey.withOpacity(0.5),
                      offset: const Offset(0, 3))
                ],
                color: const Color(0xFF6828DC),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyAddressAddPage(
                              address: markerAddress,
                              latlong: latlong,
                            )),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยืนยันสถานที่ของคุณ',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                )),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('ที่อยู่ของฉัน'),
          centerTitle: true,
          backgroundColor: AppColor.appPrimaryColor,
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      widget.latlongR ?? const LatLng(13.736717, 100.523186),
                  zoom: 18,
                ),
                onMapCreated: _onMapCreated,
                zoomControlsEnabled: false,
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onTap: (latlang) async {
                  if (markers.isNotEmpty) {
                    markers.clear();
                  }
                  addMakerPress(latlang);
                  await _getAddressFromLatLng(latlang);
                  setState(() {
                    latlong = latlang;
                    _showLocationSelect = true;
                    _controller.query = '$markerAddress';
                  });
                },
              ),
              FloatingSearchBar(
                hint: 'ค้นหาที่อยู่และชื่ออาคาร',
                scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
                transitionDuration: const Duration(milliseconds: 500),
                transitionCurve: Curves.easeInOut,
                physics: const BouncingScrollPhysics(),
                openAxisAlignment: 0.0,
                width: MediaQuery.of(context).size.width - 40,
                debounceDelay: const Duration(milliseconds: 500),
                controller: _controller,
                onQueryChanged: (query) {
                  getSuggestion(query);
                },
                onFocusChanged: (isFocused) {
                  if (isFocused) {
                    setState(() {
                      _showLocationSelect = false;
                    });
                  } else {
                    if (markers.isNotEmpty) {
                      setState(() {
                        _showLocationSelect = true;
                      });
                    }
                  }
                },
                clearQueryOnClose: false,
                transition: CircularFloatingSearchBarTransition(),
                leadingActions: [
                  FloatingSearchBarAction(
                    showIfOpened: false,
                    child: CircularButton(
                      icon: const Icon(Icons.place),
                      onPressed: () {},
                    ),
                  ),
                  FloatingSearchBarAction.back(
                    showIfClosed: false,
                  )
                ],
                actions: [
                  FloatingSearchBarAction(
                    showIfOpened: true,
                    child: CircularButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (markers.isNotEmpty) {
                          markers.clear();
                          _showLocationSelect = false;
                        }
                        _controller.clear();
                      },
                    ),
                  ),
                ],
                builder: (context, transition) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Material(
                      color: Colors.white,
                      elevation: 4.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: placesList.map((location) {
                          if (location.containsKey('description')) {
                            return InkWell(
                              onTap: () async {
                                searchLocation(location['place_id']);
                                _controller.close();
                                setState(() {
                                  _controller.query = location['description'];
                                  _showLocationSelect = true;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.place,
                                      color: Color(0xFFA6AAB4),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: Text(
                                        location['description'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              Visibility(
                visible: _showLocationSelect,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: locationSelect(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Visibility(
          visible: !_showLocationSelect,
          child: FloatingActionButton(
            backgroundColor: AppColor.appPrimaryColor,
            onPressed: () {
              getCurrentPosition();
            },
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ));
  }
}
