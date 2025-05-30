/// A base interface for the [AsyncIterator] protocol
/// 
/// This is based on
import 'dart:async';
import 'dart:js_interop';

@JS('AsyncIterator')
extension type JSAsyncIterator<T extends JSAny>._(JSObject _) implements JSObject {
  external JSPromise<JSAsyncIteratorReturn<T>> next([T value]);
  @JS('return')
  external JSPromise<JSAsyncIteratorReturn<T>> $return([T value]);
}

extension ToDartStreamIterator<T extends JSAny> on JSAsyncIterator<T> {
  StreamIterator<T> get toDart => JSStreamIterator<T>(this);
  Stream<T> get toDartStream => streamFromIterator(toDart);
}



class JSStreamIterator<T extends JSAny> implements StreamIterator<T> {
  JSAsyncIterator<T> iterator;

  bool isDone = false;
  T? _currentValue;

  JSStreamIterator(this.iterator);
  
  @override
  Future cancel() {
    return iterator.$return().toDart;
  }
  
  @override
  // TODO: implement current
  T get current {
    if (isDone) {
      throw Exception('Stream Iterator Done');
    } else if (_currentValue == null) {
      throw Exception('No value');
    } else {
      return _currentValue!;
    } 
  }
  
  @override
  Future<bool> moveNext() async {
    final value = await (iterator.next().toDart);
    if (value.done) {
      _currentValue = null;
      isDone = true;
    } else {
      _currentValue = value.value;
    }
    return !(value.done);
  }
}

Stream<T> streamFromIterator<T>(StreamIterator<T> iterator) async* {
  while (await iterator.moveNext()) {
    yield iterator.current;
  }
}

/// The only method not implemented is `AsyncGenerator.throw`, as JS Errors are not implemented...
@JS('AsyncGenerator')
extension type JSAsyncGenerator<T extends JSAny>._(JSObject _) implements JSAsyncIterator {
  
}

extension type JSAsyncIteratorReturn<T extends JSAny>._(JSObject _) implements JSObject {
  external JSAsyncIteratorReturn({bool done, T value});
  external bool get done;
  external T get value;
}

