import 'package:flutter/material.dart';

import 'package:oxdo_sqflite/database_helper2.dart';
import 'package:oxdo_sqflite/person/person.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initializing database
  await DatabaseHelper2.initDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sqflite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Sqflite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _ageFocus = FocusNode();

  //final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Initialize person list
  List<Person> _personList = [];
  
  SaveButtonMode _saveButtonMode = SaveButtonMode.save;

  // Only for updating
  Person? _personToUpdate;

  @override
  void initState() {

    // Call all persons
    _getAllPersons();

    super.initState();
  }

  void _getAllPersons() async {
    _personList = await DatabaseHelper2.getAllPersons();
    setState(() {});
  }

  void _addPerson(Person person) async {
    await DatabaseHelper2.insertPerson(person);

    _ageController.clear();
    _nameController.clear();
    _unFocusAllFocusNode();

    _getAllPersons();
  }

  void _bringPersonToUpdata(Person person) {
    _personToUpdate = person;
    _nameController.text = person.name;
    _ageController.text = person.age.toString();
    _saveButtonMode = SaveButtonMode.edit;

    setState(() {});
  }

  // update
  void _updatePerson(Person person) async {
    await DatabaseHelper2.updatePerson(person);

    _ageController.clear();
    _nameController.clear();
    _saveButtonMode = SaveButtonMode.save;
    _personToUpdate = null;
    _unFocusAllFocusNode();

    _getAllPersons();
  }

  // delete
  void _deletePerson(int id) async {
    await DatabaseHelper2.deletePerson(id);
    _getAllPersons();
    _ageController.clear();
    _nameController.clear();
    _saveButtonMode = SaveButtonMode.save;
  }

  // un focus text fields,  hide keyboard
  void _unFocusAllFocusNode() {
    _nameFocusNode.unfocus();
    _ageFocus.unfocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();

    _nameFocusNode.dispose();
    _ageFocus.dispose();

    // Close database to free up resources
    DatabaseHelper2.closeDatabase();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Sqflite"),
      ),

      // body
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              // name field
              TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(
                height: 8,
              ),

              // age field
              TextField(
                controller: _ageController,
                focusNode: _ageFocus,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 8,
              ),

              // save or edit buttton
              ElevatedButton(
                onPressed: () {
                  
                  if (_saveButtonMode == SaveButtonMode.save) {

                    // To save
                    final personToSave = Person(
                      name: _nameController.text.trim(),
                      age: int.tryParse(_ageController.text.trim()) ?? 0,
                    );
                    _addPerson(personToSave);


                  } else {

                    // To update
                    final personToUpdate = Person(
                      id: _personToUpdate?.id,
                      name: _nameController.text.trim(),
                      age: int.tryParse(_ageController.text.trim()) ?? 0,
                    );

                    _updatePerson(personToUpdate);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saveButtonMode == SaveButtonMode.save
                      ? Colors.green
                      : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                    _saveButtonMode == SaveButtonMode.save ? "Save" : "Update"),
              ),
              const SizedBox(
                height: 8,
              ),

              // person list view
              Expanded(
                  child: ListView.separated(
                itemBuilder: (context, index) {
                  final person = _personList[index];

                  return Card(
                    child: ListTile(
                      title: Text("Name:- ${person.name}"),
                      subtitle: Text("Age:- ${person.age}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {

                              // take data to update
                              _bringPersonToUpdata(person);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {

                              // delete data
                              if (person.id != null) {
                                _deletePerson(person.id!);
                              }

                            },
                            color: Colors.red,
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: _personList.length,
              ))
            ],
          ),
        ),
      ),
    );
  }
}


enum SaveButtonMode { save, edit }










































// import 'package:flutter/material.dart';
// import 'package:oxdo_sqflite/database_helper.dart';
// import 'package:oxdo_sqflite/person/person.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sqflite',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Sqflite'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();

//   final _nameFocusNode = FocusNode();
//   final _ageFocus = FocusNode();

//   final DatabaseHelper _databaseHelper = DatabaseHelper();

//   List<Person> _personList = [];

//   SaveButtonMode _saveButtonMode = SaveButtonMode.save;

//   Person? _personToUpdate;

//   @override
//   void initState() {
//     _getAllPersons();
//     super.initState();
//   }

//   void _getAllPersons() async {
//     _personList = await _databaseHelper.getAllPersons();
//     setState(() {});
//   }

//   void _addPerson(Person person) async {
//     await _databaseHelper.insertPerson(person);

//     _ageController.clear();
//     _nameController.clear();
//     _unFocusAllFocusNode();


//     _getAllPersons();
//   }

//   void _bringPersonToUpdata(Person person) {
//     _personToUpdate = person;
//     _nameController.text = person.name;
//     _ageController.text = person.age.toString();
//     _saveButtonMode = SaveButtonMode.edit;

//     setState(() {});
//   }

//   void _updatePerson(Person person) async {
//     await _databaseHelper.updatePerson(person);

//     _ageController.clear();
//     _nameController.clear();
//     _saveButtonMode = SaveButtonMode.save;
//     _personToUpdate = null;
//     _unFocusAllFocusNode();

//     _getAllPersons();
//   }

//   void _deletePerson(int id) async {
//     await _databaseHelper.deletePerson(id);
//     _getAllPersons();
//     _ageController.clear();
//     _nameController.clear();
//     _saveButtonMode = SaveButtonMode.save;
//   }

//   void _unFocusAllFocusNode() {
//     _nameFocusNode.unfocus();
//     _ageFocus.unfocus();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _ageController.dispose();

//     _nameFocusNode.dispose();
//     _ageFocus.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: const Text("Sqflite"),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               TextField(
//                 controller: _nameController,
//                 focusNode: _nameFocusNode,
//                 decoration: const InputDecoration(border: OutlineInputBorder()),
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               TextField(
//                 controller: _ageController,
//                 focusNode: _ageFocus,
//                 decoration: const InputDecoration(border: OutlineInputBorder()),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_saveButtonMode == SaveButtonMode.save) {
//                     final personToSave = Person(
//                       name: _nameController.text.trim(),
//                       age: int.tryParse(_ageController.text.trim()) ?? 0,
//                     );
//                     _addPerson(personToSave);
//                   } else {
//                     final personToUpdate = Person(
//                       id: _personToUpdate?.id,
//                       name: _nameController.text.trim(),
//                       age: int.tryParse(_ageController.text.trim()) ?? 0,
//                     );

//                     _updatePerson(personToUpdate);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _saveButtonMode == SaveButtonMode.save
//                       ? Colors.green
//                       : Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: Text(
//                     _saveButtonMode == SaveButtonMode.save ? "Save" : "Update"),
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               Expanded(
//                   child: ListView.separated(
//                 itemBuilder: (context, index) {
//                   final person = _personList[index];

//                   return Card(
//                     child: ListTile(
//                       title: Text("Name:- ${person.name}"),
//                       subtitle: Text("Age:- ${person.age}"),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             onPressed: () {
//                               _bringPersonToUpdata(person);
//                             },
//                             icon: const Icon(Icons.edit),
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               if (person.id != null) {
//                                 _deletePerson(person.id!);
//                               }
//                             },
//                             color: Colors.red,
//                             icon: const Icon(Icons.delete),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) {
//                   return const Divider();
//                 },
//                 itemCount: _personList.length,
//               ))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// enum SaveButtonMode { save, edit }
