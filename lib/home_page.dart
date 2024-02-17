import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CompassHomePage extends StatefulWidget {
  const CompassHomePage({Key? key}) : super(key: key);

  @override
  State<CompassHomePage> createState() => _CompassHomePageState();
}

class _CompassHomePageState extends State<CompassHomePage> {
  double _azimuth = 0;

  @override
  void initState() {
    super.initState();
    _setupSensors();
  }

  void _setupSensors() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      magnetometerEventStream().listen((MagnetometerEvent event) {
        setState(() {
          _azimuth = _calculateAzimuth(event);
        });
      });
    });
  }

  double _calculateAzimuth(MagnetometerEvent event) {
    // Galactic center coordinates
    double galacticCenterRAHours = 17.75; // in hours
    double galacticCenterDec = -28.94; // in degrees

    // Convert Right Ascension to degrees
    double galacticCenterRADeg = galacticCenterRAHours * 15;

    // Convert azimuth to radians
    double azimuthRad = atan2(event.y, event.x);

    // Calculate difference in Right Ascension between the device's orientation and the galactic center
    double deltaRA = (galacticCenterRADeg - azimuthRad * (180 / pi)) %
        360; // Ensure result is within 0-360 range

    // Calculate azimuth angle
    double azimuth = atan2(
            sin(deltaRA * (pi / 180)),
            cos(azimuthRad) * tan(galacticCenterDec * (pi / 180)) -
                sin(azimuthRad) * cos(deltaRA * (pi / 180))) *
        (180 / pi);

    return azimuth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galactic Compass'),
      ),
      body: Column(
        children: [
          Center(
            child: Transform.rotate(
              angle: ((_azimuth) * pi / 180 * -1),
              child: const Icon(
                Icons.navigation,
                size: 200,
              ),
            ),
          ),
          const Text(
            'Galactic Center : 26,000 light-years away',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
