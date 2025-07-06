// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resolve.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$AdapterResolveObjectToJson(
  AdapterResolveObject instance,
) => <String, dynamic>{
  'path': instance.path,
  'pathSegments': instance.pathSegments,
  'url': instance.url,
  'method': _$RequestMethodEnumMap[instance.method]!,
  'accept': instance.accept,
  'maxAge': instance.maxAge,
  'query': instance.query,
  'meta': instance.meta,
  'userAgent': instance.userAgent.toJson(),
};

const _$RequestMethodEnumMap = {
  RequestMethod.GET: 'GET',
  RequestMethod.POST: 'POST',
  RequestMethod.PUT: 'PUT',
  RequestMethod.DELETE: 'DELETE',
  RequestMethod.PATCH: 'PATCH',
  RequestMethod.OPTIONS: 'OPTIONS',
};
