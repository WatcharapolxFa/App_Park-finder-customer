import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parkfinder_customer/assets/colors/constant.dart';
import 'package:parkfinder_customer/models/parking_area_model.dart';
import 'package:parkfinder_customer/services/parking_area_service.dart';
import 'package:parkfinder_customer/widgets/buttons/button_purple.dart';
import 'package:parkfinder_customer/screens/reserve/booking.dart';

class SearchMapPage extends StatefulWidget {
  const SearchMapPage(
      {super.key,
      required this.keyword,
      required this.review,
      required this.price,
      required this.startDate,
      required this.endDate,
      required this.entryTime,
      required this.exitTime,
      required this.currentPosition});
  final String keyword;
  final int review;
  final int price;
  final String startDate;
  final String endDate;
  final TimeOfDay entryTime;
  final TimeOfDay exitTime;
  final Position currentPosition;

  @override
  SearchMapPageState createState() => SearchMapPageState();
}

class SearchMapPageState extends State<SearchMapPage> {
  // String? markerAddress;
  Position? _currentPosition;
  late GoogleMapController mapController;
  final List<Marker> markers = [];
  final _controller = FloatingSearchBarController();
  List<dynamic> placesList = [];
  List<dynamic> address = [];
  late Map placeLocation;
  bool _showLocationList = false;
  String selectLocation = "";
  String selectProviderID = "";
  String selectParkingName = "";
  String selectParkingUrl = "";
  int selectPrice = 0;
  Map selectAddress = {};
  List selectReview = [];
  final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );
  final storage = const FlutterSecureStorage();
  Set<Polyline> polylines = {};
  late LatLng clickMarker;
  bool _isParkingSelect = false;
  final parkingAreaService = ParkingAreaService();
  List<ParkingArea> parkingAreaList = [];
  bool isParkingFavSelect = false;
  int hourStart = 0;
  int hourEnd = 0;

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
    _loadParkingAreaFavorite();
    checkFilter();
  }

  void checkFilter() async {
    if (widget.keyword != "") {
      await getAddress(LatLng(
          widget.currentPosition.latitude, widget.currentPosition.longitude));
      for (int i = 0; i < address.length; i++) {
        addMakers(address[i]['_id'], address[i]['address']['latitude'],
            address[i]['address']['longitude']);
      }
      setState(() {
        _showLocationList = true;
        clickMarker = LatLng(
            widget.currentPosition.latitude, widget.currentPosition.longitude);
      });
    }
  }

  void _loadParkingAreaFavorite() async {
    try {
      final parkingAreas = await parkingAreaService.getParkingAreaFavorite();
      if (!mounted) return;
      setState(() {
        parkingAreaList = parkingAreas;
      });
    } catch (err) {
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
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
      clickMarker = LatLng(latlang.latitude, latlang.longitude);
    });
  }

  void addMakers(String id, double latitude, double longitude) async {
    BitmapDescriptor placeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "lib/assets/icons/placeIcon.png",
    );

    LatLng latlang = LatLng(latitude, longitude);
    if (!mounted) return;
    setState(() {
      markers.add(Marker(
        markerId: MarkerId(id),
        position: latlang,
        icon: placeIcon,
      ));
    });
  }

  void changeMaker(String id, LatLng latlang) async {
    BitmapDescriptor placeIconHL = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "lib/assets/icons/placeIconHL.png",
    );
    setState(() {
      markers.add(Marker(
        markerId: MarkerId(id),
        position: latlang,
        icon: placeIconHL,
      ));
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

      final LatLng searchPosition =
          LatLng(placeLocation['lat'], placeLocation['lng']);

      changeCameraGoogleMap(searchPosition, true);
      LatLng latlong =
          LatLng(searchPosition.latitude, searchPosition.longitude);
      await getAddress(latlong);
      for (int i = 0; i < address.length; i++) {
        addMakers(address[i]['_id'], address[i]['address']['latitude'],
            address[i]['address']['longitude']);
      }
    } catch (e) {
      //Failed to load data from Google Place API
    }
  }

  void changeCameraGoogleMap(LatLng latlang, bool clear) {
    if (clear) {
      if (markers.isNotEmpty) {
        markers.clear();
      }
      addMakerPress(LatLng(latlang.latitude, latlang.longitude));
    }
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(latlang.latitude, latlang.longitude), zoom: 18)));
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> poly = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      LatLng position = LatLng(latitude, longitude);
      poly.add(position);
    }
    return poly;
  }

  Future<void> getDirections(
      LatLng selectLocation, LatLng selectParking) async {
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${selectLocation.latitude},${selectLocation.longitude}&destination=${selectParking.latitude},${selectParking.longitude}&key=${dotenv.env['directionsAPIkey']}';

    final http.Response response = await http.get(Uri.parse(apiUrl));

    final Map<String, dynamic> responseData = json.decode(response.body);

    final List<LatLng> polylineCoordinates = [];

    if (responseData['routes'] != null) {
      late final Map bounds;
      responseData['routes'].forEach((route) {
        List<LatLng> decodedPolylinePoints =
            _decodePoly(route['overview_polyline']['points']);
        polylineCoordinates.addAll(decodedPolylinePoints);
        bounds = route['bounds'];
      });
      setState(() {
        polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: AppColor.appPrimaryColor,
          width: 5,
          points: polylineCoordinates,
        ));
      });

      // Zoom to fit the polyline
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest:
                LatLng(bounds['southwest']['lat'], bounds['southwest']['lng']),
            northeast:
                LatLng(bounds['northeast']['lat'], bounds['southwest']['lng']),
          ),
          100.0,
        ),
      );
    }
  }

  Future<void> getAddress(LatLng latlong) async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      try {
        int maxPrice = 0;
        int minPrice = 0;
        if (widget.price == 1) {
          maxPrice = 30;
          minPrice = 0;
        } else if (widget.price == 2) {
          maxPrice = 60;
          minPrice = 30;
        } else if (widget.price == 3) {
          maxPrice = 90;
          minPrice = 60;
        } else if (widget.price == 4) {
          maxPrice = 120;
          minPrice = 90;
        } else if (widget.price == 5) {
          maxPrice = 999999;
          minPrice = 120;
        }

        List date = [widget.startDate];
        if (widget.startDate != widget.endDate) {
          date.add(widget.endDate);
        }

        if (widget.entryTime.hour != 24) {
          hourStart = widget.entryTime.hour;
        }
        if (widget.exitTime.hour != 24) {
          hourEnd = widget.exitTime.hour;
        }

        Map data = {
          'keyword': widget.keyword,
          'latitude': latlong.latitude,
          'longitude': latlong.longitude,
          'review': widget.review,
          'max_price': maxPrice,
          'min_price': minPrice,
          'date': date,
          'hour_start': hourStart,
          'hour_end': hourEnd,
          'min_start': widget.entryTime.minute,
          'min_end': widget.exitTime.minute,
        };
        String body = json.encode(data);
        final url = Uri.parse('${dotenv.env['HOST']}/customer/search_parking');

        final response = await http.post(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $accessToken'
            },
            body: body);

        if (response.statusCode == 200) {
          setState(() {
            address = jsonDecode(response.body.toString())['data'];
          });
        } else {
          _logger.e('Failed to connect to API: ${response.body}');
        }
      } catch (e) {
        // Failed to load data from Backend
      }
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/login');
    }
  }

  Widget locationListSheet() {
    return GestureDetector(
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: address.length >= 3
              ? (150 / MediaQuery.of(context).size.height)
              : address.length * 60 / MediaQuery.of(context).size.height,
          // : (70 / MediaQuery.of(context).size.height),
          minChildSize: address.isNotEmpty
              ? (59 / MediaQuery.of(context).size.height)
              : address.length * 50 / MediaQuery.of(context).size.height,
          maxChildSize:
              (address.length * 60) / MediaQuery.of(context).size.height,
          builder: (BuildContext context, ScrollController scrollController) {
            return ListView(
              controller: scrollController,
              children: address.map((data) {
                return InkWell(
                  onTap: () {
                    String selectLocationOld = selectLocation;
                    setState(() {
                      polylines = {};
                      selectLocation = data['_id'];
                      selectProviderID = data['provider_id'];
                      selectParkingName = data['parking_name'];
                      selectParkingUrl = data['parking_picture_url'];
                      selectAddress = data['address'];
                      selectPrice = data['price'];
                      selectReview = data['review'];
                      _isParkingSelect = true;
                    });
                    for (int i = 0; i < markers.length; i++) {
                      if (markers[i].markerId == MarkerId(selectLocation)) {
                        LatLng latlang = markers[i].position;
                        markers.removeAt(i);
                        changeMaker(selectLocation, latlang);
                      }
                    }
                    for (int i = 0; i < markers.length; i++) {
                      if (markers[i].markerId == MarkerId(selectLocationOld)) {
                        LatLng latlang = markers[i].position;
                        markers.removeAt(i);
                        addMakers(selectLocationOld, latlang.latitude,
                            latlang.longitude);
                      }
                    }
                    getDirections(
                        clickMarker,
                        LatLng(data['address']['latitude'],
                            data['address']['longitude']));
                    changeCameraGoogleMap(
                        LatLng(data['address']['latitude'],
                            data['address']['longitude']),
                        false);
                    if (parkingAreaService.isParkingAreaExist(
                        parkingAreaList, data['_id'])) {
                      setState(() {
                        isParkingFavSelect = true;
                      });
                    }
                  },
                  child: Container(
                    color: Colors.white,
                    height: 50,
                    child: Container(
                      padding: const EdgeInsets.only(left: 50, right: 20),
                      color: selectLocation == data['_id']
                          ? const Color.fromRGBO(16, 227, 88, 0.2)
                          : Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 31,
                                width: 31,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF6828DC)),
                                child: const Icon(
                                  Icons.place,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        data['parking_name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 5),
                                      if (parkingAreaService.isParkingAreaExist(
                                          parkingAreaList, data['_id']))
                                        const Icon(
                                          Icons.favorite,
                                          size: 14,
                                          color: Colors.red,
                                        )
                                    ],
                                  ),
                                  Text(
                                    data['distance'] >= 1
                                        ? "${data['distance'].round()} กิโลเมตร"
                                        : "${(data['distance'] * 1000).round()} เมตร",
                                    style: const TextStyle(fontSize: 12),
                                  )
                                ],
                              )
                            ],
                          ),
                          Text(
                            "${data['price']} ฿ / ชั่วโมง",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: !_showLocationList
          ? AppBar(
              title: const Text('แผนที่'),
              centerTitle: true,
              backgroundColor: const Color(0xFF6828DC),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.currentPosition.latitude,
                    widget.currentPosition.longitude),
                zoom: 18,
              ),
              onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
              markers: markers.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              polylines: polylines,
              onTap: (latlang) async {
                if (markers.isNotEmpty) {
                  markers.clear();
                }
                addMakerPress(latlang);
                // await _getAddressFromLatLng(latlang);

                setState(() {
                  _showLocationList = true;
                  polylines = {};
                  selectLocation = "x";
                  _isParkingSelect = false;
                  // _controller.query = '$markerAddress';
                });
                mapController.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: LatLng(latlang.latitude, latlang.longitude),
                        zoom: 18)));
                await getAddress(latlang);
                for (int i = 0; i < address.length; i++) {
                  addMakers(
                      address[i]['_id'],
                      address[i]['address']['latitude'],
                      address[i]['address']['longitude']);
                }
              },
            ),
            Visibility(
              visible: !_showLocationList,
              child: FloatingSearchBar(
                hint: 'ค้นหาที่จอดรถ',
                scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
                transitionDuration: const Duration(milliseconds: 500),
                transitionCurve: Curves.easeInOut,
                physics: const BouncingScrollPhysics(),
                openAxisAlignment: 0.0,
                width: MediaQuery.of(context).size.width - 80,
                debounceDelay: const Duration(milliseconds: 500),
                controller: _controller,
                automaticallyImplyBackButton: false,
                onQueryChanged: (query) {
                  getSuggestion(query);
                },
                clearQueryOnClose: false,
                transition: CircularFloatingSearchBarTransition(),
                leadingActions: [
                  FloatingSearchBarAction(
                    showIfOpened: false,
                    child: CircularButton(
                      icon: const Icon(
                        Icons.place,
                        color: Color(0xFFA6AAB4),
                      ),
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
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFFA6AAB4),
                      ),
                      onPressed: () {
                        if (markers.isNotEmpty) {
                          markers.clear();
                          _showLocationList = false;
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
                                  _showLocationList = true;
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
            ),
            Visibility(
              visible: _showLocationList,
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectLocation = "";
                        selectProviderID = "";
                        selectParkingName = "";
                        selectAddress = {};
                        selectPrice = 0;
                        selectReview = [];
                        polylines = {};
                        _showLocationList = false;
                        _isParkingSelect = false;
                        markers.clear();
                      });
                    },
                    child: Container(
                      height: 31,
                      width: 31,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFF6828DC)),
                      child: const Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _showLocationList,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showLocationList = false;
                        markers.clear();
                      });
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Container(
                      height: 31,
                      width: 31,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFF6828DC)),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _showLocationList,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: locationListSheet(),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _showLocationList,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 90,
                  // color: const Color(0xFFF1F1F1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 61, vertical: 20),
                  child: PurpleButton(
                    label: "ยืนยัน",
                    color: _isParkingSelect
                        ? AppColor.appPrimaryColor
                        : Colors.grey,
                    onPressed: _isParkingSelect
                        ? () => {
                              if (selectParkingUrl.startsWith(
                                  "https://parkingadmindata.s3.ap-southeast-1.amazonaws.com/parkingarea/"))
                                {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BookingPage(
                                                parkingID: selectLocation,
                                                providerID: selectProviderID,
                                                parkingName: selectParkingName,
                                                parkingUrl: selectParkingUrl,
                                                address: selectAddress,
                                                price: selectPrice,
                                                review: selectReview,
                                                startDate: widget.startDate,
                                                endDate: widget.endDate,
                                                entryTime: widget.entryTime,
                                                exitTime: widget.exitTime,
                                                isParkingFavSelect:
                                                    isParkingFavSelect,
                                              )))
                                }
                              else
                                {EasyLoading.showError("ไม่พบรูปภาพ")}
                            }
                        : () => {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
          visible: !_showLocationList,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF6828DC),
            onPressed: () {
              getCurrentPosition();
            },
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          )),
    );
  }
}
