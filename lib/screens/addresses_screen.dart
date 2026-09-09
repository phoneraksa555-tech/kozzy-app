import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/address.dart';
import '../providers/shop_provider.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  void _showAddAddressDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final fNameCtrl = TextEditingController();
    final lNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final cityCtrl = TextEditingController(text: 'Phnom Penh');
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Address',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: fNameCtrl,
                              decoration: const InputDecoration(labelText: 'First Name *'),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: lNameCtrl,
                              decoration: const InputDecoration(labelText: 'Last Name *'),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone Number *'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: streetCtrl,
                        decoration: const InputDecoration(labelText: 'House / Street / Sangkat *'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cityCtrl,
                        decoration: const InputDecoration(labelText: 'City / Province *'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        value: isDefault,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Set as default delivery address'),
                        activeColor: AppConstants.brandBlack,
                        onChanged: (val) => setModalState(() => isDefault = val ?? false),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            final shop = ctx.read<ShopProvider>();
                            shop.addAddress(Address(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              firstName: fNameCtrl.text.trim(),
                              lastName: lNameCtrl.text.trim(),
                              email: shop.userProfile?.email ?? '',
                              phone: phoneCtrl.text.trim(),
                              street: streetCtrl.text.trim(),
                              city: cityCtrl.text.trim(),
                              state: cityCtrl.text.trim(),
                              isDefault: isDefault,
                            ));
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppConstants.brandBlack),
                          child: const Text('SAVE ADDRESS'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final addresses = shop.addresses;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      body: addresses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 56, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No Saved Addresses',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Save your shipping details for fast 1-click checkout.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppConstants.brandGray),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _showAddAddressDialog(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppConstants.brandBlack),
                      child: const Text('ADD ADDRESS'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final addr = addresses[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: addr.isDefault ? AppConstants.brandBlack : AppConstants.brandBorder,
                      width: addr.isDefault ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            addr.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (addr.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppConstants.brandBlack,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'DEFAULT',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(addr.formatted, style: const TextStyle(fontSize: 13, color: AppConstants.brandDark)),
                      const SizedBox(height: 4),
                      Text('Phone: ${addr.phone}', style: const TextStyle(fontSize: 12, color: AppConstants.brandGray)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => shop.deleteAddress(addr.id),
                            child: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressDialog(context),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
