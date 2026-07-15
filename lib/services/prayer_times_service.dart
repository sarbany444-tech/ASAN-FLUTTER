import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition();
  }

  Future<PrayerTimesData?> getPrayerTimes() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes.today(coordinates, params);
    final now = DateTime.now();

    final prayers = [
      PrayerTimeEntry('Fajr', prayerTimes.fajr),
      PrayerTimeEntry('Sunrise', prayerTimes.sunrise),
      PrayerTimeEntry('Dhuhr', prayerTimes.dhuhr),
      PrayerTimeEntry('Asr', prayerTimes.asr),
      PrayerTimeEntry('Maghrib', prayerTimes.maghrib),
      PrayerTimeEntry('Isha', prayerTimes.isha),
    ];

    PrayerTimeEntry? nextPrayer;
    for (final prayer in prayers) {
      if (prayer.time.isAfter(now) &&
          prayer.name != 'Sunrise') {
        nextPrayer = prayer;
        break;
      }
    }
    nextPrayer ??= PrayerTimeEntry('Fajr', prayerTimes.fajr.add(const Duration(days: 1)));

    return PrayerTimesData(
      prayers: prayers,
      nextPrayer: nextPrayer,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

class PrayerTimeEntry {
  const PrayerTimeEntry(this.name, this.time);
  final String name;
  final DateTime time;
}

class PrayerTimesData {
  const PrayerTimesData({
    required this.prayers,
    required this.nextPrayer,
    required this.latitude,
    required this.longitude,
  });

  final List<PrayerTimeEntry> prayers;
  final PrayerTimeEntry nextPrayer;
  final double latitude;
  final double longitude;
}
