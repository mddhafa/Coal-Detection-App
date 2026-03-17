import 'package:bloc/bloc.dart';
import 'package:coalmobile_app/data/model/response/profile_response_model.dart';
import 'package:coalmobile_app/repository/profile_repo.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<GetProfile>(_getProfile);
    on<CreateProfile>(_createProfile);
  }

  Future<void> _getProfile(GetProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    try {
      final response = await profileRepository.getProfile();

      emit(ProfileLoaded(data: response.data));
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }

  Future<void> _createProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final response = await profileRepository.updateProfile(event.itemData);

      if (response.data != null) {
        emit(ProfileSuccess(message: 'Profil berhasil dibuat!'));
        add(GetProfile()); // Refresh the profile after creation
      } else {
        emit(ProfileFailure(error: 'Gagal membuat profil'));
      }
    } catch (e) {
      emit(ProfileFailure(error: e.toString()));
    }
  }
}
