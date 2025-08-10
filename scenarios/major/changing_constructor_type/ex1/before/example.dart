// Simple example demonstrating a class with a generative constructor
library example;

/// A base class with a generative constructor
class Widget {
  final String id;
  final bool visible;

  /// This is a generative constructor
  Widget({required this.id, this.visible = true}) {
    print('Creating widget $id');
  }
}

/// A subclass that extends Widget and calls super() in its constructor
class Button extends Widget {
  final String label;

  Button({required String id, required this.label, bool visible = true})
      : super(id: id, visible: visible) {
    print('Creating button with label: $label');
  }
}

/// Usage example
// void main() {
//   final button = Button(id: 'btn1', label: 'Click me');
//   print('Button created: ${button.id}, ${button.label}');
// }
