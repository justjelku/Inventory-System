import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shoes_inventory_ms/database/productsearchservice.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ListTile> _searchResults = [];
  String _scanBarcodes = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          style: const TextStyle(
            color: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              _searchResults.clear();
            });
          },
          onSubmitted: (value) {
            _search();
          },
        ),
      ),
      body: ListView(
        children: _searchResults,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scanBarcode();
        },
        child: const Icon(Icons.qr_code),
      ),
    );
  }

  void _search() async {
    final user = FirebaseAuth.instance.currentUser;
    String searchQuery = _searchController.text.trim();

    var results =
    await ProductSearchService().searchById(user!.uid, searchQuery);

    setState(() {
      _searchResults = results.docs.map((doc) {
        return ListTile(
          title: Text(doc['productTitle']),
          subtitle: Text(doc['productDetails']),
          onTap: () {
            // Navigate to the product details page using the product ID
          },
        );
      }).toList();
      if (_searchResults.isEmpty) {
        _searchResults.add(const ListTile(
          title: Text('No products found.'),
        ));
      }
    });
  }

  void _scanBarcode() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // Search for product details using the scanned barcode ID
    final user = FirebaseAuth.instance.currentUser;
    var results =
        await ProductSearchService().searchByBarcodeId(user!.uid, barcodeScanRes);

    setState(() {
      _searchResults = results.docs.map((doc) {
        return ListTile(
          title: Text(doc['productTitle']),
          subtitle: Text(doc['productDetails']),
          onTap: () {
            // Navigate to the product details page using the product ID
          },
        );
      }).toList();
      if (_searchResults.isEmpty) {
        _searchResults.add(const ListTile(
          title: Text('No products found.'),
        ));
      }
    });
  }
}
