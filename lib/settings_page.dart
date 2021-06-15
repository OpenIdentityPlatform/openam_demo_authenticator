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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:openam_demo_authenticator/services/settings.dart';

class SettingsPage extends StatefulWidget {
  final SettingsService settingsService;
  SettingsPage(this.settingsService);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Settings settings;
  final openamUrlController = new TextEditingController();
  final realmController = new TextEditingController();
  final usernameController = new TextEditingController();
  final passwordController = new TextEditingController();
  final qrServiceController = new TextEditingController();

  void _setUrl(url) {
    setState(() {
      this.settings.openamUrl = url;
    });
  }

  void _setUsername(username) {
    setState(() {
      this.settings.user = username;
    });
  }

  void _setRealm(realm) {
    setState(() {
      this.settings.realm = realm;
    });
  }

  void _setPassword(password) {
    setState(() {
      this.settings.password = password;
    });
  }

  void _setQRService(qrService) {
    setState(() {
      this.settings.qrService = qrService;
    });
  }

  _SettingsPageState();

  @override
  void initState() {
    super.initState();
    widget.settingsService.getSettings().then((s) => {
          setState(() {
            this.settings = s;
          }),
          openamUrlController.text = s.openamUrl,
          realmController.text = s.realm,
          usernameController.text = s.user,
          passwordController.text = s.password,
          qrServiceController.text = s.qrService,
        });
  }

  @override
  void dispose() async {
    super.dispose();
    widget.settingsService.updateSettings(settings);
    this.openamUrlController.dispose();
    this.realmController.dispose();
    this.passwordController.dispose();
    this.usernameController.dispose();
    this.qrServiceController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('building widget');
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SettingsTextField(
                      controller: openamUrlController,
                      onChanged: _setUrl,
                      labelText: 'OpenAM URL',
                      keyboardType: TextInputType.url,
                    ),
                    SettingsTextField(
                        controller: realmController,
                        onChanged: _setRealm,
                        labelText: 'Realm'),
                    SettingsTextField(
                        controller: qrServiceController,
                        onChanged: _setQRService,
                        labelText: 'QR Service'),
                    SettingsTextField(
                        controller: usernameController,
                        onChanged: _setUsername,
                        labelText: 'Username'),
                    SettingsTextField(
                      controller: passwordController,
                      onChanged: _setPassword,
                      obscureText: true,
                      labelText: 'Password',
                    ),
                  ])),
        )));
  }
}

class SettingsTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function onChanged;
  final bool obscureText;
  final String labelText;
  final TextInputType keyboardType;
  SettingsTextField(
      {this.controller,
      this.onChanged,
      this.obscureText = false,
      this.labelText,
      this.keyboardType});
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 15.0),
        child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: this.labelText,
            ),
            keyboardType: this.keyboardType,
            obscureText: this.obscureText,
            onChanged: this.onChanged,
            controller: this.controller));
  }
}
