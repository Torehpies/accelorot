class EmailVerifyState {
  final bool isVerified;
  final bool isResending;
  final int resendCooldown;
  final int dashboardCountdown;

  const EmailVerifyState({
    this.isVerified = false,
    this.isResending = false,
    this.resendCooldown = 0,
    this.dashboardCountdown = 3,
  });

  EmailVerifyState copyWith({
    bool? isVerified,
    bool? isResending,
    int? resendCooldown,
    int? dashboardCountdown,
  }) {
    return EmailVerifyState(
      isVerified: isVerified ?? this.isVerified,
      isResending: isResending ?? this.isResending,
      resendCooldown: resendCooldown ?? this.resendCooldown,
      dashboardCountdown: dashboardCountdown ?? this.dashboardCountdown,
    );
  }
}
