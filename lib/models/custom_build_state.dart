import 'package:flutter/foundation.dart';
import 'pc_component_model.dart';

class CustomBuildState extends ChangeNotifier {
  final Map<ComponentCategory, PcComponent> _selectedComponents = {};
  String _buildName = 'My Custom Rig';

  Map<ComponentCategory, PcComponent> get selectedComponents =>
      Map.unmodifiable(_selectedComponents);

  String get buildName => _buildName;

  void setBuildName(String name) {
    _buildName = name;
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

  void loadComponents(List<PcComponent> components, {String? buildName}) {
    _selectedComponents.clear();
    for (var comp in components) {
      _selectedComponents[comp.category] = comp;
    }
    if (buildName != null) {
      _buildName = buildName;
    }
    notifyListeners();
  }

  void reset() {
    _selectedComponents.clear();
    _buildName = 'My Custom Rig';
    notifyListeners();
  }

  double get totalPrice {
    return _selectedComponents.values.fold(0.0, (sum, item) => sum + item.price);
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
        warnings.add('Power Supply alert: Rig estimated at ${totalEstimatedWattage}W is close to or exceeds PSU rating (${psuWattage}W). Recommended: 750W+.');
      }
    }

    return warnings;
  }

  bool get isFullyCompatible => compatibilityWarnings.isEmpty;
}
