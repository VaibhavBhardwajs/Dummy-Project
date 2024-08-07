import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'productdetailpage.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> fetchProducts() async {
    if (isLoading || !hasMore) return;
    setState(() {
      isLoading = true;
    });

    try {
      String url = 'https://dummyjson.com/products?skip=${(page - 1) * 20}&limit=20';
      if (searchQuery.isNotEmpty) {
        url = 'https://dummyjson.com/products/search?q=$searchQuery&skip=${(page - 1) * 20}&limit=20';
      }

      print('Fetching products from page $page with query "$searchQuery"...');
      final response = await http.get(Uri.parse(url));
      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> newProducts = data['products'];
        print('Fetched ${newProducts.length} products.');

        if (newProducts.isNotEmpty) {
          setState(() {
            if (page == 1) {
              products = newProducts; // Reset list if new search
            } else {
              products.addAll(newProducts);
            }
            filteredProducts = products; // Update filtered list with new data
            page++;
          });
        } else {
          setState(() {
            hasMore = false; // No more products to load
          });
        }
      } else {
        print('Failed to load products. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text;
      page = 1;
      products.clear();
      filteredProducts.clear();
      hasMore = true;
    });
    fetchProducts(); // Trigger a new fetch with the search query
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Products List'),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            fetchProducts();
            return true;
          }
          return false;
        },
        child: filteredProducts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: filteredProducts.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Products List',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              );
            }

            if (index == filteredProducts.length) {
              return hasMore
                  ? const Center(child: CircularProgressIndicator())
                  : const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No more products'),
              );
            }

            final product = filteredProducts[index - 1];
            return Card(
              child: ListTile(
                leading: Icon(Icons.image, size: 50), // Placeholder for image
                title: Text(product['title']),
                subtitle: Text(product['description']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
