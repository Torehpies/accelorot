class Result<T, E> {
	final T? value;
	final E? error;

	const Result.success(T data) : value = data, error = null;
	const Result.failure(E failure) : value = null, error = failure;
}
