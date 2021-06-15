/*
 * The contents of this file are subject to the terms of the Common Development and
 * Distribution License (the License). You may not use this file except in compliance with the
 * License.
 *
 * You can obtain a copy of the License at legal/CDDLv1.0.txt. See the License for the
 * specific language governing permission and limitations under the License.
 *
 * When distributing Covered Software, include this CDDL Header Notice in each file and include
 * the License file at legal/CDDLv1.0.txt. If applicable, add the following below the CDDL
 * Header, with the fields enclosed by brackets [] replaced by your own identifying
 * information: "Portions copyright [year] [name of copyright owner]".
 *
 * Copyright 2021 Open Identity Platform Comminity
 */

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openam_demo_authenticator/services/openam.dart';
import 'package:openam_demo_authenticator/services/settings.dart';
import 'package:openam_demo_authenticator/settings_page.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OpenAM Demo Authentcatior',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: QRAuthenticatorPage(title: 'OpenAM Demo Authentcatior'),
      routes: <String, WidgetBuilder>{
        "/settings": (BuildContext context) => SettingsPage(settingsService),
      },
    );
  }
}

final OpenAMService openamService = OpenAMService(http.Client());
final SettingsService settingsService = SettingsService();

class QRAuthenticatorPage extends StatefulWidget {
  QRAuthenticatorPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _QRAuthenticatorPageState createState() => _QRAuthenticatorPageState();
}

class _QRAuthenticatorPageState extends State<QRAuthenticatorPage> {
  String tokenId = '';
  String qrCode = '';
  String userName = '';
  final codeController = TextEditingController();
  void _gotoSettings() {
    Navigator.of(context).pushNamed("/settings");
  }

  void _login() async {
    var settings = await settingsService.getSettings();
    print('settings $settings');
    String openamToken = await openamService.login(
        settings.openamUrl, settings.realm, settings.user, settings.password);
    setState(() {
      this.tokenId = openamToken == null ? 'null' : openamToken;
    });

    var sessionInfo =
        await openamService.getSessionInfo(settings.openamUrl, openamToken);
    setState(() {
      this.userName = sessionInfo["username"];
    });
  }

  void _scan() async {
    try {
      ScanResult sr = await BarcodeScanner.scan();
      processBarcode(sr.rawContent);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        _processBarcodeError('The user did not grant the camera permission!');
      } else {
        _processBarcodeError('Unknown error: $e');
      }
    } on FormatException {
      _processBarcodeError(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      _processBarcodeError('Unknown error: $e');
    }
  }

  void processBarcode(String barcode) async {
    if (barcode.isEmpty) {
      _processBarcodeError('no barcode scanned');
      return;
    }
    print('process barcode $barcode');
    var settings = await settingsService.getSettings();
    try {
      await openamService.qrAuth(settings.openamUrl, settings.realm,
          settings.qrService, barcode, this.tokenId);

      processBarcodeResult("Sucessfull authentication");
    } catch (e) {
      _processBarcodeError('Authentication error');
    }
  }

  void processBarcodeResult(String result) {
    _showErrorDialog(result, false);
  }

  void _processBarcodeError(String errText) {
    _showErrorDialog(errText, true);
  }

  void _setQRCode(String qrCode) {
    setState(() {
      this.qrCode = qrCode;
    });
  }

  void _enterCode() async {
    processBarcode(this.qrCode);
  }

  Future<void> _showErrorDialog(String text, bool isError) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isError ? 'Error Occurred' : 'Success'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getTokenIdPresentation(String tokenId) {
    return tokenId == null || tokenId.length < 10
        ? tokenId
        : tokenId.replaceRange(10, tokenId.length, '...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(icon: Icon(Icons.settings), onPressed: _gotoSettings),
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                    child: Text('got tokenId: ' +
                        _getTokenIdPresentation(tokenId) +
                        ' uid: $userName')),
                FloatingActionButton.extended(
                  onPressed: _login,
                  icon: Icon(Icons.login),
                  label: Text('Login'),
                  heroTag: 'login',
                ),
                Container(
                    margin: const EdgeInsets.only(top: 15.0),
                    child: FloatingActionButton.extended(
                      onPressed: _scan,
                      icon: Icon(Icons.qr_code),
                      label: Text('Scan QR to authenicate'),
                      heroTag: 'qr-auth',
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 15.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Enter a code from QR",
                        suffixIcon: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.clear),
                            onPressed: () =>
                                {codeController.clear(), _setQRCode('')}),
                      ),
                      onChanged: _setQRCode,
                      controller: codeController,
                    )),
                Container(
                    margin: const EdgeInsets.only(top: 15.0),
                    child: FloatingActionButton.extended(
                      onPressed: _enterCode,
                      icon: Icon(Icons.text_snippet),
                      label: Text('Authenticate'),
                      heroTag: 'code-auth',
                    )),
              ],
            ),
          ),
        )));
  }
}
