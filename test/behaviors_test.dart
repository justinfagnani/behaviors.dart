library behaviors_test;

import 'dart:async';
import 'dart:html';
import 'package:behaviors/behaviors.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart'
    show useHtmlEnhancedConfiguration;

// was going to use package:mock, but it's not working
class TestBehavior extends Behavior {

  TestBehavior(Element e) : super(e);

  detach() {
    super.detach();
  }
}

main() {

  useHtmlEnhancedConfiguration();

  group('registerBehavior', () {
    var testDiv = querySelector('#test-div');

    setUp(() {
      testDiv.children.clear();
    });

    test('should send an event when an element matches a query', () {
      int factoryCallCount = 0;
      var behavior;
      registerBehavior('.test', (e) {
        print("factory!");
        factoryCallCount++;
        return behavior = new TestBehavior(e);
      }, node: testDiv);
      var e = new DivElement()..classes.add('test');
      testDiv.children.add(e);
      return new Future(() {
        expect(factoryCallCount, 1);
        expect(behavior.element, e);
        e.classes.remove('test');
        return new Future(() {
          expect(behavior.element, null);
        });
      });
    });


  });

}