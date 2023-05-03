import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class PhoneLoad extends StatefulWidget {
  const PhoneLoad({super.key});

  @override
  State<PhoneLoad> createState() => _PhoneLoadState();
}

class _PhoneLoadState extends State<PhoneLoad> {
  final phoneNumController = TextEditingController();
  var isBusy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Load Retrieval"),
      ),
      body: Container(
        margin: const EdgeInsets.all(5.0),
        child: Column(children: [
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11)
            ],
            controller: phoneNumController,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter Phone Number'),
          ),
          ElevatedButton(
              onPressed: () => {}, child: const Text("Get Load Balance")),
          Container(
            margin: const EdgeInsets.only(top: 50),
            child: isBusy
                ? Row(children: const [
                    CircularProgressIndicator(),
                    Text("Calling WebServices(API)")
                  ])
                : Container(),
          )
        ]),
      ),
    );
  }
}
