import 'package:flutter/material.dart';

class ColorFilters {
  ColorFilters._();

  static const ColorFilter grayscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, // Red channel
    0.2126, 0.7152, 0.0722, 0, 0, // Green channel
    0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
    0, 0, 0, 0.4, 0, // Alpha channel (40% opacity)
  ]);

  static const ColorFilter none = ColorFilter.matrix([
    1, 0, 0, 0, 0, // Red channel
    0, 1, 0, 0, 0, // Green channel
    0, 0, 1, 0, 0, // Blue channel
    0, 0, 0, 1, 0, // Alpha channel
  ]);
}
