import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinController extends GetxController {
  static const String _coinsKey = 'total_coins';

  final RxInt totalCoins = 0.obs;

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadCoins();
  }

  /// Load coins from persistent storage
  void loadCoins() {
    final savedCoins = _prefs.getInt(_coinsKey) ?? 0;
    totalCoins.value = savedCoins;
  }

  /// Add coins and persist automatically
  void addCoins(int value) {
    if (value > 0) {
      totalCoins.value += value;
      _saveCoins();
    }
  }

  /// Save coins to persistent storage
  Future<void> _saveCoins() async {
    await _prefs.setInt(_coinsKey, totalCoins.value);
  }

  /// Reset coins (for testing or reset functionality)
  void resetCoins() {
    totalCoins.value = 0;
    _saveCoins();
  }
}
