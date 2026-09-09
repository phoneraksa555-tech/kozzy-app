import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/product.dart';
import '../models/store_collection.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/settings_service.dart';

class ShopProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final SettingsService _settingsService = SettingsService();

  // Products & Categories
  List<Product> _products = [];
  bool _productsLoading = true;
  String? _catalogError;
  List<String> _categories = [];
  List<StoreCollection> _collections = const [];
  /// Product.category value: Men | Women | '' (all)
  String _activeDepartment = '';
  String _searchQuery = '';
  bool _showSearch = false;

  bool _showMenuDrawer = false;
  bool _showCartDrawer = false;
  bool _showProfileDrawer = false;

  // Store Settings
  double _flatShippingRate = 1.5;
  double _freeShippingThreshold = 30.0;
  bool _marqueeEnabled = true;
  List<String> _marqueeMessages = const [
    'NEW ARRIVALS EVERY WEEK',
    'Open 7:00 AM – 5:00 PM  ·  បើកពីម៉ោង ៧:០០ ព្រឹក ដល់ ៥:០០ ល្ងាច',
  ];
  Map<String, dynamic> _storeSettings = {};

  // Cart: Map<itemId, Map<size, int>>
  Map<String, Map<String, int>> _cartItems = {};
  bool _cartReady = false;

  // Wishlist: Set of product IDs
  final Set<String> _wishlist = {};

  // Auth & Profile
  String? _token;
  UserProfile? _userProfile;
  bool _isAuthLoading = false;

  // Saved Addresses
  List<Address> _addresses = [];

  // Getters
  List<Product> get products => _products;
  bool get productsLoading => _productsLoading;
  String? get catalogError => _catalogError;
  List<String> get categories => _categories;
  List<StoreCollection> get collections => _collections;
  String get activeDepartment => _activeDepartment;
  String get searchQuery => _searchQuery;
  bool get showSearch => _showSearch;
  bool get showMenuDrawer => _showMenuDrawer;
  bool get showCartDrawer => _showCartDrawer;
  bool get showProfileDrawer => _showProfileDrawer;
  Map<String, Map<String, int>> get cartItems => _cartItems;
  Set<String> get wishlist => _wishlist;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthLoading => _isAuthLoading;
  List<Address> get addresses => _addresses;
  double get flatShippingRate => _flatShippingRate;
  double get freeShippingThreshold => _freeShippingThreshold;
  bool get marqueeEnabled => _marqueeEnabled;
  List<String> get marqueeMessages => _marqueeMessages;
  Map<String, dynamic> get storeSettings => _storeSettings;

  // Initialization
  Future<void> initialize() async {
    await _api.initToken();
    _token = _api.token;

    await Future.wait([
      _loadStoredData(),
      refreshProducts(),
      _loadSettings(),
      _loadCategories(),
    ]);

    if (isLoggedIn) {
      await loadProfile();
      await syncUserCart();
    }
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    // Wishlist
    final storedWishlist = prefs.getStringList(AppConstants.wishlistKey);
    if (storedWishlist != null) {
      _wishlist.addAll(storedWishlist);
    }

    // Guest Cart
    final storedCartJson = prefs.getString(AppConstants.cartKey);
    if (storedCartJson != null) {
      try {
        final decoded = asJsonMap(jsonDecode(storedCartJson));
        _cartItems = decoded.map((key, value) {
          final sizeMap = Map<String, dynamic>.from(value as Map).map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          );
          return MapEntry(key, sizeMap);
        });
      } catch (_) {}
    }
    _cartReady = true;

    // Addresses
    final storedAddresses = prefs.getString(AppConstants.addressesKey);
    if (storedAddresses != null) {
      try {
        final list = jsonDecode(storedAddresses) as List;
        _addresses = list
            .whereType<Map>()
            .map((item) => Address.fromJson(asJsonMap(item)))
            .toList();
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> _persistCart() async {
    if (!_cartReady || isLoggedIn) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.cartKey, jsonEncode(_cartItems));
  }

  Future<void> _persistWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.wishlistKey, _wishlist.toList());
  }

  Future<void> _persistAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.addressesKey,
      jsonEncode(_addresses.map((a) => a.toJson()).toList()),
    );
  }

  // Department and Search
  void setActiveDepartment(String dept) {
    _activeDepartment = dept;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSearch() {
    _showSearch = !_showSearch;
    if (!_showSearch) _searchQuery = '';
    notifyListeners();
  }

  void setShowSearch(bool value) {
    _showSearch = value;
    if (!value) _searchQuery = '';
    notifyListeners();
  }

  void openMenuDrawer() {
    _showCartDrawer = false;
    _showProfileDrawer = false;
    _showMenuDrawer = true;
    notifyListeners();
  }

  void closeMenuDrawer() {
    _showMenuDrawer = false;
    notifyListeners();
  }

  void openCartDrawer() {
    _showMenuDrawer = false;
    _showProfileDrawer = false;
    _showCartDrawer = true;
    notifyListeners();
  }

  void closeCartDrawer() {
    _showCartDrawer = false;
    notifyListeners();
  }

  void openProfileDrawer() {
    _showMenuDrawer = false;
    _showCartDrawer = false;
    _showProfileDrawer = true;
    notifyListeners();
  }

  void closeProfileDrawer() {
    _showProfileDrawer = false;
    notifyListeners();
  }

  void closeAllDrawers() {
    _showMenuDrawer = false;
    _showCartDrawer = false;
    _showProfileDrawer = false;
    notifyListeners();
  }

  // Catalog
  Future<void> refreshAllCatalog() async {
    await Future.wait([
      refreshProducts(),
      _loadSettings(),
      _loadCategories(),
    ]);
  }

  Future<void> refreshProducts() async {
    _productsLoading = true;
    _catalogError = null;
    notifyListeners();
    try {
      _products = await _productService.getProducts();
    } catch (e) {
      _products = [];
      _catalogError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _productsLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    try {
      final res = await _settingsService.getPublicSettings();
      if (res['success'] == true && res['settings'] != null) {
        final s = Map<String, dynamic>.from(res['settings'] as Map);
        _storeSettings = s;
        final shipping = s['flatShippingRate'] ?? s['deliveryCharge'];
        if (shipping is num) {
          _flatShippingRate = shipping.toDouble();
        }
        final freeAt = s['freeShippingThreshold'] ?? s['freeDeliveryThreshold'];
        if (freeAt is num) {
          _freeShippingThreshold = freeAt.toDouble();
        }
        if (s['marqueeEnabled'] == false) {
          _marqueeEnabled = false;
        } else {
          _marqueeEnabled = true;
          final msgs = (s['marqueeMessages'] as List?)
                  ?.map((e) => e.toString().trim())
                  .where((e) => e.isNotEmpty)
                  .toList() ??
              [];
          if (msgs.isNotEmpty) {
            const hours = 'Open 7:00 AM – 5:00 PM  ·  បើកពីម៉ោង ៧:០០ ព្រឹក ដល់ ៥:០០ ល្ងាច';
            final hasHours = msgs.any((m) => m.contains('7:00') || m.contains('៧'));
            _marqueeMessages = hasHours ? msgs : [...msgs, hours];
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _loadCategories() async {
    try {
      final records = await _settingsService.getPublicCategories();
      _collections = records
          .where((c) => c.kind == 'collection' && c.showOnStorefront)
          .where((c) => c.slug != 'shoes' && c.slug != 'shoe')
          .toList()
        ..sort((a, b) {
          if (a.sortOrder != b.sortOrder) return a.sortOrder.compareTo(b.sortOrder);
          return a.name.compareTo(b.name);
        });
      _categories = records
          .where((c) => c.kind == 'department')
          .map((c) => c.name)
          .toList();
      if (_collections.isEmpty) {
        _collections = const [
          StoreCollection(id: 'all', name: 'All', slug: 'all', sortOrder: 1),
          StoreCollection(id: 'boxy', name: 'Boxy', slug: 'boxy', sortOrder: 2),
          StoreCollection(id: 'ls', name: 'Long Sleeve', slug: 'long sleeve', sortOrder: 3),
          StoreCollection(id: 'tops', name: 'Tops', slug: 'tops', sortOrder: 4),
          StoreCollection(id: 'bags', name: 'Bags', slug: 'bags', sortOrder: 5),
        ];
      }
      notifyListeners();
    } catch (_) {}
  }

  Product? findProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Wishlist
  bool isInWishlist(String productId) => _wishlist.contains(productId);

  void toggleWishlist(String productId) {
    if (_wishlist.contains(productId)) {
      _wishlist.remove(productId);
    } else {
      _wishlist.add(productId);
    }
    _persistWishlist();
    notifyListeners();
  }

  // Cart Operations
  Future<String?> addToCart(String productId, String size) async {
    if (size.isEmpty) return 'Please select a size';

    final product = findProductById(productId);
    if (product != null && !product.isAvailableInSize(size)) {
      return 'Selected size is sold out';
    }

    if (!_cartItems.containsKey(productId)) {
      _cartItems[productId] = {};
    }
    _cartItems[productId]![size] = (_cartItems[productId]![size] ?? 0) + 1;

    notifyListeners();
    _persistCart();

    if (isLoggedIn) {
      try {
        await _cartService.addToCart(productId, size);
      } catch (e) {
        return e.toString();
      }
    }
    return null; // Success
  }

  Future<void> updateQuantity(String productId, String size, int quantity) async {
    if (!_cartItems.containsKey(productId)) return;

    if (quantity <= 0) {
      _cartItems[productId]!.remove(size);
      if (_cartItems[productId]!.isEmpty) {
        _cartItems.remove(productId);
      }
    } else {
      _cartItems[productId]![size] = quantity;
    }

    notifyListeners();
    _persistCart();

    if (isLoggedIn) {
      try {
        await _cartService.updateCart(productId, size, quantity);
      } catch (_) {}
    }
  }

  void clearCart() {
    _cartItems.clear();
    _persistCart();
    notifyListeners();
  }

  int getCartCount() {
    int count = 0;
    _cartItems.forEach((_, sizes) {
      sizes.forEach((_, qty) {
        if (qty > 0) count += qty;
      });
    });
    return count;
  }

  double getCartAmount() {
    double total = 0.0;
    _cartItems.forEach((productId, sizes) {
      final product = findProductById(productId);
      if (product != null) {
        sizes.forEach((_, qty) {
          if (qty > 0) total += product.price * qty;
        });
      }
    });
    return total;
  }

  double getShippingFee([double? customSubtotal]) {
    final subtotal = customSubtotal ?? getCartAmount();
    if (subtotal >= _freeShippingThreshold || subtotal == 0) {
      return 0.0;
    }
    return _flatShippingRate;
  }

  List<CartItem> getCartItemModels() {
    final List<CartItem> items = [];
    _cartItems.forEach((productId, sizes) {
      final product = findProductById(productId);
      sizes.forEach((size, qty) {
        if (qty > 0) {
          items.add(CartItem(
            productId: productId,
            size: size,
            quantity: qty,
            product: product,
          ));
        }
      });
    });
    return items;
  }

  // Remote Cart Sync on Login
  Future<void> syncUserCart() async {
    if (!isLoggedIn) return;
    try {
      final res = await _cartService.fetchCart();
      if (res['success'] == true && res['cartData'] is Map) {
        final remoteCart = asJsonMap(res['cartData']);
        remoteCart.forEach((itemId, sizeMap) {
          if (!_cartItems.containsKey(itemId)) {
            _cartItems[itemId] = {};
          }
          if (sizeMap is Map) {
            sizeMap.forEach((size, qty) {
              final intQty = (qty as num).toInt();
              _cartItems[itemId]![size.toString()] = intQty;
            });
          }
        });
        notifyListeners();
      }
    } catch (_) {}
  }

  // Auth Operations
  Future<void> login(String email, String password) async {
    _isAuthLoading = true;
    notifyListeners();
    try {
      final res = await _authService.login(email, password);
      if (res['success'] == true && res['token'] != null) {
        _token = res['token'].toString();
        await _api.setToken(_token);
        await loadProfile();
        await syncUserCart();
      } else {
        throw Exception(res['message'] ?? 'Login failed');
      }
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isAuthLoading = true;
    notifyListeners();
    try {
      final res = await _authService.register(name, email, password);
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Registration failed');
      }
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyRegisterOtp(String email, String code) async {
    _isAuthLoading = true;
    notifyListeners();
    try {
      final res = await _authService.verifyRegisterOtp(email, code);
      if (res['success'] == true && res['token'] != null) {
        _token = res['token'].toString();
        await _api.setToken(_token);
        await loadProfile();
      } else {
        throw Exception(res['message'] ?? 'Verification failed');
      }
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    if (!isLoggedIn) return;
    try {
      final res = await _authService.getProfile();
      if (res['success'] == true && res['user'] != null) {
        _userProfile = UserProfile.fromJson(asJsonMap(res['user']));
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    _token = null;
    _userProfile = null;
    await _api.setToken(null);
    clearCart();
    notifyListeners();
  }

  // Address Operations
  void addAddress(Address address) {
    if (address.isDefault) {
      _addresses = _addresses.map((a) => Address(
        id: a.id,
        firstName: a.firstName,
        lastName: a.lastName,
        email: a.email,
        phone: a.phone,
        street: a.street,
        city: a.city,
        state: a.state,
        country: a.country,
        zipcode: a.zipcode,
        isDefault: false,
      )).toList();
    }
    _addresses.insert(0, address);
    _persistAddresses();
    notifyListeners();
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    _persistAddresses();
    notifyListeners();
  }
}
