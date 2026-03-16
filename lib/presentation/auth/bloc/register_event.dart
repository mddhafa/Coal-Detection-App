part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterRequest extends RegisterEvent {
  final RegisterRequestModel requestModel;

  RegisterRequest({required this.requestModel});
}
