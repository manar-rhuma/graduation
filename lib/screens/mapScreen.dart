import 'package:flutter/material.dart'; // مكوّنات واجهة المستخدم
import 'package:flutter_map/flutter_map.dart'; // مكتبة لرسم الخريطة
import 'package:latlong2/latlong.dart'; // لحساب الإحداثيات (Latitude و Longitude)
import 'package:location/location.dart'; // للحصول على موقع المستخدم
import 'package:http/http.dart'
    as http; //  نعرف منه االمسار من راوتر لإرسال طلب HTTP
import 'dart:convert'; // لتحويل JSON إلى كائن Dart

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController(); // يتحكم في حركة الخريطة
  LocationData? currentLocation; // يخزن الموقع الحالي للمستخدم
  List<LatLng> routePoints = []; // يخزن نقاط المسار المرسوم بين موقعك والوجهة
  List<Marker> markers = []; // يخزن علامات (Markers) تظهر على الخريطة
  LatLng? _clientLocation;
  final String orsApiKey =
      '5b3ce3597851110001cf62482a3bbccce840449baea616641f870310';

  @override
  void initState() {
    // اول م نفتح صفحة تستخدم نجيب البيانات بيها
    super.initState();
    _getCurrentLocation(); // ينفذ الدالة التي تجلب الموقع الحالي
  }

  // دالة لجلب الموقع الحالي للمستخدم
  Future<void> _getCurrentLocation() async {
    var location = Location();

    try {
      var userLocation =
          await location.getLocation(); // ينتظر حتى يحصل على الموقع
      setState(() {
        currentLocation = userLocation; // يخزن الموقع في المتغير

        // يضيف Marker بلون أزرق على موقع المستخدم
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(userLocation.latitude!, userLocation.longitude!),
            child:
                const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
          ),
        );
      });
    } on Exception {
      currentLocation = null; // في حالة حدوث خطأ
    }

    //  تحديث تلقائي عند تغيّر الموقع
    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
      });
    });
  }

  // دالة للحصول على مسار من موقع المستخدم إلى الوجهة
  Future<void> _getRoute(LatLng destination) async {
    if (currentLocation == null) return; // يتأكد أن الموقع معروف

    final start =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    // طلب GET إلى OpenRouteService للحصول على المسار
    final response = await http.get(
      Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car'
        '?api_key=$orsApiKey'
        '&start=${start.longitude},${start.latitude}'
        '&end=${destination.longitude},${destination.latitude}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body); // فك تشفير JSON
      final List<dynamic> coords =
          data['features'][0]['geometry']['coordinates']; // استخراج النقاط

      setState(() {
        // تحويل النقاط إلى LatLng
        routePoints =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();

        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: destination,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
          ),
        );
      });
    } else {
      print('Failed to fetch route');
    }
  }



void _addDestinationMarker(LatLng point) async {
  // تحديث الموقع في الواجهة أولاً
  setState(() {
    _clientLocation = point;
    markers.clear();
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: point,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
      ),
    );
  });

  // تأخير صغير قبل العودة للصفحة السابقة
  await Future.delayed(const Duration(milliseconds: 200));

  // إذا كانت الشاشة ما زالت موجودة في الـ context (مقارنة بـ mounted)
  if (mounted) {
    Navigator.pop(context, point);
  }
}


  // عند الضغط على الخريطة، نضيف علامة ونحسب المسار
  /*void _addDestinationMarker(LatLng point) {
    setState(() {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: point,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
        ),
      );
    });

    _getRoute(point); // رسم المسار
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap with Flutter'), // عنوان التطبيق
      ),
      body: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator()) // تحميل حتى نحصل على الموقع
          : FlutterMap(
              mapController: mapController, // ربط الكنترولر بالخريطة
              options: MapOptions(
                initialCenter: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ), // مركز الخريطة في بداية التشغيل
                initialZoom: 15.0, // درجة التكبير
                onTap: (tapPosition, point) =>
                    _addDestinationMarker(point), // إضافة Marker عند الضغط
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'], // سيرفرات الخريطة
                ),
                MarkerLayer(
                  markers: markers, // عرض العلامات
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    // عرض المسار باللون الأزرق
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentLocation != null) {
            mapController.move(
              // إعادة الخريطة إلى موقع المستخدم
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              15.0,
            );
          }
        },
        child: const Icon(Icons.my_location), // أيقونة الموقع
      ),
    );
  }
}
