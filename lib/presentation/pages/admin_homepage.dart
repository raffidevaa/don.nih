import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/menu_datasource.dart';
import '../../data/datasources/storage_datasource.dart';
import '../../data/models/menu_model.dart';
import 'package:donnih/presentation/widgets/admin_page_nav.dart';
import 'admin_add_menu_page.dart';
import 'admin_menu_detail_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String? _fullName;

  late final MenuDataSource _menuDataSource;
  late final StorageDatasource _storageDataSource;

  List<MenuModel> _menus = [];
  final Map<int, String?> _menuImages = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _menuDataSource = MenuDataSource(Supabase.instance.client);
    _storageDataSource = StorageDatasource();
    _fetchUserData();
    _fetchMenus();
  }

  void _fetchUserData() async {
    try {
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser == null) {
        setState(() => _fullName = "Admin");
        return;
      }

      final profile = await Supabase.instance.client
          .from("users")
          .select()
          .eq("id", authUser.id)
          .maybeSingle();

      if (profile == null) {
        setState(() => _fullName = "Admin");
        return;
      }
      if (!mounted) return;
      setState(() {
        _fullName = profile["fullname"] ?? "Admin";
      });
    } catch (e) {
      setState(() => _fullName = "Admin");
    }
  }

  Future<void> _fetchMenus() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final menus = await _menuDataSource.getAllMenu();
      _menus = menus;

      // Fetch images for each menu
      for (var menu in menus) {
        try {
          final url = _storageDataSource.getImageUrl(
            id: menu.id.toString(),
            folderName: "menu",
            fileType: "png",
          );
          _menuImages[menu.id] = url;
        } catch (_) {
          _menuImages[menu.id] = null;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<MenuModel> get _filteredMenus {
    // Get unique menus by name
    final Map<String, MenuModel> uniqueMenus = {};
    for (var menu in _menus) {
      if (!uniqueMenus.containsKey(menu.name)) {
        uniqueMenus[menu.name] = menu;
      }
    }

    // Filter by search
    if (_search.isEmpty) {
      return uniqueMenus.values.toList();
    }
    
    return uniqueMenus.values
        .where((m) => m.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  Future<void> _navigateToDetail(MenuModel menu) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminMenuDetailPage(menu: menu),
      ),
    );
    _fetchMenus();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/admin/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/admin/orders');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 35, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  Text(
                    'Welcome, ${_fullName ?? "Admin"}!',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFCB8A58),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _search = v),
                      decoration: const InputDecoration(
                        hintText: 'Search menu...',
                        hintStyle: TextStyle(
                          color: Color(0xFFCBCBD4),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFFCB8A58),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Add Menu Button
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFCB8A58),
                            Color(0xFF562B1A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminAddMenuPage(),
                            ),
                          );
                          _fetchMenus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Add Menu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Menu Grid
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(
                                  child: Text(
                                    'Error: $_error',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                )
                              : GridView.builder(
                                  itemCount: _filteredMenus.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 22,
                                    mainAxisSpacing: 22,
                                    childAspectRatio: 0.8,
                                  ),
                                  itemBuilder: (context, index) {
                                    final menu = _filteredMenus[index];
                                    final imageUrl = _menuImages[menu.id];

                                    return GestureDetector(
                                      onTap: () => _navigateToDetail(menu),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: const Color(0xFFCB8A58),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Image
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: imageUrl != null
                                                    ? Image.network(
                                                        imageUrl,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (_, __, ___) =>
                                                                const Center(
                                                          child: Icon(
                                                            Icons.fastfood,
                                                            size: 48,
                                                            color: Color(
                                                                0xFFCB8A58),
                                                          ),
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        'assets/images/caffelatte.png',
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            // Menu Info
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    menu.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    'Rp${menu.price.toInt()}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminPageNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
