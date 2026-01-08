import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Shared Liquid Glass settings for the iOS theme aesthetic.
const kIOSLiquidGlassSettings = LiquidGlassSettings(
  blur: 24.0,
  thickness: 8.0,
  glassColor: Color(0x15FFFFFF), // Very subtle white tint
  refractiveIndex: 1.1,
  lightIntensity: 0.3,
  ambientStrength: 0.1,
  saturation: 1.2,
);
