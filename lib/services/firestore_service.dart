import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_data.dart';
import '../models/order_model.dart';
import '../models/pc_build_model.dart';
import '../models/pc_component_model.dart';

class FirestoreService {
  final FirebaseFirestore? _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _safeInstance();

  static FirebaseFirestore? _safeInstance() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Collection References
  CollectionReference<Map<String, dynamic>>? get _componentsCol =>
      _firestore?.collection('components');
  CollectionReference<Map<String, dynamic>>? get _prebuiltPcsCol =>
      _firestore?.collection('prebuilt_pcs');
  CollectionReference<Map<String, dynamic>>? get _ordersCol =>
      _firestore?.collection('orders');

  // =========================================================================
  // 1. COMPONENTS CATALOG
  // =========================================================================

  /// Stream components from Firestore with automatic fallback to local AppData if empty
  Stream<List<PcComponent>> streamComponents({ComponentCategory? category}) {
    if (_componentsCol == null) {
      if (category != null) {
        return Stream.value(AppData.allComponents.where((c) => c.category == category).toList());
      }
      return Stream.value(AppData.allComponents);
    }

    Query<Map<String, dynamic>> query = _componentsCol!;
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        if (category != null) {
          return AppData.allComponents.where((c) => c.category == category).toList();
        }
        return AppData.allComponents;
      }
      return snapshot.docs.map((doc) => PcComponent.fromJson(doc.data(), doc.id)).toList();
    }).handleError((_) {
      if (category != null) {
        return AppData.allComponents.where((c) => c.category == category).toList();
      }
      return AppData.allComponents;
    });
  }

  /// One-time fetch of components
  Future<List<PcComponent>> getComponents({ComponentCategory? category}) async {
    try {
      if (_componentsCol != null) {
        Query<Map<String, dynamic>> query = _componentsCol!;
        if (category != null) {
          query = query.where('category', isEqualTo: category.name);
        }
        final snapshot = await query.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => PcComponent.fromJson(doc.data(), doc.id))
              .toList();
        }
      }
    } catch (_) {}

    if (category != null) {
      return AppData.allComponents.where((c) => c.category == category).toList();
    }
    return AppData.allComponents;
  }

  // =========================================================================
  // 2. PREBUILT PCS STORE
  // =========================================================================

  /// Stream pre-built PCs with fallback to AppData.featuredPrebuilts
  Stream<List<PcBuildModel>> streamPrebuiltPcs() {
    if (_prebuiltPcsCol == null) {
      return Stream.value(AppData.featuredPrebuilts);
    }
    return _prebuiltPcsCol!.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return AppData.featuredPrebuilts;
      }
      return snapshot.docs
          .map((doc) => PcBuildModel.fromJson(doc.data(), doc.id))
          .toList();
    }).handleError((_) => AppData.featuredPrebuilts);
  }

  /// One-time fetch of pre-built systems
  Future<List<PcBuildModel>> getPrebuiltPcs() async {
    try {
      if (_prebuiltPcsCol != null) {
        final snapshot = await _prebuiltPcsCol!.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => PcBuildModel.fromJson(doc.data(), doc.id))
              .toList();
        }
      }
    } catch (_) {}
    return AppData.featuredPrebuilts;
  }

  // =========================================================================
  // 3. ORDERS & REAL-TIME TRACKING
  // =========================================================================

  /// Stream orders for a specific user. If Firestore has no orders for this user,
  /// returns mock active & completed orders for seamless initial experience.
  Stream<List<OrderModel>> streamUserOrders(String userId) {
    if (_ordersCol == null) {
      return Stream.value(AppData.mockOrders);
    }
    return _ordersCol!
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return AppData.mockOrders;
      }
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
          .toList();
    }).handleError((_) => AppData.mockOrders);
  }

  /// Place a new custom or prebuilt PC order to Firestore
  Future<String> createOrder({
    required String userId,
    required String buildName,
    required double totalAmount,
    required List<OrderItemModel> items,
    required String shippingAddress,
    required String paymentMethod,
    String? customTrackingNumber,
  }) async {
    final String trackingNumber = customTrackingNumber ??
        'RC-${DateTime.now().year}-${100000 + Random().nextInt(900000)}';

    final now = DateTime.now();
    final estimatedDeliveryDate = now.add(const Duration(days: 4));
    final String orderDateStr =
        '${_monthName(now.month)} ${now.day.toString().padLeft(2, '0')}, ${now.year}';
    final String estDeliveryStr =
        '${_monthName(estimatedDeliveryDate.month)} ${estimatedDeliveryDate.day.toString().padLeft(2, '0')}, ${estimatedDeliveryDate.year}';

    final String docId = _ordersCol?.doc().id ?? 'order_${DateTime.now().millisecondsSinceEpoch}';

    final order = OrderModel(
      id: docId,
      userId: userId,
      orderDate: orderDateStr,
      estimatedDelivery: estDeliveryStr,
      status: OrderStatus.confirmed,
      totalAmount: totalAmount,
      buildName: buildName,
      items: items,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      trackingNumber: trackingNumber,
    );

    if (_ordersCol != null) {
      await _ordersCol!.doc(docId).set(order.toFirestore());
    }
    return docId;
  }

  // =========================================================================
  // 4. SAVED CUSTOM BUILDS (User's Cloud Profile)
  // =========================================================================

  CollectionReference<Map<String, dynamic>>? _savedBuildsCol(String userId) =>
      _firestore?.collection('users').doc(userId).collection('saved_builds');

  /// Stream user's cloud saved rigs
  Stream<List<PcBuildModel>> streamSavedBuilds(String userId) {
    final col = _savedBuildsCol(userId);
    if (col == null) {
      return Stream.value(AppData.savedBuilds);
    }
    return col.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return AppData.savedBuilds;
      }
      return snapshot.docs
          .map((doc) => PcBuildModel.fromJson(doc.data(), doc.id))
          .toList();
    }).handleError((_) => AppData.savedBuilds);
  }

  /// Save a custom PC configuration to Firestore
  Future<String> saveCustomBuild({
    required String userId,
    required String name,
    required List<PcComponent> components,
    required double totalPrice,
    required int totalWattage,
  }) async {
    final col = _savedBuildsCol(userId);
    final String docId = col?.doc().id ?? 'saved_${DateTime.now().millisecondsSinceEpoch}';

    String cpuName = components
            .where((c) => c.category == ComponentCategory.cpu)
            .firstOrNull
            ?.name ??
        'N/A';
    String gpuName = components
            .where((c) => c.category == ComponentCategory.gpu)
            .firstOrNull
            ?.name ??
        'Integrated';
    String ramName = components
            .where((c) => c.category == ComponentCategory.ram)
            .firstOrNull
            ?.name ??
        'N/A';
    String storageName = components
            .where((c) => c.category == ComponentCategory.storage)
            .firstOrNull
            ?.name ??
        'N/A';
    String moboName = components
            .where((c) => c.category == ComponentCategory.motherboard)
            .firstOrNull
            ?.name ??
        'N/A';
    String psuName = components
            .where((c) => c.category == ComponentCategory.psu)
            .firstOrNull
            ?.name ??
        'N/A';
    String coolerName = components
            .where((c) => c.category == ComponentCategory.cooler)
            .firstOrNull
            ?.name ??
        'Stock Cooler';
    String casingName = components
            .where((c) => c.category == ComponentCategory.casing)
            .firstOrNull
            ?.name ??
        'Mid Tower Case';

    final savedBuild = PcBuildModel(
      id: docId,
      title: name.isEmpty ? 'Custom Dream Rig' : name,
      tier: 'Custom User Build',
      price: totalPrice,
      rating: 5.0,
      reviews: 1,
      description: 'Custom configured rig with $cpuName and $gpuName.',
      imageUrl: components.where((c) => c.category == ComponentCategory.casing).firstOrNull?.imageUrl.isNotEmpty == true
          ? components.firstWhere((c) => c.category == ComponentCategory.casing).imageUrl
          : 'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?auto=format&fit=crop&w=600&q=80',
      cpu: cpuName,
      gpu: gpuName,
      ram: ramName,
      storage: storageName,
      motherboard: moboName,
      psu: psuName,
      cooler: coolerName,
      casing: casingName,
      totalWattage: totalWattage,
      tags: ['Custom Rig', 'User Config'],
      badge: 'SAVED',
      defaultComponents: components,
    );

    if (col != null) {
      await col.doc(docId).set(savedBuild.toFirestore());
    }
    return docId;
  }

  /// Delete a saved custom build
  Future<void> deleteSavedBuild(String userId, String buildId) async {
    await _savedBuildsCol(userId)?.doc(buildId).delete();
  }

  // =========================================================================
  // 5. SEED CATALOG (Helper to populate Firestore for Admin Dashboard)
  // =========================================================================

  /// Populate initial components and prebuilt rigs if collections are fresh
  Future<void> seedDatabaseIfEmpty() async {
    final fs = _firestore;
    final compCol = _componentsCol;
    final pcCol = _prebuiltPcsCol;

    if (fs == null || compCol == null || pcCol == null) {
      return;
    }
    try {
      final compSnapshot = await compCol.limit(1).get();
      if (compSnapshot.docs.isEmpty) {
        final batch = fs.batch();
        for (var comp in AppData.allComponents) {
          final doc = compCol.doc(comp.id);
          batch.set(doc, comp.toFirestore());
        }
        await batch.commit();
      }

      final pcSnapshot = await pcCol.limit(1).get();
      if (pcSnapshot.docs.isEmpty) {
        final batch = fs.batch();
        for (var pc in AppData.featuredPrebuilts) {
          final doc = pcCol.doc(pc.id);
          batch.set(doc, pc.toFirestore());
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
