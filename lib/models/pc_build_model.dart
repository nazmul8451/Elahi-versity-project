import 'pc_component_model.dart';

class PcBuildModel {
  final String id;
  final String title;
  final String tier; // "Ultimate Gaming", "Pro Workstation", "Budget Beast", "Creator Edition"
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviews;
  final String description;
  final String imageUrl;
  final String cpu;
  final String gpu;
  final String ram;
  final String storage;
  final String motherboard;
  final String psu;
  final String cooler;
  final String casing;
  final int totalWattage;
  final List<String> tags;
  final String badge;
  final bool isFeatured;
  final List<PcComponent> defaultComponents;

  const PcBuildModel({
    required this.id,
    required this.title,
    required this.tier,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviews,
    required this.description,
    required this.imageUrl,
    required this.cpu,
    required this.gpu,
    required this.ram,
    required this.storage,
    required this.motherboard,
    required this.psu,
    required this.cooler,
    required this.casing,
    required this.totalWattage,
    required this.tags,
    this.badge = '',
    this.isFeatured = false,
    this.defaultComponents = const [],
  });

  double get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).roundToDouble();
  }
}
