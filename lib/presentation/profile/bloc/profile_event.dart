part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class GetProfile extends ProfileEvent {}

class CreateProfile extends ProfileEvent {
  final Map<String, dynamic> itemData;
  CreateProfile({required this.itemData});
}
