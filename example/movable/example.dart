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

library behavior.example.movable;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:behaviors/behaviors.dart';

class Movable extends Behavior {
  List<StreamSubscription> _subscriptions;
  bool _dragging = false;
  Point _offset;

  Movable(Element element) : super(element) {
    print("new Movable");
    var parent = element.offsetParent;

    _subscriptions = [
      element.onMouseDown.listen((event) {
        _dragging = true;
        _offset = element.offset.topLeft - event.client;
        element.classes.add('moving');
      }),
      parent.onMouseUp.listen((event) {
        _dragging = false;
        element.classes.remove('moving');
      }),
      parent.onMouseMove.listen((MouseEvent event) {
        if (_dragging) {
          element.style.left = '${event.client.x + _offset.x}px';
          element.style.top = '${event.client.y + _offset.y}px';
        }
      })];
  }

  detach() {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    super.detach();
  }
}

class Selectable extends Behavior {
  StreamSubscription _onClickSubscription;

  Selectable(Element element) : super(element) {
    _onClickSubscription = element.onClick.listen((event) {
      element.classes.toggle('selected');
    });
  }

  detach() {
    element.classes.remove('seleted');
    if (_onClickSubscription != null) {
      _onClickSubscription.cancel();
      _onClickSubscription = null;
    }
  }
}

@CustomTag('selectable-example')
class SelectableExample extends PolymerElement {
  SelectableExample.created() : super.created() {
    registerBehavior('[selectable]', (e) => new Selectable(e), node: this.shadowRoot);
  }
}

@CustomTag('movable-example')
class MovableExample extends PolymerElement {
  @published bool lock = false;

  MovableExample.created() : super.created() {
    registerBehavior('[movable]', (e) => new Movable(e), node: this.shadowRoot);
  }
}
