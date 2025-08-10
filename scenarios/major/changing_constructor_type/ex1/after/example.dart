// Simple example demonstrating a class with a constructor changed to factory
library example;

/// A base class with a constructor changed to factory
class Widget {
  final String id;
  final bool visible;

  /// Changed to a factory constructor - MAJOR breaking change
  factory Widget({required String id, bool visible = true}) {
    print('Creating widget $id');
    return _WidgetImpl(id: id, visible: visible);
  }
}

/// Private implementation class
class _WidgetImpl implements Widget {
  @override
  final String id;

  @override
  final bool visible;

  _WidgetImpl({required this.id, this.visible = true});
}

/// A subclass that extends Widget
/// This will now fail to compile - MAJOR breaking change
// class Button extends Widget {
//   final String label;
//
//   // Error: Can't use 'super' with a factory constructor
//   Button({required String id, required this.label, bool visible = true})
//       : super(id: id, visible: visible) {
//     print('Creating button with label: $label');
//   }
// }

/// Usage example
void main() {
  final widget = Widget(id: 'widget1');
  print('Widget created: ${widget.id}');

  // Can no longer create Button that extends Widget
}
