import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/menu_model.dart';

class AdminAddMenuPage extends StatefulWidget {
  final MenuModel? menu;
  const AdminAddMenuPage({super.key, this.menu});

  @override
  State<AdminAddMenuPage> createState() => _AdminAddMenuPageState();
}

class _AdminAddMenuPageState extends State<AdminAddMenuPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  bool get isEdit => widget.menu != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.menu!.name;
      _priceController.text = widget.menu!.price.toInt().toString();
    }
  }

  Future<void> _saveMenu() async {
    final supabase = Supabase.instance.client;

    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama & harga wajib diisi')),
      );
      return;
    }

    final data = {
      'name': _nameController.text,
      'price': int.parse(_priceController.text),
    };

    if (isEdit) {
      await supabase
          .from('menus')
          .update(data)
          .eq('id', widget.menu!.id);
    } else {
      await supabase.from('menus').insert(data);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Menu' : 'Add Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Menu Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCB8A58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
