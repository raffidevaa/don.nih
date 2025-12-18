import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/menu_model.dart';
import '../../data/datasources/storage_datasource.dart';
import '../../data/datasources/topping_datasource.dart';
import '../../data/models/topping_model.dart';

class AdminMenuDetailPage extends StatefulWidget {
  final MenuModel menu;
  const AdminMenuDetailPage({super.key, required this.menu});

  @override
  State<AdminMenuDetailPage> createState() => _AdminMenuDetailPageState();
}

class _AdminMenuDetailPageState extends State<AdminMenuDetailPage> {
  bool _isEditMode = false;
  late StorageDatasource _storageDataSource;
  late ToppingDataSource _toppingDataSource;
  String? _imageUrl;

  // Data for editing
  List<String> _sizeOptions = [];
  List<String> _temperatureOptions = [];
  List<ToppingModel> _toppings = [];
  bool _isLoadingData = true;

  int _selectedSizeIndex = 0;
  int _selectedTemperatureIndex = 0;

  // Excluded topping IDs for size & temperature (same as user side)
  final Set<int> excludedToppingIds = {9, 10, 11, 12};
  
  // Mapping label → topping id
  final Map<String, int> sizeToId = {'Regular': 11, 'Large': 9};
  final Map<String, int> tempToId = {'Cold': 10, 'Hot': 12};
  
  // Price lookup for size & temp
  final Map<int, double> sizeTempPrice = {};

  @override
  void initState() {
    super.initState();
    _storageDataSource = StorageDatasource();
    _toppingDataSource = ToppingDataSource(Supabase.instance.client);
    _loadImage();
    _loadData();
  }

  void _loadImage() {
    try {
      final url = _storageDataSource.getImageUrl(
        id: widget.menu.id.toString(),
        folderName: "menu",
        fileType: "png",
      );
      setState(() => _imageUrl = url);
    } catch (_) {
      _imageUrl = null;
    }
  }

