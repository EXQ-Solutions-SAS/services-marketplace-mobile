class NavigationState {
  final bool isProviderMode;
  final int selectedIndex;

  NavigationState({
    required this.isProviderMode,
    required this.selectedIndex,
  });

  // Helper para copiar el estado sin perder datos
  NavigationState copyWith({bool? isProviderMode, int? selectedIndex}) {
    return NavigationState(
      isProviderMode: isProviderMode ?? this.isProviderMode,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}