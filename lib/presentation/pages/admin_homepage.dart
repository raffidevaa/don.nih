import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/menu_datasource.dart';
import '../../data/models/menu_model.dart';
import 'package:donnih/presentation/widgets/admin_page_nav.dart';
import 'admin_add_menu_page.dart';
import 'admin_menu_detail_page.dart';

enum MenuAction { detail, edit }

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
    int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  late final MenuDataSource _menuDataSource;

  List<MenuModel> _menus = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _menuDataSource = MenuDataSource(Supabase.instance.client);
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final menus = await _menuDataSource.getAllMenu();

      setState(() {
        _menus = menus;
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
    return _menus
        .where(
          (m) => m.name.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
  }

  Future<void> _handleMenuAction(
    MenuAction action,
    MenuModel menu,
  ) async {
    switch (action) {
      case MenuAction.detail:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminMenuDetailPage(menu: menu),
          ),
        );
        break;

      case MenuAction.edit:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminAddMenuPage(menu: menu),
          ),
        );
        break;
    }

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Admin!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              /// SEARCH
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search menu...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// ADD MENU
              SizedBox(
                width: double.infinity,
                height: 48,
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
                  child: const Text('+ Add Menu'),
                ),
              ),

              const SizedBox(height: 20),

              /// MENU GRID
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!))
                        : GridView.builder(
                            itemCount: _filteredMenus.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                            itemBuilder: (context, index) {
                              final menu = _filteredMenus[index];

                              return GestureDetector(
                                onTap: () =>
                                    _handleMenuAction(MenuAction.detail, menu),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: Colors.brown.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.fastfood,
                                            size: 48,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              menu.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text('Rp${menu.price.toInt()}'),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _handleMenuAction(
                                            MenuAction.edit,
                                            menu,
                                          ),
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
      bottomNavigationBar: AdminPageNav(
      currentIndex: _currentIndex,
      onTap: _onNavTap,
      ),
    );
  }
}
