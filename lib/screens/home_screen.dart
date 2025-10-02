import 'package:flutter/material.dart';
import '../components/add-waste-product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _products = [];

  void _addProduct(String name, double quantity) {
    setState(() {
      _products.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': name,
        'quantity': quantity,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Tracker'),
      ),
      body: _products.isEmpty
          ? const Center(child: Text('No products added yet'))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(product['name']),
                    subtitle: Text('${product['quantity']} kg'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddWasteProductScreen(
                onAddProduct: _addProduct,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}