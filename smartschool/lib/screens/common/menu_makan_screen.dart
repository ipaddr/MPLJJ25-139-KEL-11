import 'package:flutter/material.dart';
import 'package:smartschool/services/api_service.dart';
import 'package:smartschool/models/menu_model.dart';
import 'package:smartschool/utils/app_constants.dart';
// import 'package:smartschool/auth/auth_repository.dart'; // Untuk cek role
import 'package:smartschool/models/user_model.dart'; // Untuk user model
import 'package:smartschool/screens/widgets/custom_text_field.dart'; // <<<--- Tambahkan ini

class MenuMakanScreen extends StatefulWidget {
  const MenuMakanScreen({super.key});

  @override
  State<MenuMakanScreen> createState() => _MenuMakanScreenState();
}

class _MenuMakanScreenState extends State<MenuMakanScreen> {
  final ApiService _apiService = ApiService();
  MenuModel? _dailyMenu;
  bool _isLoading = true;
  String? _errorMessage;
  UserModel? _currentUser; // Untuk menyimpan user yang login

  @override
  void initState() {
    super.initState();
    _checkUserRoleAndFetchMenu();
  }

  Future<void> _checkUserRoleAndFetchMenu() async {
    _currentUser = await _apiService.getCurrentUserData();
    await _fetchDailyMenu();
  }

  Future<void> _fetchDailyMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _dailyMenu = await _apiService.getDailyMenu(DateTime.now());
      if (_dailyMenu == null) {
        _errorMessage = "Belum ada menu makan siang untuk hari ini.";
      }
    } catch (e) {
      _errorMessage = "Gagal mengambil menu: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = _currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Makan Siang'), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700], fontSize: 16),
                  ),
                ),
              )
              : _dailyMenu == null || _dailyMenu!.menuItems.isEmpty
              ? Center(
                child: Text(
                  'Tidak ada menu tersedia untuk hari ini.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _dailyMenu!.menuItems.length,
                itemBuilder: (context, index) {
                  final item = _dailyMenu!.menuItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: AppConstants.darkBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kalori: ${item.calories} kkal',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton:
          isAdmin
              ? FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              EditMenuMakanScreen(currentMenu: _dailyMenu),
                    ),
                  );
                  if (result == true) {
                    _fetchDailyMenu(); // Refresh menu jika ada perubahan
                  }
                },
                child: const Icon(Icons.edit),
              )
              : null, // Sembunyikan FAB jika bukan admin
    );
  }
}

// --- NEW SCREEN FOR ADMIN TO EDIT MENU ---
class EditMenuMakanScreen extends StatefulWidget {
  final MenuModel? currentMenu;
  const EditMenuMakanScreen({super.key, this.currentMenu});

  @override
  State<EditMenuMakanScreen> createState() => _EditMenuMakanScreenState();
}

class _EditMenuMakanScreenState extends State<EditMenuMakanScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(
      widget.currentMenu?.date ?? DateTime.now(),
    );
    if (widget.currentMenu != null) {
      _menuItems = List.from(widget.currentMenu!.menuItems);
    } else {
      _menuItems.add(MenuItem(name: '', description: '', calories: 0));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.currentMenu?.date ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = _formatDate(pickedDate);
      });
    }
  }

  void _addMenuItemField() {
    setState(() {
      _menuItems.add(MenuItem(name: '', description: '', calories: 0));
    });
  }

  void _removeMenuItemField(int index) {
    setState(() {
      _menuItems.removeAt(index);
    });
  }

  Future<void> _saveMenu() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        DateTime selectedDate = DateTime(
          int.parse(_dateController.text.substring(6, 10)),
          int.parse(_dateController.text.substring(3, 5)),
          int.parse(_dateController.text.substring(0, 2)),
        );

        MenuModel newMenu = MenuModel(
          id: _dateController.text.replaceAll('/', '-'), // Simplified ID
          date: selectedDate,
          menuItems: _menuItems,
        );

        await _apiService.setDailyMenu(newMenu);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Menu makan siang berhasil disimpan!'),
            ),
          );
          Navigator.pop(context, true); // Kembali dan beri sinyal refresh
        }
      } catch (e) {
        print('Error saving menu: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menyimpan menu: $e')));
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.currentMenu == null
              ? 'Tambah Menu Baru'
              : 'Edit Menu Makan Siang',
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        // Mencegah keyboard muncul saat tap
                        child: CustomTextField(
                          controller: _dateController,
                          labelText: 'Tanggal Menu',
                          prefixIcon: Icons.calendar_today,
                          enabled: true, // Biarkan enabled agar bisa diklik
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Daftar Item Menu:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppConstants.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                CustomTextField(
                                  controller: TextEditingController(
                                    text: _menuItems[index].name,
                                  ),
                                  labelText: 'Nama Item',
                                  hintText: 'Misal: Nasi Goreng',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nama item tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _menuItems[index] = MenuItem(
                                      name: value,
                                      description:
                                          _menuItems[index].description,
                                      calories: _menuItems[index].calories,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: TextEditingController(
                                    text: _menuItems[index].description,
                                  ),
                                  labelText: 'Deskripsi',
                                  hintText: 'Misal: Dengan telur dan kerupuk',
                                  maxLines: 2,
                                  onChanged: (value) {
                                    _menuItems[index] = MenuItem(
                                      name: _menuItems[index].name,
                                      description: value,
                                      calories: _menuItems[index].calories,
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                CustomTextField(
                                  controller: TextEditingController(
                                    text: _menuItems[index].calories.toString(),
                                  ),
                                  labelText: 'Kalori (kkal)',
                                  hintText: 'Misal: 450',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        int.tryParse(value) == null) {
                                      return 'Kalori harus angka';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _menuItems[index] = MenuItem(
                                      name: _menuItems[index].name,
                                      description:
                                          _menuItems[index].description,
                                      calories: int.tryParse(value) ?? 0,
                                    );
                                  },
                                ),
                                if (_menuItems.length >
                                    1) // Jangan izinkan hapus jika hanya satu item
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed:
                                          () => _removeMenuItemField(index),
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      label: const Text('Hapus Item'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _addMenuItemField,
                        icon: const Icon(
                          Icons.add_circle,
                          color: AppConstants.accentBlue,
                        ),
                        label: const Text('Tambah Item Menu'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveMenu,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Simpan Menu',
                                style: TextStyle(fontSize: 18),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
