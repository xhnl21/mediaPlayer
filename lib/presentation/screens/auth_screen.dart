import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/widgets.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthFormCubit(),
      child: const _AuthView(),
    );
  }
}

class _AuthView extends StatelessWidget {
  const _AuthView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.read<NavigationCubit>().navigateTo(AppScreen.profile);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.accentCoral,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 20.0,
            ),
            child: BlocBuilder<AuthFormCubit, AuthFormState>(
              builder: (context, formState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Top Tab Switcher: "LOG IN" | "SIGN UP"
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                context.read<AuthFormCubit>().setLoginTab(true),
                            child: Column(
                              children: [
                                Text(
                                  'LOG IN',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: formState.isLoginTab
                                        ? AppColors.textLight
                                        : AppColors.textSecondary.withValues(
                                            alpha: 0.6,
                                          ),
                                    fontWeight: formState.isLoginTab
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 2,
                                  color: formState.isLoginTab
                                      ? AppColors.textLight
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context
                                .read<AuthFormCubit>()
                                .setLoginTab(false),
                            child: Column(
                              children: [
                                Text(
                                  'SIGN UP',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: !formState.isLoginTab
                                        ? AppColors.textLight
                                        : AppColors.textSecondary.withValues(
                                            alpha: 0.6,
                                          ),
                                    fontWeight: !formState.isLoginTab
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 2,
                                  color: !formState.isLoginTab
                                      ? AppColors.textLight
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // Name field (shown on Sign Up)
                    if (!formState.isLoginTab) ...[
                      CommonTextField(
                        hintText: 'Name',
                        onChanged: (val) =>
                            context.read<AuthFormCubit>().updateName(val),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Email field
                    CommonTextField(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) =>
                          context.read<AuthFormCubit>().updateEmail(val),
                    ),
                    const SizedBox(height: 14),

                    // Phone number field
                    CommonTextField(
                      hintText: 'Phone number',
                      keyboardType: TextInputType.phone,
                      onChanged: (val) =>
                          context.read<AuthFormCubit>().updatePhone(val),
                    ),
                    const SizedBox(height: 14),

                    // Password field
                    CommonTextField(
                      hintText: 'Password',
                      obscureText: true,
                      onChanged: (val) =>
                          context.read<AuthFormCubit>().updatePassword(val),
                    ),
                    const SizedBox(height: 14),

                    // Confirm password field
                    CommonTextField(
                      hintText: 'Confirm password',
                      obscureText: true,
                      onChanged: (val) => context
                          .read<AuthFormCubit>()
                          .updateConfirmPassword(val),
                    ),
                    const SizedBox(height: 28),

                    // Primary Coral Button: LOG IN or SIGN UP
                    CommonCoralButton(
                      text: formState.isLoginTab ? 'LOG IN' : 'SIGN UP',
                      onPressed: () {
                        if (formState.isLoginTab) {
                          context.read<AuthCubit>().login(
                            email: formState.email,
                            password: formState.password,
                          );
                        } else {
                          context.read<AuthCubit>().register(
                            name: formState.name.isEmpty
                                ? 'Lorem Name'
                                : formState.name,
                            email: formState.email,
                            phone: formState.phone,
                            password: formState.password,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Checkbox terms: "Lorem ipsum dolor"
                    GestureDetector(
                      onTap: () => context.read<AuthFormCubit>().toggleTerms(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: formState.termsAccepted
                                  ? AppColors.accentCoral
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: formState.termsAccepted
                                    ? AppColors.accentCoral
                                    : AppColors.textSecondary,
                                width: 1.5,
                              ),
                            ),
                            child: formState.termsAccepted
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: AppColors.textLight,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Lorem ipsum dolor',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
