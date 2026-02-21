import 'package:bloc/bloc.dart';
import 'package:coalmobile_app/data/model/request/login_request_model.dart';
import 'package:coalmobile_app/data/model/response/login_response_model.dart';
import 'package:coalmobile_app/repository/authrepo.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Authrepo authrepo;

  LoginBloc({required this.authrepo}) : super(LoginInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    final result = await authrepo.login(event.requestModel);

    result.fold(
      (l) => emit(LoginFailure(error: l)),
      (r) => emit(LoginSuccess(responseModel: r)),
    );
  }
}
