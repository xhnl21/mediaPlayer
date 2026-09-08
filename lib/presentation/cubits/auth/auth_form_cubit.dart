import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthFormState extends Equatable {
  const AuthFormState({
    this.isLoginTab = true,
    this.name = '',
    this.email = 'lorem@example.com',
    this.phone = '+1 555 019 2834',
    this.password = 'Password123!',
    this.confirmPassword = 'Password123!',
    this.termsAccepted = true,
  });

  final bool isLoginTab;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final bool termsAccepted;

  AuthFormState copyWith({
    bool? isLoginTab,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    bool? termsAccepted,
  }) {
    return AuthFormState(
      isLoginTab: isLoginTab ?? this.isLoginTab,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  @override
  List<Object?> get props => [
    isLoginTab,
    name,
    email,
    phone,
    password,
    confirmPassword,
    termsAccepted,
  ];
}

class AuthFormCubit extends Cubit<AuthFormState> {
  AuthFormCubit() : super(const AuthFormState());

  void setLoginTab(bool isLogin) {
    emit(state.copyWith(isLoginTab: isLogin));
  }

  void updateName(String name) => emit(state.copyWith(name: name));
  void updateEmail(String email) => emit(state.copyWith(email: email));
  void updatePhone(String phone) => emit(state.copyWith(phone: phone));
  void updatePassword(String password) =>
      emit(state.copyWith(password: password));
  void updateConfirmPassword(String confirmPassword) =>
      emit(state.copyWith(confirmPassword: confirmPassword));
  void toggleTerms() =>
      emit(state.copyWith(termsAccepted: !state.termsAccepted));
}
