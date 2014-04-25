behaviors.dart
==============

Behaviors are a way to attach new functionality to DOM elements which match
certain CSS selectors.

Behaviors are encapsulated, reusable bits of functionality. They interact with
elements via public APIs - listening to events and reading and writing
properties. Examples of behaviors include selectability, drag and drop,
or input validation.

`Behavior` is the interface or base class for Behaviors. It has a named
constructor `Behavior.attach` that takes the element the behavior is attached
to. It then has a single method `detach` that's called when the behavior should
clean up.
 
`registerBehavior` registers a CSS selector with a `BehaviorFactory` function
for a specific node. Using the active_query package, the node is monitored for
changes, and when an element matches the selector a new behavior instance is
created with the factory. When an element is removed or changed so that it no
longer matches the selector, the behavior is detached.

`getBehaviors` returns all the behaviors currently attached to a node.

See the example folder for more.
