import 'package:json_annotation/json_annotation.dart';
import '../../utils/user_agent.dart';

part 'resolve.g.dart';

@JsonEnum()
enum RequestMethod { 
  GET, 
  POST, 
  PUT, 
  DELETE, 
  PATCH, 
  OPTIONS;
}

/// An object containing important information used for adapters to be able to distinguish and make requests for packages from the registry
@JsonSerializable(createFactory: false)
class AdapterResolveObject {
  /// the path of the request, as is without the forward slash in front
  String path;

  /// the path segments
  List<String> pathSegments;

  /// the url of the current pritt instance
  ///
  /// Use this for modifying any urls that are needed to be made to the registry, rather than guessing the url or accidentally calling the wrong url
  String url;

  /// the request method
  RequestMethod method;

  /// The return type of the request, as a string from the `accept` header
  String accept;

  /// The value of the keep-alive header
  int? maxAge;

  /// The query parameters
  Map<String, String> query;

  final Map<String, dynamic> _meta = {};
  Map<String, dynamic> get meta => _meta;

  void addMeta(String key, String value) => _meta[key] = value;

  /// User agent information
  UserAgent userAgent;

  AdapterResolveObject(
      {required Uri uri,
      this.maxAge,
      required this.method,
      this.accept = 'application/json',
      this.query = const {},
      required this.userAgent})
      : path = uri.path,
        pathSegments = uri.pathSegments,
        url =
            '${uri.scheme}://${uri.host}${uri.port == 80 ? '' : ':${uri.port}'}';


  Map<String, dynamic> toJson() => _$AdapterResolveObjectToJson(this);
}

@JsonEnum(valueField: 'value')
enum AdapterResolveType {
  meta('meta'),
  archive('archive'),
  none('none');

  const AdapterResolveType(this.value);
  final String value;

  bool get isResolved => this != none;
}
