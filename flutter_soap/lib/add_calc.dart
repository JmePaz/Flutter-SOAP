import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class AddCalc extends StatefulWidget {
  const AddCalc({super.key});

  @override
  State<AddCalc> createState() => _AddCalcState();
}

class _AddCalcState extends State<AddCalc> {
  final num1Controller = TextEditingController();
  final num2Controller = TextEditingController();
  var isCalling = false;

  callSOAP(num1, num2) async {
    if (isCalling) {
      return;
    }

    setState(() {
      isCalling = true;
    });

    var soapEnv = '''
<?xml version="1.0" encoding="utf-8"?>
<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
  <soap12:Body>
    <Add xmlns="http://tempuri.org/">
      <intA>$num1</intA>
      <intB>$num2</intB>
    </Add>
  </soap12:Body>
</soap12:Envelope>
''';

    http.Response response = await http.post(
        Uri(scheme: 'http', host: 'dneonline.com', path: '/calculator.asmx'),
        headers: {
          "Content-Type": "text/xml; charset=utf-8",
          "Host": "www.dneonline.com"
        },
        body: soapEnv);

    var rawResponseXML = response.body;

    xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawResponseXML);
    var res = parsedXml
        .getElement("soap:Envelope")
        ?.getElement("soap:Body")
        ?.getElement("AddResponse")
        ?.getElement("AddResult")!
        .text;
    // var val = parsedXml.getAttribute("AddResult");
    announce("Result is $res");

    setState(() {
      isCalling = false;
    });
  }

  announce(text) {
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            content: Text("$text"),
          );
        }));
  }

  calculate() {
    if (num1Controller.text == "" || num2Controller.text == "") {
      announce("Input must not be empty");
      return;
    }
    //call web services
    callSOAP(num1Controller.text, num2Controller.text);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Add Calculator using SOAP"),
      ),
      body: Container(
        padding: const EdgeInsets.all(7),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: num1Controller,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(), labelText: 'Enter number 1'),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: num2Controller,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(), labelText: 'Enter number 2'),
            ),
            ElevatedButton(
                onPressed: calculate, child: const Text("Add Numbers")),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: isCalling
                  ? Row(children: const [
                      CircularProgressIndicator(),
                      Text("Calling Online WebServices(API)")
                    ])
                  : Container(),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
