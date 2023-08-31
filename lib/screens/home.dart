// ignore_for_file: prefer_const_constructors, unused_field, sort_child_properties_last, avoid_print

import 'package:crud/models/config.dart';
import 'package:crud/models/users.dart';
import 'package:crud/screens/sidemenu.dart';
import 'package:crud/screens/userform.dart';
import 'package:crud/screens/userinfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  static const routeName = "/";
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget mainBody = Container();
  List<Users> _userList = [];

  @override
  void initState() {
    super.initState();
    Users user = Configure.login;
    if (user.id != null) {
      getUsers();
    }
  }

  Future<void> getUsers() async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.get(url);
    setState(() {
      _userList = usersFromJson(resp.body);
      mainBody = showUsers();
    });
    return;
  }

  Future<void> removeUsers(user) async {
    var url = Uri.http(Configure.server, "users/${user.id}");
    var resp = await http.delete(url);
    print(resp.body);
    return;
  }

  Widget showUsers() {
    return ListView.builder(
        itemCount: _userList.length,
        itemBuilder: (context, index) {
          Users user = _userList[index];
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            child: Card(
                child: ListTile(
              title: Text("${user.fullname}"),
              subtitle: Text("${user.email}"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserInfo(),
                        settings: RouteSettings(arguments: user)));
              }, // to show info
              trailing: IconButton(
                  onPressed: () async {
                    String result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserForm(),
                            settings: RouteSettings(arguments: user)));
                    if (result == "refresh") {
                      getUsers();
                    }
                  },
                  icon: Icon(Icons.edit)),
            )),
            onDismissed: (direction) {
              removeUsers(user);
            }, // to delete
            background: Container(
              color: Colors.red,
              margin: EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.centerRight,
              child: Icon(Icons.delete, color: Colors.white),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: SideMenu(),
      body: mainBody,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserForm(),
              ));
          if (result == "refresh") {
            getUsers();
          }
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
