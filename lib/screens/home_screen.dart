// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/first_aid.dart';
import '../widget/first_aid_card.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<FirstAid> items = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    setState(() => loading = true);
    items = await dbHelper.readAllFirstAids(query: searchQuery);
    setState(() => loading = false);
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditScreen()),
    );
    if (changed == true) _refreshList();
  }

  Future<void> _openEdit(FirstAid item) async {
    final changed = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditScreen(existing: item)),
    );
    if (changed == true) _refreshList();
  }

  Future<void> _deleteItem(int id) async {
    await dbHelper.deleteFirstAid(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Aid Quick Guide'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshList,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search title or description',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                    });
                    _refreshList();
                  },
                )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onSubmitted: (v) {
                setState(() => searchQuery = v.trim());
                _refreshList();
              },
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text('No entries yet. Tap + to add a first aid guide.'))
          : RefreshIndicator(
        onRefresh: _refreshList,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return FirstAidCard(
              item: item,
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailScreen(item: item)));
              },
              onEdit: () => _openEdit(item),
              onDelete: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete?'),
                    content: const Text('Are you sure you want to delete this guide?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
                    ],
                  ),
                );
                if (ok == true) _deleteItem(item.id!);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
