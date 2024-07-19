import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'list_item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListItemScreen(),
    );
  }
}

class ListItemScreen extends StatefulWidget {
  @override
  _ListItemScreenState createState() => _ListItemScreenState();
}

class _ListItemScreenState extends State<ListItemScreen> {
  late Future<List<ListItem>> _listItems;

  @override
  void initState() {
    super.initState();
    _refreshListItems();
  }

  void _refreshListItems() {
    setState(() {
      _listItems = DatabaseHelper.instance.getListItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.webp',
          height: 100,
        ),
      ),
      body: FutureBuilder<List<ListItem>>(
        future: _listItems,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              ListItem listItem = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(listItem.title),
                  subtitle: Text(listItem.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final updatedItem = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditListItemScreen(listItem: listItem)),
                          );
                          if (updatedItem != null) {
                            DatabaseHelper.instance.updateListItem(updatedItem);
                            _refreshListItems();
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          DatabaseHelper.instance.deleteListItem(listItem.id!);
                          _refreshListItems();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newListItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddListItemScreen()),
          );
          if (newListItem != null) {
            DatabaseHelper.instance.insertListItem(newListItem);
            _refreshListItems();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddListItemScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newListItem = ListItem(
                      title: _titleController.text,
                      description: _descriptionController.text,
                    );
                    Navigator.pop(context, newListItem);
                  }
                },
                child: Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditListItemScreen extends StatefulWidget {
  final ListItem listItem;

  EditListItemScreen({required this.listItem});

  @override
  _EditListItemScreenState createState() => _EditListItemScreenState();
}

class _EditListItemScreenState extends State<EditListItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.listItem.title;
    _descriptionController.text = widget.listItem.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedListItem = ListItem(
                      id: widget.listItem.id,
                      title: _titleController.text,
                      description: _descriptionController.text,
                    );
                    Navigator.pop(context, updatedListItem);
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
