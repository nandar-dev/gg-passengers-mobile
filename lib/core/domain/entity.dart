import 'package:equatable/equatable.dart';

abstract class Entity extends Equatable {
  const Entity();

  @override
  List<Object?> get props => [];
}

/// Represents a generic result with success or failure
sealed class Result<T> with EquatableMixin {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Failure(:final message) => failure(message),
    };
  }

  @override
  List<Object?> get props => [];
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;

  const Failure(
    this.message, {
    this.exception,
  });

  @override
  List<Object?> get props => [message, exception];
}
