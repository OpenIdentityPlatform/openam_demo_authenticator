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

import 'dart:convert';

import 'package:openam_demo_authenticator/services/storage.dart';

class Settings {
  String openamUrl;
  String realm;
  String user;
  String password;
  String qrService;
  Settings(this.openamUrl, this.realm, this.qrService, this.user, [this.password = ""]);

  Settings.fromJson(Map<String, dynamic> json)
      : openamUrl = json['openamUrl'],
        realm = json['realm'],
        qrService = json['qrService'],
        user = json['user'],
        password = json['password'];

  Map<String, dynamic> toJson() => {
        'openamUrl': openamUrl,
        'realm': realm,
        'qrService': qrService,
        'user': user,
        'password': password,
      };
}

final Settings _settings = Settings("http://openam.example.com:8080/openam", "/", "qr", "amadmin");

final StorageService _storageService = StorageService();

class SettingsService {

  Future<Settings> getSettings() async {
    bool containsKey = await _storageService.containsKey();
    if(!containsKey) {
      var settingsStr = jsonEncode(_settings);
      _storageService.set(settingsStr);
    }
    var settingsStr = await _storageService.get();
    return Settings.fromJson(jsonDecode(settingsStr));
  }

  void updateSettings(Settings newSettings) async {
    _settings.openamUrl = newSettings.openamUrl;
    _settings.realm = newSettings.realm;
    _settings.qrService = newSettings.qrService;
    _settings.user = newSettings.user;
    _settings.password = newSettings.password;

    _storageService.set(jsonEncode(_settings));
  }
}

