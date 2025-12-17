import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_model.dart';

class MenuDataSource {
  final SupabaseClient supabase;

  MenuDataSource(this.supabase);

  /// GET /menu
  Future<List<MenuModel>> getAllMenu() async {
    final response = await supabase.from('menus').select();

    return (response as List)
        .map((json) => MenuModel.fromJson(json))
        .toList();
  }

  /// GET /menu/:id
  Future<MenuModel?> getMenuById(int id) async {
    final response = await supabase
        .from('menus')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MenuModel.fromJson(response);
  }

  /// GET /menu?name=&size=
  Future<MenuModel?> getMenuByNameAndSize(String name, String size) async {
    final response = await supabase
        .from('menus')
        .select()
        .eq('name', name)
        .eq('size', size)
        .maybeSingle();

    if (response == null) return null;
    return MenuModel.fromJson(response);
  }

  /// ===============================
  /// TASK 29 — CREATE MENU (ADMIN)
  /// POST /menu
  /// ===============================
  Future<void> createMenu(MenuModel menu) async {
    await supabase.from('menus').insert(menu.toJson());
  }
  /// ===============================
  /// TASK 30 — UPDATE MENU (ADMIN)
  /// PUT /menu/:id
  /// ===============================
  Future<void> updateMenu(int id, MenuModel menu) async {
    await supabase
        .from('menus')
        .update(menu.toJson())
        .eq('id', id);
  }
    /// ===============================
  /// TASK 31 — DELETE MENU (ADMIN)
  /// DELETE /menu/:id
  /// ===============================
  Future<void> deleteMenu(int id) async {
    await supabase
        .from('menus')
        .delete()
        .eq('id', id);
  }
}