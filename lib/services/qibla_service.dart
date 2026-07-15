import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaService {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  Future<QiblaData?> getQiblaDirection() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    final position = await Geolocator.getCurrentPosition();
    final qiblaBearing = _calculateQiblaBearing(
      position.latitude,
      position.longitude,
    );

    double? deviceHeading;
    final compassEvents = FlutterCompass.events;
    if (compassEvents != null) {
      await for (final event in compassEvents.take(1)) {
        deviceHeading = event.heading;
        break;
      }
    }

    return QiblaData(
      qiblaBearing: qiblaBearing,
      deviceHeading: deviceHeading ?? 0,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  double _calculateQiblaBearing(double lat, double lng) {
    final latRad = lat * pi / 180;
    final lngRad = lng * pi / 180;
    final kaabaLatRad = kaabaLat * pi / 180;
    final kaabaLngRad = kaabaLng * pi / 180;

    final dLng = kaabaLngRad - lngRad;
    final y = sin(dLng) * cos(kaabaLatRad);
    final x = cos(latRad) * sin(kaabaLatRad) -
        sin(latRad) * cos(kaabaLatRad) * cos(dLng);

    var bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }
}

class QiblaData {
  const QiblaData({
    required this.qiblaBearing,
    required this.deviceHeading,
    required this.latitude,
    required this.longitude,
  });

  final double qiblaBearing;
  final double deviceHeading;
  final double latitude;
  final double longitude;

  double get compassRotation => qiblaBearing - deviceHeading;
}
