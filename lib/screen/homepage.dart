import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:tododo/db_service/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool suggest = false;
  bool _isGridView = false;
  TextEditingController todoController = TextEditingController();
  Stream? todoStream;

  getOnTheLoad() async {
    todoStream = await DatabaseService()
        .getTask(_selectedIndex == 0 ? "PersonalTask" : "Done");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

//long press
  void showEditRemoveMenu(DocumentSnapshot docSnap) {
    _selectedIndex == 0
        ? showModalBottomSheet(
            context: context,
            builder: (context) => Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    openEditBox(docSnap);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Remove'),
                  onTap: () async {
                    await DatabaseService()
                        .removeMethod(docSnap["id"], "PersonalTask");
                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
              ],
            ),
          )
        : null;
  }

//edit sheet
  Future openEditBox(DocumentSnapshot docSnap) {
    todoController.text = docSnap["work"];
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Task Name'),
              SizedBox(height: 10),
              TextField(
                controller: todoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  ),
                  onPressed: () async {
                    String updatedTask = todoController.text;
                    await DatabaseService()
                        .updateTask(docSnap["id"], updatedTask);
                    todoController.text = "";
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//store to fb(to do -> done)
  Widget getWork() {
    return StreamBuilder(
      stream: todoStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Expanded(
                child: _isGridView
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot docSnap = snapshot.data.docs[index];
                          bool isDone = docSnap["done"];
                          return GestureDetector(
                            onLongPress: () => showEditRemoveMenu(docSnap),
                            child: Card(
                              elevation: 4,
                              child: CheckboxListTile(
                                activeColor: Colors.green.shade400,
                                title: Text(
                                  docSnap["work"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                value: isDone,
                                onChanged: (newValue) async {
                                  await DatabaseService().tickmethod(
                                      docSnap["id"], "PersonalTask");
                                  Map<String, dynamic> doneTask = {
                                    "work": docSnap["work"],
                                    "id": docSnap["id"],
                                    "done": true,
                                  };
                                  await DatabaseService()
                                      .addToDoneTask(doneTask, docSnap["id"]);

                                  Future.delayed(Duration(seconds: 1), () {
                                    DatabaseService().removeMethod(
                                        docSnap["id"], "PersonalTask");
                                  });
                                  setState(() {});
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot docSnap = snapshot.data.docs[index];
                          bool isDone = docSnap["done"];
                          return GestureDetector(
                            onLongPress: () => showEditRemoveMenu(docSnap),
                            child: CheckboxListTile(
                              activeColor: Colors.green.shade400,
                              title: Text(
                                docSnap["work"],
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              value: isDone,
                              onChanged: (newValue) async {
                                await DatabaseService()
                                    .tickmethod(docSnap["id"], "PersonalTask");
                                Map<String, dynamic> doneTask = {
                                  "work": docSnap["work"],
                                  "id": docSnap["id"],
                                  "done": true,
                                };
                                await DatabaseService()
                                    .addToDoneTask(doneTask, docSnap["id"]);

                                Future.delayed(Duration(seconds: 1), () {
                                  DatabaseService().removeMethod(
                                      docSnap["id"], "PersonalTask");
                                });
                                setState(() {});
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          );
                        },
                      ),
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

//bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    getOnTheLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () {
                openBox();
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            )
          : null,
      appBar: AppBar(
        title: Text("Task Manager"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedIndex == 0 ? 'To do Tasks' : 'Completed Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            getWork(),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              child: Text(
                  _isGridView ? 'Switch to ListView' : 'Switch to GridView'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'To do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Done',
          ),
        ],
      ),
    );
  }

//add new task
  Future openBox() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Task Name'),
              SizedBox(height: 10),
              TextField(
                controller: todoController,
                decoration: InputDecoration(
                  hintText: "Enter task",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  ),
                  onPressed: () {
                    String id = randomAlphaNumeric(100);
                    Map<String, dynamic> userTodo = {
                      "work": todoController.text,
                      "id": id,
                      "done": false,
                    };
                    DatabaseService().addPersonalTask(userTodo, id);
                    todoController.text = "";
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
