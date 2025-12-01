import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_model.dart';

class MenuDataSource {
  final SupabaseClient supabase;

  MenuDataSource(this.supabase);

  /// GET /api/menu - Get all menus
  /// Menggunakan Supabase CRUD bawaan (bukan edge function)
  Future<List<MenuModel>> getAllMenu() async {
    final response = await supabase.from('menus').select();

    final List<MenuModel> menus = (response as List)
        .map((json) => MenuModel.fromJson(json))
        .toList();

    return menus;
  }

  /// Get menu by ID
  Future<MenuModel?> getMenuById(int id) async {
    final response = await supabase
        .from('menus')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MenuModel.fromJson(response);
  }

  /// Get menu by name and size
  /// Untuk fetch harga berdasarkan size yang dipilih
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
}
