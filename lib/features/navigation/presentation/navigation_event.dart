abstract class NavigationEvent {}
class ToggleUserMode extends NavigationEvent {} // El que cambia el Switch
class ChangeTab extends NavigationEvent {       // El que cambia el índice del BottomBar
  final int index;
  ChangeTab(this.index);
}