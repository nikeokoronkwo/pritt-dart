abstract class Content {
  /// The mime type of the given content
  String mime;

  Content({this.mime = 'text/plain'});
}

/// Binary GZip Content
class GZipContent extends Content {
  @override
  String get mime => "application/gzip";

  /// The data in the GZip
  /// TODO: Change type of data
  Object data;

  GZipContent(this.data) : super(mime: "application/gzip");
}
