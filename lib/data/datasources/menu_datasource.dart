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
}
