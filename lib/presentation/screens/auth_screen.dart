import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:media_player/core/core.dart';
import 'package:media_player/presentation/cubits.dart';
import 'package:media_player/presentation/router/route_names.dart';
import 'package:media_player/presentation/utils/responsive_extensions.dart';
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
    final horizontalPadding = context.w(0.07).clamp(16.0, 36.0);
    final verticalPadding = context.h(0.02).clamp(12.0, 24.0);
    final fieldSpacing = context.h(0.016).clamp(10.0, 16.0);
    final checkboxSize = context.iconSize(20);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(RouteNames.dashboard);
          context.read<NavigationCubit>().navigateTo(AppScreen.dashboardGrid);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(fontSize: context.sp(13)),
              ),
              backgroundColor: AppColors.accentCoral,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textLight,
              size: context.iconSize(20),
            ),
            onPressed: () {
              context.go(RouteNames.welcome);
              context.read<NavigationCubit>().navigateTo(AppScreen.welcome);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: BlocBuilder<AuthFormCubit, AuthFormState>(
              builder: (context, formState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: context.h(0.018).clamp(10.0, 20.0)),

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
                                    fontSize: context.sp(16),
                                    fontWeight: formState.isLoginTab
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: context.h(0.008).clamp(4.0, 8.0),
                                ),
                                // Justified exception: 2px tab underline indicator
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
                                    fontSize: context.sp(16),
                                    fontWeight: !formState.isLoginTab
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  height: context.h(0.008).clamp(4.0, 8.0),
                                ),
                                // Justified exception: 2px tab underline indicator
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
                    SizedBox(height: context.h(0.04).clamp(20.0, 40.0)),

                    // Name field (shown on Sign Up)
                    if (!formState.isLoginTab) ...[
                      CommonTextField(
                        hintText: 'Name',
                        onChanged: (val) =>
                            context.read<AuthFormCubit>().updateName(val),
                      ),
                      SizedBox(height: fieldSpacing),
                    ],

                    // Email field
                    CommonTextField(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) =>
                          context.read<AuthFormCubit>().updateEmail(val),
                    ),
                    SizedBox(height: fieldSpacing),

                    // Phone number field
                    CommonTextField(
                      hintText: 'Phone number',
                      keyboardType: TextInputType.phone,
                      onChanged: (val) =>
                          context.read<AuthFormCubit>().updatePhone(val),
                    ),
                    SizedBox(height: fieldSpacing),

                    // Password field
                    CommonTextField(
                      hintText: 'Password',
                      obscureText: true,
                      onChanged: (val) =>
                          context.read<AuthFormCubit>().updatePassword(val),
                    ),
                    SizedBox(height: fieldSpacing),

                    // Confirm password field
                    CommonTextField(
                      hintText: 'Confirm password',
                      obscureText: true,
                      onChanged: (val) => context
                          .read<AuthFormCubit>()
                          .updateConfirmPassword(val),
                    ),
                    SizedBox(height: context.h(0.032).clamp(18.0, 32.0)),

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
                    SizedBox(height: context.h(0.022).clamp(12.0, 24.0)),

                    // Checkbox terms: "Lorem ipsum dolor"
                    GestureDetector(
                      onTap: () => context.read<AuthFormCubit>().toggleTerms(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: checkboxSize,
                            height: checkboxSize,
                            decoration: BoxDecoration(
                              color: formState.termsAccepted
                                  ? AppColors.accentCoral
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              // Justified exception: 1.5 border width
                              border: Border.all(
                                color: formState.termsAccepted
                                    ? AppColors.accentCoral
                                    : AppColors.textSecondary,
                                width: 1.5,
                              ),
                            ),
                            child: formState.termsAccepted
                                ? Icon(
                                    Icons.check,
                                    size: context.iconSize(14),
                                    color: AppColors.textLight,
                                  )
                                : null,
                          ),
                          SizedBox(width: context.w(0.025).clamp(6.0, 14.0)),
                          Text(
                            'Lorem ipsum dolor',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textLight,
                              fontSize: context.sp(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(0.025).clamp(14.0, 28.0)),
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
