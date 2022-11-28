import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techmdemo/Model/todomodel.dart';

import '../Common/SharedPreferenes.dart';
import '../Common/comHelper.dart';
import '../DatabaseHandler/dbHelper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  List<TodoModel> todoList = [];
  List<TodoModel> filtertodoList = [];
  late DbHelper dbHelper;
  String userId = "";
  final ImagePicker _picker = ImagePicker();
  late File imageURI;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    getTodoList();
  }

  Future<void> getTodoList() async {
    userId = await getuserIdSF() ?? "";
    final SharedPreferences sp = await _pref;
    setState(() {
      Future<List<TodoModel>> todoListFuture = dbHelper.getTodoList(userId);
      todoListFuture.then((todoList1) {
        setState(() {
          filtertodoList.clear();
          todoList.clear();
          this.filtertodoList = todoList1;
          todoList=filtertodoList;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showLogoutDailog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: todoView(),
      ),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          navigateToDetail(TodoModel('', '', '', userId, ''), 'Add Todo');
        },
      ),
    );
  }

  Widget todoView() {
    return filtertodoList.length == 0
        ? emptycontainer("Data Not Available",
        context)
        :SingleChildScrollView(
      child: Column(
        children: [_searchBar(), ListView.builder(
          shrinkWrap: true,
          itemCount: todoList.length,
          itemBuilder: (BuildContext context, int position) {
            return Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Text(getFirstLetter(this.todoList[position].title),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text(this.todoList[position].title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      this.todoList[position].description,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Text(
                      DateFormat("dd MMM yyyy hh:mm a")
                          .format(DateTime.parse(todoList[position].date)),
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                    if(todoList[position].image.isNotEmpty)
                      GestureDetector(
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (_) =>
                                  Dialog(
                                    child: Container(
                                      width: 400,
                                      height: 400,
                                      child: Image.memory(
                                          Base64Decoder().convert(todoList[position].image)),
                                    ),
                                  ));
                        },
                        child: Text(
                          "Preview Image",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.orange),
                        ),
                      )
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onTap: () {
                        _delete(context, todoList[position]);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  debugPrint("ListTile Tapped");
                  navigateToDetail(this.todoList[position], 'Edit Todo');
                },
              ),
            );
          },
        )],
      ),
    );
  }

  _searchBar() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black38,
          ),
          borderRadius: BorderRadius.circular(
              10) // use instead of BorderRadius.all(Radius.circular(20))
      ),
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      height: 50,
      child: TextField(
        autofocus: false,
        onChanged: (searchText) {
          searchText = searchText.toLowerCase();
          setState(() {
            todoList = filtertodoList.where((u) {
              var ftname = u.title.toLowerCase();
              return ftname.contains(searchText);
            }).toList();
          });
        },
        // controller: _textController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 14),
          prefixIcon: Icon(Icons.search),
          hintText: 'Search By Reminder Title',
        ),
      ),
    );
  }


  void _delete(BuildContext context, TodoModel todo) async {
    int result = await dbHelper.deleteTodo(todo.id);
    if (result != 0) {
      alertDialog('Todo Deleted Successfully', context);
      getTodoList();
    }
  }

  void navigateToDetail(TodoModel todo, String title) async {
    openAddEditDailog(todo, title);
  }

  void openAddEditDailog(TodoModel todo, String title) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _controllerdate = TextEditingController();
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    _controllerdate.text = todo.date;


    void save() async {
      int result;
      if(todo.title.isEmpty || todo.description.isEmpty || todo.date.isEmpty ){
        alertDialog('Please enter details', context);
      }else {
        if (title == "Add Todo") {
          result = await dbHelper.insertTodo(todo);
        } else {
          result = await dbHelper.updateTodo(todo);
        }

        Navigator.of(context, rootNavigator: true).pop();
        if (result != 0) {
          alertDialog('Todo Saved Successfully', context);
        } else {
          alertDialog('Problem Saving Todo', context);
        }
        getTodoList();
      }
    }

    var selectedImage = "";
    Widget optionOne = SimpleDialogOption(
      child: const Text('Choose from Camera'),
      onPressed: () async {
        //Navigator.of(context, rootNavigator: true).pop(context);
        XFile? image = await _picker.pickImage(source: ImageSource.camera,imageQuality: 50);
        if (image != null) {
          File imagefile = File(image.path);
          Uint8List imagebytes = await imagefile.readAsBytes();
          setState(() {
            selectedImage = base64.encode(imagebytes);
            print(selectedImage);
          });
        }
        Navigator.pop(context, selectedImage);
      },
    );
    Widget optionTwo = SimpleDialogOption(
      child: const Text('Choose from Gallery'),
      onPressed: () async {
        // Navigator.of(context, rootNavigator: true).pop(context);
        XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          File imagefile = File(image.path);
          Uint8List imagebytes = await imagefile.readAsBytes();
          setState(() {
            selectedImage = base64.encode(imagebytes);
            print(selectedImage);
          });
        }
        Navigator.pop(context, selectedImage);
      },
    );
    Widget optionThree = SimpleDialogOption(
      child: const Text('Cancel'),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
      },
    );



    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(title),
                  content: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                TextField(
                                  controller: titleController,
                                  style: TextStyle(fontSize: 13),
                                  onChanged: (value) {
                                    todo.title = titleController.text;
                                  },
                                  decoration: InputDecoration(
                                      labelText: 'Reminder Title',
                                      border: OutlineInputBorder()),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  child: TextField(
                                    controller: descriptionController,
                                    minLines: 2,
                                    maxLines: 5,
                                    keyboardType: TextInputType.multiline,
                                    style: TextStyle(fontSize: 13),
                                    onChanged: (value) {
                                      todo.description =
                                          descriptionController.text;
                                    },
                                    decoration: InputDecoration(
                                        labelText: 'Reminder Description',
                                        border: OutlineInputBorder()),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                DateTimePicker(
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                      labelText: 'Reminder Date Time',
                                      border: OutlineInputBorder()),
                                  type: DateTimePickerType.dateTime,
                                  dateMask: 'dd MMM yyyy kk:mm',
                                  use24HourFormat: true,
                                  initialValue: _controllerdate.text,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                  dateLabelText: 'Reminder Date Time',
                                  locale: Locale('en', 'US'),
                                  onChanged: (val) {
                                    setState(() {
                                      _controllerdate.text = val!;
                                      todo.date = val!;
                                    });
                                  },
                                  validator: (val) {
                                    setState(() {
                                      _controllerdate.text = val!;
                                      todo.date = val!;
                                    });
                                    return null;
                                  },
                                  onSaved: (val) => {todo.date = val!},
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                          side: BorderSide(color: Colors.grey)),
                                      primary: Colors.grey,
                                      textStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  icon: Text('Choose Image',
                                      style: TextStyle(fontSize: 14, color: Colors.black)),
                                  label: Icon(
                                    Icons.wb_cloudy_outlined,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    SimpleDialog dialog = SimpleDialog(
                                      title: const Text('Add Photo!'),
                                      children: <Widget>[
                                        optionOne,
                                        optionTwo,
                                        optionThree,
                                      ],
                                    );

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return dialog;
                                      },
                                    ).then((val) {
                                      setState(() {
                                        todo.image = val;
                                        print(todo.image);
                                      });
                                    });
                                    ;
                                  },
                                ),
                                Container(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10.0),
                                      child: todo.image.isEmpty ? Text("No File Choosen")
                                          : GestureDetector(
                                        onTap: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  Dialog(
                                                    child: Container(
                                                      width: 400,
                                                      height: 400,
                                                      child: Image.memory(
                                                          Base64Decoder().convert(todo.image)),
                                                    ),
                                                  ));
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              "Preview",
                                              style: TextStyle(
                                                  decoration: TextDecoration.underline,
                                                  color: Colors.orange),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  todo.image = "";
                                                });
                                              },
                                              child: Text(
                                                "Delete",
                                                style: TextStyle(
                                                    decoration: TextDecoration.underline,
                                                    color: Colors.red),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size.fromWidth(double.maxFinite),
                                    ),
                                    child: Text('Save'),
                                    onPressed: () {
                                      save();
                                    },
                                  ),
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                );
              });
        }
    );
  }
}
