---
layout: post
title: "Undocumented secrets of $scope.$watch"
description: "A look at the angular source code reveals some nifty tricks that border on Functional Reactive Programming."
category: articles
tags: [angular, javascript, functional reactive programming, frp]
image:
  feature: post.cowboy-hat.jpg
---

### The $scope.$watch() you know and love

Most angular devs I've talked to use `$scope.$watch` sparingly and as advertised: for DOM manipulation inside directives.

{% highlight js %}
/* inside custom directive */
$scope.$watch('prop', function(newVal, oldVal, scope){
  // update the DOM
});
{% endhighlight %}

For the unfamiliar, each time `$scope.prop` changes, our callback gets invoked and updates the DOM. This is, in fact, the same API that angular uses to implement one direction of its two-way data binding.

### The $scope.$watch() that sneaks out at night

What most devs don't know is that `$scope.$watch` takes an *expression*, not just a property name.

{% highlight js %}
$scope.$watch('lions && tigers && bears || my = head, isGoingToExplode()', ...);
{% endhighlight %}

After you pick your jaw up off the floor, take a look at the powerful subset of JavaScript expressions that `$watch` suports:

* array access: `myArr[idx]`
* dot access: `myObj.prop`
* logical, comparison, and ternary operators: `you > excited || vulcan`
* function invocation: `noWay(), unpossible()`
* assignment: `thatIs = "just wow"`

So, `$scope.$watch` has a pretty sweet API, but, if you're like most devs, you don't use it all that often, so... what? Well, consider the consequences of using a an isolated `$scope` object as the base class for your models: functional reactive programming[^1]. For example, let's say we have a widget whose save button we show only if it has been edited and is selected:

{% highlight js %}
$widget = $rootScope.new(true);
// ... widget-y stuff
$widget.$watch('edited', function(newEditedVal, oldVal, widget){
    widget.showSaveButton = newEditedVal && widget.selected;
});
{% endhighlight %}

We can use `$watch` to define a model property in terms of other model properties such that we don't ever have to think about that property again&mdash;unless we want to change its definition, but *not* if we add features that change its dependent properties[^2]. Cool, but cumbersome.

What if it were as simple as saying: `net <~ revenue - expenses`? `net` should *always* reflect the value of `revenue - expenses`, and it should do so without forcing the developer into, e.g., an awkward setter pattern or compiling Haskell to JavaScript.

### The $scope.$watch() that will haunt your dreams


![Cyriak, Christmas 2012](/images/post.cyriak-christmas.gif)

Merry Christmas.

{% highlight js %}
$widget = $rootScope.new(true);
// ...
$widget.$watch('edited && selected', 'showSaveButton = edited && selected');
{% endhighlight %}

WAT. While not nearly as elegant as our pure-bred `net` example, here we see our pony `$watch` accepting *another expression* as its second argument, which brings us a step closer to the FRP ideal of expressing relationships instead of operations[^3].

How did I discover this? On accident, reading the source, after I'd implemented the same feature by monkey-patching `$watch` using angular's `$parse` service. But that's [another story](/articles/monkey-patching-ng-scope-watch) in which `$watch` gets a pretty serious face-lift, including `$watch(...).once(), $watch(...).times(n)`, and`$scope.$if`.


[^1]: For FRP-realsies, check out [Bacon](https://github.com/baconjs/bacon.js), [Elm](http://elm-lang.org/), or [RxJS](https://github.com/Reactive-Extensions/RxJS).
[^2]: This is the main draw of FRP over procedural programming&mdash;by saying *what* you want rather than *how* you want it done, you save yourself from, e.g., the possibility of forgetting to update `showSaveButton` when you add a feature that manipulates the `edited` property.
[^3]: Again, this is FRP (relationships) vs procedural (operations). FRP leverages higher-level abstractions, reducing the developer's opportunities to introduce bugs.
