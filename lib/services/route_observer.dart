// lib/services/route_observer.dart
import 'package:flutter/material.dart';

/// Global route observer — screens subscribe karke route changes sun sakti hain.
/// Isse pata chalta hai jab koi screen wapas focus me aati hai (back from another screen).
final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();