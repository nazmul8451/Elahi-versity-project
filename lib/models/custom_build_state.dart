import 'package:flutter/foundation.dart';
import 'pc_component_model.dart';

class CustomBuildState extends ChangeNotifier {
  final Map<ComponentCategory, PcComponent> _selectedComponents = {};
  String _buildName = 'My Custom PC';
  double? _targetBudget;

  Map<ComponentCategory, PcComponent> get selectedComponents =>
      Map.unmodifiable(_selectedComponents);

  String get buildName {
    if (_buildName.isEmpty) return 'My Custom PC';
    return _buildName
        .replaceAll(RegExp(r'\bRigs\b', caseSensitive: false), 'PCs')
        .replaceAll(RegExp(r'\bRig\b', caseSensitive: false), 'PC');
  }
  double? get targetBudget => _targetBudget;
  bool get hasBudget => _targetBudget != null && _targetBudget! > 0;

  void setBuildName(String name) {
    _buildName = name
        .replaceAll(RegExp(r'\bRigs\b', caseSensitive: false), 'PCs')
        .replaceAll(RegExp(r'\bRig\b', caseSensitive: false), 'PC');
    notifyListeners();
  }

  void setTargetBudget(double? budget) {
    _targetBudget = (budget != null && budget > 0) ? budget : null;
    notifyListeners();
  }

  void clearTargetBudget() {
    _targetBudget = null;
    notifyListeners();
  }

  void selectComponent(PcComponent component) {
    _selectedComponents[component.category] = component;
    notifyListeners();
  }

  void removeComponent(ComponentCategory category) {
    _selectedComponents.remove(category);
    notifyListeners();
  }

  void loadComponents(List<PcComponent> components, {String? buildName, double? budget}) {
    _selectedComponents.clear();
    for (var comp in components) {
      _selectedComponents[comp.category] = comp;
    }
    if (buildName != null) {
      _buildName = buildName;
    }
    if (budget != null && budget > 0) {
      _targetBudget = budget;
    }
    notifyListeners();
  }

  void reset({bool keepBudget = true}) {
    _selectedComponents.clear();
    _buildName = 'My Custom PC';
    if (!keepBudget) {
      _targetBudget = null;
    }
    notifyListeners();
  }

  double get totalPrice {
    return _selectedComponents.values.fold(0.0, (sum, item) => sum + item.price);
  }

  // Budget calculations
  bool get isOverBudget => hasBudget && totalPrice > _targetBudget!;

  double get budgetRemaining => hasBudget ? (_targetBudget! - totalPrice) : 0.0;

  double get budgetOverAmount => isOverBudget ? (totalPrice - _targetBudget!) : 0.0;

  double get budgetUsageRatio {
    if (!hasBudget) return 0.0;
    return (totalPrice / _targetBudget!).clamp(0.0, 1.5);
  }

  double get budgetUsagePercent {
    if (!hasBudget) return 0.0;
    return (totalPrice / _targetBudget!) * 100;
  }

  /// Calculates what the total price would be if [newComponent] is selected in its category.
  double calculateSimulatedTotal(PcComponent newComponent) {
    double sum = 0.0;
    for (var entry in _selectedComponents.entries) {
      if (entry.key != newComponent.category) {
        sum += entry.value.price;
      }
    }
    sum += newComponent.price;
    return sum;
  }

  /// Checks if selecting [newComponent] would cause the build to exceed the target budget.
  bool wouldExceedBudget(PcComponent newComponent) {
    if (!hasBudget) return false;
    return calculateSimulatedTotal(newComponent) > _targetBudget!;
  }

  /// Calculates remaining budget or over-budget difference if [newComponent] is selected.
  double simulatedBudgetDiff(PcComponent newComponent) {
    if (!hasBudget) return 0.0;
    final simulated = calculateSimulatedTotal(newComponent);
    return _targetBudget! - simulated;
  }

  int get totalEstimatedWattage {
    int baseWatts = 65; // fans, motherboard, peripherals base
    return _selectedComponents.values.fold(baseWatts, (sum, item) => sum + item.wattage);
  }

  int get selectedCount => _selectedComponents.length;
  int get totalRequiredCount => 8; // CPU, Motherboard, GPU, RAM, Storage, PSU, Cooler, Case

  double get progress => (selectedCount / totalRequiredCount).clamp(0.0, 1.0);

  // Compatibility checking
  List<String> get compatibilityWarnings {
    List<String> warnings = [];

    // Target Budget check
    if (isOverBudget) {
      warnings.add(
        'Budget Alert: Current build total (৳${totalPrice.toStringAsFixed(0)}) exceeds your target budget of ৳${targetBudget!.toStringAsFixed(0)} by ৳${budgetOverAmount.toStringAsFixed(0)}.',
      );
    }

    final cpu = _selectedComponents[ComponentCategory.cpu];
    final mobo = _selectedComponents[ComponentCategory.motherboard];
    final ram = _selectedComponents[ComponentCategory.ram];
    final psu = _selectedComponents[ComponentCategory.psu];

    // Socket check
    if (cpu != null && mobo != null) {
      if (cpu.socket != 'N/A' && mobo.socket != 'N/A' && cpu.socket != mobo.socket) {
        warnings.add('Socket mismatch: CPU (${cpu.socket}) does not fit Motherboard (${mobo.socket}).');
      }
    }

    // RAM generation check
    if (mobo != null && ram != null) {
      if (mobo.memoryType != 'N/A' && ram.memoryType != 'N/A' && mobo.memoryType != ram.memoryType) {
        warnings.add('Memory mismatch: Motherboard requires ${mobo.memoryType} but selected RAM is ${ram.memoryType}.');
      }
    }

    // PSU wattage check
    if (psu != null) {
      int psuWattage = int.tryParse(psu.specs['Wattage']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0;
      if (psuWattage > 0 && totalEstimatedWattage > psuWattage - 50) {
        warnings.add('Power Supply alert: PC estimated at ${totalEstimatedWattage}W is close to or exceeds PSU rating (${psuWattage}W). Recommended: 750W+.');
      }
    }

    return warnings;
  }

  bool get isFullyCompatible => compatibilityWarnings.isEmpty;
}
