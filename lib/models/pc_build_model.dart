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

  factory PcBuildModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    final List<String> parsedTags = [];
    if (json['tags'] is List) {
      for (var t in (json['tags'] as List)) {
        if (t != null) parsedTags.add(t.toString());
      }
    }

    final List<PcComponent> parsedComponents = [];
    if (json['defaultComponents'] is List) {
      for (var c in (json['defaultComponents'] as List)) {
        if (c is Map<String, dynamic>) {
          parsedComponents.add(PcComponent.fromJson(c));
        }
      }
    }

    return PcBuildModel(
      id: docId ?? (json['id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'Custom Rig',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      originalPrice: json['originalPrice'] != null
          ? ((json['originalPrice'] is num)
              ? (json['originalPrice'] as num).toDouble()
              : double.tryParse(json['originalPrice'].toString()))
          : null,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '4.9') ?? 4.9,
      reviews: (json['reviews'] is num)
          ? (json['reviews'] as num).toInt()
          : int.tryParse(json['reviews']?.toString() ?? '20') ?? 20,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      cpu: json['cpu']?.toString() ?? '',
      gpu: json['gpu']?.toString() ?? '',
      ram: json['ram']?.toString() ?? '',
      storage: json['storage']?.toString() ?? '',
      motherboard: json['motherboard']?.toString() ?? '',
      psu: json['psu']?.toString() ?? '',
      cooler: json['cooler']?.toString() ?? '',
      casing: json['casing']?.toString() ?? '',
      totalWattage: (json['totalWattage'] is num)
          ? (json['totalWattage'] as num).toInt()
          : int.tryParse(json['totalWattage']?.toString() ?? '0') ?? 0,
      tags: parsedTags,
      badge: json['badge']?.toString() ?? '',
      isFeatured: json['isFeatured'] is bool
          ? (json['isFeatured'] as bool)
          : (json['isFeatured']?.toString().toLowerCase() == 'true'),
      defaultComponents: parsedComponents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tier': tier,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviews': reviews,
      'description': description,
      'imageUrl': imageUrl,
      'cpu': cpu,
      'gpu': gpu,
      'ram': ram,
      'storage': storage,
      'motherboard': motherboard,
      'psu': psu,
      'cooler': cooler,
      'casing': casing,
      'totalWattage': totalWattage,
      'tags': tags,
      'badge': badge,
      'isFeatured': isFeatured,
      'defaultComponents': defaultComponents.map((c) => c.toJson()).toList(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'tier': tier,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviews': reviews,
      'description': description,
      'imageUrl': imageUrl,
      'cpu': cpu,
      'gpu': gpu,
      'ram': ram,
      'storage': storage,
      'motherboard': motherboard,
      'psu': psu,
      'cooler': cooler,
      'casing': casing,
      'totalWattage': totalWattage,
      'tags': tags,
      'badge': badge,
      'isFeatured': isFeatured,
      'defaultComponents': defaultComponents.map((c) => c.toFirestore()).toList(),
    };
  }
}
