/// An object to represent a custom adapter
class CustomAdapterEntry {
  /// The id of the adapter
  String id;

  /// The language this adapter is associated with, as a lowercase string
  String language;

  /// The path to the adapter in the adapter file system
  Uri path;

  /// The external location to where this adapter is authored
  ///
  /// This is null if the adapter is authored locally
  Uri? source;

  /// The name of the adapter, if any
  String name;

  /// Any metadata concerning the adapter
  Map<String, dynamic>? metadata;

  CustomAdapterEntry({
    required this.id,
    required this.language,
    required this.path,
    this.source,
    required this.name,
    this.metadata,
  });

  @override
  String toString() =>
      'CustomAdapterEntry(id: $id, language: $language, path: $path, source: $source, name: $name, metadata: $metadata)';
}
