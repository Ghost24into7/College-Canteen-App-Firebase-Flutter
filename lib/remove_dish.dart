import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveDishPage extends StatelessWidget {
  const RemoveDishPage({super.key, Key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Dish'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _RemoveDishForm(),
            _DishList(),
          ],
        ),
      ),
    );
  }
}

class _RemoveDishForm extends StatefulWidget {
  @override
  _RemoveDishFormState createState() => _RemoveDishFormState();
}

class _RemoveDishFormState extends State<_RemoveDishForm> {
  final TextEditingController _dishNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _dishNameController,
            decoration: const InputDecoration(
              labelText: 'Dish Name',
              hintText: 'Enter the dish name to remove',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final dishName = _dishNameController.text.trim();
              if (dishName.isNotEmpty) {
                _deleteDishByName(context, dishName);
              }
            },
            child: const Text('Remove Dish'),
          ),
        ],
      ),
    );
  }

  void _deleteDishByName(BuildContext context, String dishName) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('dishes')
          .where('dishName', isEqualTo: dishName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance.collection('dishes').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dish removed successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dish not found!')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}

class _DishList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('dishes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final dishes = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            return ListTile(
              title: Text(dish['dishName']),
              subtitle: Text('Price: ₹${dish['price']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteDishById(context, dish.id),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteDishById(BuildContext context, String dishId) async {
    try {
      await FirebaseFirestore.instance.collection('dishes').doc(dishId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dish removed successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RemoveDishPage(),
  ));
}
