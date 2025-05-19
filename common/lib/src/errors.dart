class RequestError {
  int errorCode = 500;
}

class UnauthorizedError extends RequestError {
  @override
  int errorCode = 401;
}

class ServerError extends RequestError {}
