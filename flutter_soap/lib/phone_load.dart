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

  callSOAP(phoneNum) async {
    setState(() {
      isBusy = true;
    });

    var soapEnv = '''
<?xml version="1.0" encoding="ISO-8859-1"?>
<SOAP-ENV:Envelope SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Body>
    <ns3060:get_load xmlns:ns3060="http://tempuri.org">
      <currCpNum xsi:type="xsd:string">$phoneNum</currCpNum>
    </ns3060:get_load>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
''';
    try {
      http.Response response = await http
          .post(
              Uri(
                  scheme: 'http',
                  host: '192.168.1.5',
                  path: '/IT140P_LABExer4/service.php'),
              headers: {
                "Content-Type": "text/xml; charset=ISO-8859-1",
                "Host": "localhost"
              },
              body: soapEnv)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        // Time has run out, do what you wanted to do.
        return http.Response(
            'Error', 408); // Request Timeout response status code
      });

      var rawResponseXML = response.body;

      xml.XmlDocument parsedXml = xml.XmlDocument.parse(rawResponseXML);

      var res = parsedXml
          .getElement("SOAP-ENV:Envelope")
          ?.getElement("SOAP-ENV:Body")
          ?.getElement("ns1:get_loadResponse")
          ?.getElement("return")!
          .text;
      // var val = parsedXml.getAttribute("AddResult");
      if (res == "NOT FOUND") {
        announce("Phone number $res");
      } else {
        announce("You have P$res load");
      }
    } catch (e) {
      announce("There is a problem in connecting to web services api.");
    }

    setState(() {
      isBusy = false;
    });
  }

  getBalance() {
    if (phoneNumController.text == "") {
      announce("Please input a phone number");
      return;
    }
    callSOAP(phoneNumController.text);
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
              onPressed: getBalance, child: const Text("Get Load Balance")),
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
