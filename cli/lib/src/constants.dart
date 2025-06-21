import 'dart:io';

final mainPrittInstance = Platform.environment['PRITT_URL'] ?? defaultPrittInstance;
const defaultPrittInstance = 'https://pritt.dev/';

final mainPrittUrl = Uri.parse(mainPrittInstance);
final mainPrittApiUrl = mainPrittUrl.replace(host: 'api.${mainPrittUrl.host}');
final mainPrittApiInstance = Platform.environment['PRITT_API_URL'] ?? mainPrittApiUrl.toString();
