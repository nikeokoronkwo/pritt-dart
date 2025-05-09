class CoreRegistryService {}

enum CRSRequestType { Meta, Archive }

class CRSRequest {
  CRSRequestType requestType = CRSRequestType.Meta;
}

class CRSResponse {}

class CRSException implements Exception {}
