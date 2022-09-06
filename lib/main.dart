import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance/stock_price?key=70a44057";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.blueGrey, primaryColor: Colors.blueGrey),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final searchController = TextEditingController();
  final displayResultController = TextEditingController();

  double price;
  String simbolo;

  void _symbolChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    simbolo = text;
  }

  void _clearAll() {
    searchController.text = "";
    displayResultController.text = "";
  }

  void _clearSearch() {
    searchController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text("\$ Bolsa de Valores \$"),
            centerTitle: true,
            backgroundColor: Colors.blueGrey),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao carregar dados...",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.blueGrey),
                          buildTextFormField("Informe o simbo ", searchController, _symbolChange),
                          Divider(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 30),
                              primary: Colors.blueGrey,
                            ),
                            onPressed: () async {
                              _clearSearch();
                                  String request ="https://api.hgbrasil.com/finance/stock_price?key=70a44057&symbol=" + simbolo;
                                  http.Response response = await http.get(request);
                                  Map<String, dynamic> snapshot = json.decode(response.body);
                                  price = snapshot["results"][simbolo.toUpperCase()]["price"];
                                  simbolo = snapshot["results"][simbolo.toUpperCase()]["name"];
                                  displayResultController.text = simbolo + ", R\$ " + price.toStringAsFixed(2);
                            },
                            child: Text('Buscar'),
                          ),
                          Divider(),
                          TextField(
                              controller: displayResultController,
                              decoration: InputDecoration(
                                  fillColor: Colors.blueGrey),
                              style:
                                  TextStyle(color: Colors.blueGrey, fontSize: 25),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.none)
                        ],
                      ),
                    );
                  }
              }
            }));
  }

  Widget buildTextFormField(
      String label, TextEditingController controller, Function f) {
    return TextField(
      onChanged: f,
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey),
          border: OutlineInputBorder()),
      style: TextStyle(color: Colors.blueGrey, fontSize: 25.0),
      keyboardType: TextInputType.text,
    );
  }
}
