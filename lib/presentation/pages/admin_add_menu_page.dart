import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAddMenuPage extends StatefulWidget {
  const AdminAddMenuPage({super.key});

  @override
  State<AdminAddMenuPage> createState() => _AdminAddMenuPageState();
}

class _AdminAddMenuPageState extends State<AdminAddMenuPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final SupabaseClient supabase = Supabase.instance.client;

  XFile? _selectedImage;
  bool _isLoading = false;

  // =========================
  // PICK IMAGE (WEB + MOBILE)
  // =========================
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // =========================
  // SAVE MENU + UPLOAD IMAGE
  // =========================
  Future<void> _saveMenu() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama & harga wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ INSERT MENU (tanpa img dulu)
      final inserted = await supabase
          .from('menus')
          .insert({
            'name': _nameController.text,
            'price': double.parse(_priceController.text),
          })
          .select()
          .single();

      final int menuId = inserted['id'];

      // 2️⃣ UPLOAD IMAGE (JIKA ADA)
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final ext = _selectedImage!.name.split('.').last.toLowerCase();

        // 🔥 PATH KONSISTEN
        final filePath = 'menu/${menuId}_menu.$ext';

        // 1️⃣ UPLOAD
        await supabase.storage
            .from('menu') // BUCKET NAME
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
            );

        // 2️⃣ SIMPAN PATH KE DB (BUKAN URL)
        await supabase.from('menus').update({'img': filePath}).eq('id', menuId);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu berhasil ditambahkan')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// IMAGE AREA
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 420,
            child: Container(
              color: const Color(0xFFB29F91),
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF846046),
                      shape: BoxShape.circle,
                    ),
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.network(
                              _selectedImage!.path,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 40,
                          ),
                  ),
                ),
              ),
            ),
          ),

          /// TOP BAR
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Color(0xFF846046)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF846046),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ),

          /// FORM
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter menu name',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Price',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter price',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
