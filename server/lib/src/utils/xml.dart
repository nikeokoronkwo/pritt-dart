import 'package:xml/xml.dart';

String mapToXml(Map<String, dynamic> data, {String rootElement = 'root'}) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element(rootElement, nest: () {
    _buildXml(builder, data);
  });
  return builder.buildDocument().toXmlString(pretty: true);
}

void _buildXml(XmlBuilder builder, Map<String, dynamic> data) {
  data.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      builder.element(key, nest: () => _buildXml(builder, value));
    } else if (value is List) {
      for (var item in value) {
        if (item is Map<String, dynamic>) {
          builder.element(key, nest: () => _buildXml(builder, item));
        } else {
          builder.element(key, nest: item.toString());
        }
      }
    } else {
      builder.element(key, nest: value.toString());
    }
  });
}
