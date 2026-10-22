import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CartScreen(),
    ));

// 1. CartItem Class
class CartItem {
  String name;
  double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

// 2. Main Screen (StatefulWidget)
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // List sa mga items ug controllers
  final List<CartItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Preload 3 sample items
  @override
  void initState() {
    super.initState();
    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(name: 'Eggs', price: 8.00, quantity: 12),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  // Dispose controllers
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Total Calculator
  double get _total {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  // Actions (Tanan naa sa setState)
  void _increase(int index) {
    setState(() {
      if (_items[index].quantity < 99) {
        _items[index].quantity++;
      }
    });
  }

  void _decrease(int index) {
    setState(() {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      }
    });
  }

  void _toggle(int index) {
    setState(() {
      _items[index].gotIt = !_items[index].gotIt;
    });
  }

  void _clearChecked() {
    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });
  }

  // Add Item with Validation
  void _addItem() {
    String name = _nameController.text.trim();
    double? price = double.tryParse(_priceController.text);

    if (name.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid name and a price greater than 0.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _items.add(CartItem(name: name, price: price));
      _nameController.clear();
      _priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mini Shopping Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Giusab nako ni gikan sa Teal ngadto sa BlueGrey aron naay ika-3 nga commit
        backgroundColor: Colors.blueGrey, 
      ),
      body: SafeArea(
        child: Column(
          children: [
            // List sa mga Items
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return CartItemTile(
                    item: _items[index],
                    onIncrease: () => _increase(index),
                    onDecrease: () => _decrease(index),
                    onToggle: () => _toggle(index),
                  );
                },
              ),
            ),

            // Summary Bar (Live Update)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items: ${_items.length}  |  Got it: ${_items.where((i) => i.gotIt).length}',
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Total: PHP ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),

            // Form sa ubos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Item name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: const Text('Add'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearChecked,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          child: const Text('Clear checked'),
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
    );
  }
}

// 3. StatelessWidget para sa matag Item
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: item.gotIt,
              activeColor: Colors.teal,
              onChanged: (_) => onToggle(),
            ),

            // Name ug Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      decoration: item.gotIt ? TextDecoration.lineThrough : null,
                      color: item.gotIt ? Colors.grey : Colors.black87,
                    ),
                  ),
                  Text(
                    'PHP ${item.price.toStringAsFixed(2)} each',
                    style: const TextStyle(fontSize: 12.0, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Minus Button
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.teal),
              onPressed: onDecrease,
            ),

            // Quantity
            Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),

            // Plus Button
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
              onPressed: onIncrease,
            ),
          ],
        ),
      ),
    );
  }
}