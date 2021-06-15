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

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  final _storage = FlutterSecureStorage();

  final String _settingsKey = 'settings'; 
  Future<void> set(String value) async {
    if(kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(_settingsKey, value);
    } else {
      await _storage.write(key: _settingsKey, value: value);
    }
  }
  Future<String> get() async {
    if(kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_settingsKey);
    } else {
      return await _storage.read(key: _settingsKey);
    }
  }

  Future<bool> containsKey() async {
    if(kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_settingsKey);
    } else {
      return await _storage.containsKey(key: _settingsKey);
    }
  }
}