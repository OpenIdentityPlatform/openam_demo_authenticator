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

import 'package:http/http.dart' as http;

class OpenAMService {
  http.Client client;

  OpenAMService(this.client);
  Future<String> login(
      String openamUrl, String realm, String user, String password) async {
    try {
      var url = Uri.parse('$openamUrl/json' +
          (realm == '/' ? '' : '/$realm') +
          '/authenticate');
      final headers = {
        "X-OpenAM-Username": user,
        "X-OpenAM-Password": password
      };
      var response = await client.post(url, headers: headers);
      var bidningMap = jsonDecode(response.body);
      print('auth body: $bidningMap');
      var tokenId = bidningMap['tokenId'];
      return tokenId;
    } catch (e) {
      print('exception: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> serverInfo(String openamUrl) async {
    var url = Uri.parse('$openamUrl/json/serverinfo/*');
    var response = await client.get(url);
    var serverInfo = jsonDecode(response.body);
    print('server info $serverInfo');
    return serverInfo;
  }

/*  
curl 'http://openam.example.org:8080/openam/json/sessions?_action=getSessionInfo&tokenId=AQIC5wM2LY4Sfcx062gMx3oBBvCW2t2xVZ4iyomHBx-rr-g.*AAJTSQACMDEAAlNLABMyMDgxMDg2MzA3ODQwNTMwOTIzAAJTMQAA*' \
  -X 'POST' \
  -H 'Connection: keep-alive' \
  -H 'Content-Length: 0' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'Accept-API-Version: protocol=1.0,resource=2.0' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'Accept-Language: ru' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36' \
  -H 'Content-Type: application/json' \
  -H 'Origin: http://openam.example.org:8080' \
  -H 'Referer: http://openam.example.org:8080/openam/XUI/' \
  -H 'Cookie: JSESSIONID=E3173FB0E9871EA13091C8EB2C604C15; i18next=ru; amlbcookie=01; AMAuthCookie=AQIC5wM2LY4SfcwyF_L8vTAA-cRLhVv06SWmaC0mgtqhHG8.*AAJTSQACMDEAAlNLABQtMzk1NzEzMTM4NDYyMTc1OTAwOAACUzEAAA..*; iPlanetDirectoryPro=AQIC5wM2LY4Sfcx062gMx3oBBvCW2t2xVZ4iyomHBx-rr-g.*AAJTSQACMDEAAlNLABMyMDgxMDg2MzA3ODQwNTMwOTIzAAJTMQAA*' \
  --compressed \
  --insecure*/

  Future<Map<String, dynamic>> getSessionInfo(
      String openamUrl, String tokenId) async {
    var serverInfo = await this.serverInfo(openamUrl);
    String cookieName = serverInfo['cookieName'];
    var url = Uri.parse('$openamUrl/json/sessions/?_action=getSessionInfo');
    final headers = {
      "Content-Type": "application/json",
      cookieName: tokenId,
    };
    var response = await client.post(url, headers: headers);
    var sessionInfo = jsonDecode(response.body);
    print('server info $sessionInfo');
    return sessionInfo;
  }

  Future<void> qrAuth(String openamUrl, String realm, String qrService,
      String code, String tokenId) async {
    var url = Uri.parse('$openamUrl/json' +
        (realm == '/' ? '' : '/$realm') +
        '/authenticate?&authIndexType=service&authIndexValue=$qrService&ForceAuth=true' +
        "&sessionUpgradeSSOTokenId=" +
        tokenId);
    final headers = {'Content-Type': 'application/json;charset=UTF-8'};
    var response = await client.post(url, headers: headers);
    var bidningMap = jsonDecode(response.body);

    print('$bidningMap');

    List callbacks = bidningMap['callbacks'].toList();
    if (callbacks.length != 1) {
      throw new Exception("Authentication error");
    }
    var callback = callbacks[0];
    var input = callback['input'][0];
    input['value'] = code;
    print('$input');

    print(bidningMap);

    String body = jsonEncode(bidningMap);

    var authResponse = await client.post(url, headers: headers, body: body);

    var parsedResponse = jsonDecode(authResponse.body);

    print(parsedResponse);

    List authCallbacks = parsedResponse['callbacks'].toList();
    if (authCallbacks.length != 1) {
      throw new Exception("Authentication error");
    }
    if (authCallbacks[0]["type"] != 'TextOutputCallback' ||
        authCallbacks[0]["output"][0]['value'] != 'OK') {
      throw new Exception("Authentication error");
    }
  }
}

/*curl -v --request POST \
 --header "X-OpenAM-Username: demo" \
 --header "X-OpenAM-Password: changeit" \
 https://openam.example.org:8080/openam/json/authenticate
*/
