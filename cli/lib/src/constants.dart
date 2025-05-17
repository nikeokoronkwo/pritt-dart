const mainPrittInstance =
    String.fromEnvironment('PRITT_URL', defaultValue: defaultPrittInstance);
const defaultPrittInstance = 'https://pritt.dev/';

final mainPrittUrl = Uri.parse(mainPrittInstance);
final mainPrittApiUrl = mainPrittUrl.replace(host: 'api.${mainPrittUrl.host}');
