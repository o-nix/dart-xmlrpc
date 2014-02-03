part of xmlrpc;


abstract class _ParamsIterationSupport extends IterableBase<Object> {
	List _params;

	Object operator [](int index) =>
		_params[index];

	void operator []=(int index, Object value) {
		_params[index] = value;
	}

	void addParam(Object param) {
		_params.add(param);
	}

	void setParams(List params) {
		_params = params;
	}

	void clear() {
		_params.clear();
	}

	@override
	int get length =>
		_params.length;
}

class _ParamsIterator implements Iterator<Object> {
	_ParamsIterationSupport _request;
	int _num = -1;

	_ParamsIterator(this._request);

	@override
	Object get current =>
	_request._params[_num];

	@override
	bool moveNext() {
		_num++;

		return _num < _request._params.length;
	}
}