  Future<void> _loadData() async {
    try {
      // Fetch toppings (exclude size & temp) - same as user side
      final exclude = excludedToppingIds.join(',');
      final toppingResp = await Supabase.instance.client
          .from('toppings')
          .select('*')
          .not('id', 'in', '($exclude)');

      final toppings = (toppingResp as List)
          .map((e) => ToppingModel.fromMap(e))
          .toList();

      // Fetch size & temp prices
      final sizeTempResp = await Supabase.instance.client
          .from('toppings')
          .select('id, name, price')
          .inFilter('id', excludedToppingIds.toList());

      // Build size and temperature options from database
      List<String> sizes = [];
      List<String> temps = [];
      
      for (var r in sizeTempResp) {
        final id = r['id'] as int;
        final name = r['name'] as String;
        final price = (r['price'] as num).toDouble();
        
        sizeTempPrice[id] = price;
        
        // Remove "Size - " and "Temperature - " prefix
        String cleanName = name
            .replaceAll('Size - ', '')
            .replaceAll('Temperature - ', '');
        
        // Size IDs: 9 (Large), 11 (Regular)
        if (id == 9 || id == 11) {
          sizes.add(cleanName);
        }
        // Temp IDs: 10 (Cold), 12 (Hot)
        else if (id == 10 || id == 12) {
          temps.add(cleanName);
        }
      }
      
      // Sort to ensure Regular before Large, Cold before Hot
      sizes.sort((a, b) {
        if (a.toLowerCase().contains('regular')) return -1;
        if (b.toLowerCase().contains('regular')) return 1;
        return 0;
      });
      
      temps.sort((a, b) {
        if (a.toLowerCase().contains('cold')) return -1;
        if (b.toLowerCase().contains('cold')) return 1;
        return 0;
      });
      
      setState(() {
        _toppings = toppings;
        _sizeOptions = sizes;
        _temperatureOptions = temps;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _saveChanges() {
    // TODO: Implement save functionality
    _toggleEditMode();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved!')),
    );
  }

  void _addSizeOption() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Size Option'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter size name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _sizeOptions.insert(0, controller.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTemperatureOption() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Temperature Option'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter temperature'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _temperatureOptions.insert(0, controller.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTopping() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Topping'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Topping name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                Navigator.pop(context);
                
                // Show loading
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Adding topping...')),
                  );
                }
                
                try {
                  // Save to database
                  await _toppingDataSource.createTopping(
                    nameController.text,
                    int.parse(priceController.text),
                  );
                  
                  // Refresh data from database
                  await _loadData();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Topping added successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add topping: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editItem(String type, int index) {
    final controller = TextEditingController();
    
    if (type == 'size') {
      controller.text = _sizeOptions[index];
    } else if (type == 'temperature') {
      controller.text = _temperatureOptions[index];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${type.substring(0, 1).toUpperCase()}${type.substring(1)}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Edit name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  if (type == 'size') {
                    _sizeOptions[index] = controller.text;
                  } else if (type == 'temperature') {
                    _temperatureOptions[index] = controller.text;
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editTopping(int index) {
    final nameController = TextEditingController(text: _toppings[index].name);
    final priceController = TextEditingController(text: _toppings[index].price.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Topping'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Topping name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                Navigator.pop(context);
                
                // Show loading
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Updating topping...')),
                  );
                }
                
                try {
                  // Update in database
                  await _toppingDataSource.updateTopping(
                    _toppings[index].id,
                    nameController.text,
                    int.parse(priceController.text),
                  );
                  
                  // Refresh data from database
                  await _loadData();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Topping updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update topping: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                // Image Header with shadow overlay
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 402,
                      decoration: BoxDecoration(
                        image: _imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: _imageUrl == null ? const Color(0xFFF2F2F2) : null,
                      ),
                      child: _imageUrl == null
                          ? const Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 80,
                                color: Color(0xFFCB8A58),
                              ),
                            )
                          : null,
                    ),
                    // Shadow overlay
                    Container(
                      width: double.infinity,
                      height: 402,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Content Container
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -78, 0),
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Menu Name
                      Text(
                        widget.menu.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF422110),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // About Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Espresso, Steamed Milk, and Frothed Milk.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Size Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: List.generate(
                                _sizeOptions.length,
                                (index) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: index < _sizeOptions.length - 1 ? 15 : 0,
                                    ),
                                    child: GestureDetector(
                                      onTap: _isEditMode
                                          ? () => _editItem('size', index)
                                          : () => setState(() => _selectedSizeIndex = index),
                                      child: Container(
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: _selectedSizeIndex == index
                                              ? const Color(0xFF846046)
                                              : Colors.white,
                                          border: Border.all(
                                            color: const Color(0xFF846046),
                                            width: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _sizeOptions[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: _selectedSizeIndex == index
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                              color: _selectedSizeIndex == index
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_isEditMode)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: GestureDetector(
                                onTap: _addSizeOption,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF846046),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Temperature Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Temperature',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: List.generate(
                                    _temperatureOptions.length,
                                    (index) => Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: index < _temperatureOptions.length - 1 ? 15 : 0,
                                        ),
                                        child: GestureDetector(
                                          onTap: _isEditMode
                                              ? () => _editItem('temperature', index)
                                              : () => setState(() => _selectedTemperatureIndex = index),
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: _selectedTemperatureIndex == index
                                                  ? const Color(0xFF846046)
                                                  : Colors.white,
                                              border: Border.all(
                                                color: const Color(0xFF846046),
                                                width: 0.5,
                                              ),
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _temperatureOptions[index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: _selectedTemperatureIndex == index
                                                      ? FontWeight.w500
                                                      : FontWeight.normal,
                                                  color: _selectedTemperatureIndex == index
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_isEditMode)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: GestureDetector(
                                    onTap: _addTemperatureOption,
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF846046),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Toppings Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Toppings',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (_isEditMode)
                                GestureDetector(
                                  onTap: _addTopping,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF846046),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          
                          // Toppings List
                          Column(
                            children: List.generate(
                              _toppings.length,
                              (index) => Column(
                                children: [
                                  GestureDetector(
                                    onTap: _isEditMode
                                        ? () => _editTopping(index)
                                        : null,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _toppings[index].name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Rp${_toppings[index].price}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index < _toppings.length - 1)
                                    const Divider(
                                      color: Color(0xFF422110),
                                      thickness: 1,
                                      height: 1,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF422110),
                          size: 20,
                        ),
                      ),
                    ),
                    
                    // Edit/Save Button
                    GestureDetector(
                      onTap: _isEditMode ? _saveChanges : _toggleEditMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 27,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF846046),
                          border: Border.all(
                            color: const Color(0xFF846046),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _isEditMode ? 'Save' : 'Edit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
