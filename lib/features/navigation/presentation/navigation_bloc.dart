import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_event.dart';
import 'package:services_marketplace_mobile/features/navigation/presentation/navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState(isProviderMode: false, selectedIndex: 0)) {
    
    on<ToggleUserMode>((event, emit) {
      // Al cambiar de modo, reseteamos el índice a 0 para evitar errores de rango
      emit(state.copyWith(
        isProviderMode: !state.isProviderMode,
        selectedIndex: 0, 
      ));
    });

    on<ChangeTab>((event, emit) {
      emit(state.copyWith(selectedIndex: event.index));
    });
  }
}