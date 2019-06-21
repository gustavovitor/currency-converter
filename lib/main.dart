import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const URL = 'https://api.hgbrasil.com/finance?format=json&key=788f2e22';

void main() {
  runApp(MaterialApp(
    title: 'Conversor',
    home: App(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(URL);
  return json.decode(response.body);
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll(){
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  void _realChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double value = double.parse(text);
    dolarController.text = (value/dolar).toStringAsFixed(2);
    euroController.text = (value/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double value = double.parse(text);
    realController.text = (value * dolar).toStringAsFixed(2);
    euroController.text = (value * dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double value = double.parse(text);
    realController.text = (value * euro).toStringAsFixed(2);
    dolarController.text = (value * euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Conversor', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text('Carregando dados..',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0
                  ),
                  textAlign: TextAlign.center),
              );
              break;
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao buscar os dados :(',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0
                    ),
                    textAlign: TextAlign.center),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Icon(Icons.monetization_on, size: 128, color: Colors.amber),
                      ),
                      buildTextField('Reais', 'R\$', realController, _realChanged),
                      Divider(),
                      buildTextField('Dolar', 'US\$', dolarController, _dolarChanged),
                      Divider(),
                      buildTextField('Euro', '€', euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

buildTextField(String labelText, String prefix, TextEditingController controller, Function onChangeFunction) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: onChangeFunction,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}