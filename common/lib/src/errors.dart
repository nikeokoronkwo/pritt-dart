class RequestError {
  int errorCode = 500;
}

class UnauthorizedError extends RequestError {
  int errorCode = 401;
}

class ServerError extends RequestError {}
