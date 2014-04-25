// Copyright 2014 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library behaviors;

import 'dart:html';

import 'package:active_query/active_query.dart';

/**
 * Interface or base class for Behaviors.
 */
abstract class Behavior<E extends Element> {
  E _element;

  Behavior(this._element);

  /**
   * The [Element] this behavior is attached to.
   */
  E get element => _element;

  /**
   * Called when a Behavior should detach itself from [element].
   *
   * The behavior should remove any listeners and attempt to reset any state it
   * modified that doesn't make sense when the behavior is detached, for
   * instance classes that it added.
   */
  void detach() {
    _element = null;
  }
}

/**
 * A interface for functions that create Behaviors.
 *
 * Factories will usually just wrap a constructor, like:
 * `MovableBehavior movableFactory(e) => new MovableBehavior(e);`
 *
 * If you are using behaviors with a dependency injection container you can use
 * a partial injection pattern to have the container produce instances:
 *
 *     var factory = injector.invoke((A a, B b) =>
 *         (Element e) => new MyBehavior(a, b, e));
 *     registerBehavior('[my-behavior]', factory);
 */
typedef Behavior BehaviorFactory(Element element);

final Expando<Set<_BehaviorRegistration>> _behaviors
    = new Expando<Set<_BehaviorRegistration>>();

class _BehaviorRegistration {
  final String selector;
  final Behavior behavior;
  _BehaviorRegistration(this.selector, this.behavior);
}

/**
 * Registers [factory] to create new [Behavior] instances whenever descendent
 * elements in [node] match [selector].
 */
registerBehavior(String selector, BehaviorFactory factory, {Node node}) {
  var query = activeQuery(selector, node: node);

  query.added.listen((Element e) {
    var behavior = factory(e);
    if (_behaviors[e] == null) {
      _behaviors[e] = new Set<_BehaviorRegistration>();
    }
    _behaviors[e].add(new _BehaviorRegistration(selector, behavior));
  });

  query.removed.listen((Element e) {
    var registrations = _behaviors[e];
    if (registrations != null) {
      var detachedRegistrations = [];
      for (_BehaviorRegistration registration in registrations) {
        if (registration.selector == selector) {
          detachedRegistrations.add(registration);
        }
      }
      for (var registration in detachedRegistrations) {
        registration.behavior.detach();
        registrations.remove(registration);
      }
    }
  });
}

List<Behavior> getBehaviors(Node node) {
  var behaviors = _behaviors[node];
  return behaviors == null ? <Behavior>[] : behaviors.map((r) => r.behavior);
}
