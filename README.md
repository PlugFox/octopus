# [Octopus: A Declarative Router for Flutter](https://github.com/PlugFox/octopus/wiki)

[![Pub](https://img.shields.io/pub/v/octopus.svg)](https://pub.dev/packages/octopus)
[![Actions Status](https://github.com/PlugFox/octopus/actions/workflows/checkout.yml/badge.svg?branch=master)](https://github.com/PlugFox/octopus/actions/workflows/checkout.yml)
[![Example](https://github.com/PlugFox/octopus/actions/workflows/example-deploy-production.yml/badge.svg?branch=master)](https://octopus.plugfox.dev)
[![Coverage](https://codecov.io/gh/PlugFox/octopus/branch/master/graph/badge.svg)](https://codecov.io/gh/PlugFox/octopus)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Linter](https://img.shields.io/badge/style-linter-40c4ff.svg)](https://pub.dev/packages/linter)
[![GitHub stars](https://img.shields.io/github/stars/plugfox/octopus?style=social)](https://github.com/plugfox/octopus/)

Octopus is a declarative router for Flutter. Its main concept and distinction from other solutions is dynamic navigation through state mutations. It is a TRULY DECLARATIVE router, where you don’t change the state imperatively using push and pop commands. Instead, you (or the user) specify the desired outcome through state mutations or the address bar, and the router delivers a predictably expected result.

Most solutions use templating for navigation, pre-describing all possible router states with hardcoding (and code generation). While this is an expected and predictable approach in traditional BE SSR (where the page is assembled server-side), it has several serious drawbacks on the client side:

1. You cannot predict all possible states in advance.
2. There is no ability to implement routes of arbitrary depth (e.g., `/shop/category~id=1/category~id=12/category~id=123/product~id=1234`).
3. Understanding what happens in cases with nested routes can be quite complex.
4. Loss of state in nested routes, as such routers typically display only the active route, even though the nested state continues to exist.

What does the current solution offer?

1. Changing state through mutation.
2. Nested navigation, both through the out-of-the-box solution and your custom implementation.
3. A router state machine and case implementation based on state changes. For example, it’s very easy to implement breadcrumbs or integrate a tab/sidebar with router state arguments.
4. A history of states, allowing you to implement a time machine or, after reauthentication, return the user to where they started. Or simply log this for analytics purposes.
5. A user-friendly API with a "foolproof" design, where mutable states are clear and methods for changing them are provided, and immutable states are also clearly indicated.
6. A strong focus on Guards. Since the user can now obtain any desired configuration, you might want to "clip their wings." Ensure that the "Home" page is always at the root except for logged-out users, change states during navigation or upon reaching certain conditions, for example, showing login for unauthorized users. Recheck all navigation states on a specific event, just pass the subscription to your guard.
7. Implementation of dialogs through declarative navigation. No more showing dialogs from the navigator and mixing anonymous imperative dialogs with declarative navigation.
8. Preserve and display the entire navigation tree in the URL and deep links, not just the active route!
9. Clear debugging and the representation of the state as a string will simplify development.
10. Concurrency support a out of the box.

With a declarative approach, the only limit is your imagination!

---

## [Installation](https://github.com/PlugFox/octopus/wiki/Installation)

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  octopus: <version>
```

## [Get Started](https://github.com/PlugFox/octopus/wiki/Get-Started)

Set up your routes.
You can use an enum, make a few sealed classes, or both.
This doesn't matter. A recommended and simple way is to get started with enums.
Override a `builder` function to link your nodes and widgets.
Optionally, set up a "title" field for any route.

```dart
enum Routes with OctopusRoute {
  home('home', title: 'Home'),
  gallery('gallery', title: 'Gallery'),
  picture('picture', title: 'Picture'),
  settings('settings', title: 'Settings');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) =>
      switch (this) {
        Routes.home => const HomeScreen(),
        Routes.gallery => const GalleryScreen(),
        Routes.picture => PictureScreen(id: node.arguments['id']),
        Routes.settingsDialog => const SettingsDialog(),
      };
}
```

[Example](https://github.com/PlugFox/octopus/blob/master/example/lib/src/common/router/routes.dart)

Create an Octopus router instance.
During `main` initialization or state of the root `App` widget.
To do so, pass a list of all possible routes.
Optionally, set a `defaultRoute` as a route by default.

```dart
router = Octopus(
  routes: Routes.values,
  defaultRoute: Routes.home,
);
```

[Example](https://github.com/PlugFox/octopus/blob/master/example/lib/src/common/router/router_state_mixin.dart)

Add configuration from `Octopus.config` to the `WidgetApp.router` constructor.

```dart
MaterialApp.router(
  routerConfig: router.config,
)
```

[Example](https://github.com/PlugFox/octopus/blob/master/example/lib/src/common/widget/app.dart)

## [How to navigate](https://github.com/PlugFox/octopus/wiki/How-to-navigate)

Use the `context.octopus.setState((state) => ...)` method as a basic navigation method.

And realize any navigation logic inside the callback as you please.

```dart
context.octopus.setState((state) =>
  state
    ..findByName('catalog-tab')?.add(Routes.category.node(
      arguments: <String, String>{'id': category.id},
    )));
```

Of course, there are other ways to navigate, primarily shortcuts for the most common cases.

```dart
context.octopus.push(Routes.shop)
```

But you can truly do anything you want.
Just change the state, children, nodes, and arguments as you please.
Everything is in your hands and just works fine, that's a declarative approach as it should be.

## [Guards](https://github.com/PlugFox/octopus/wiki/Guards)

Guards are a powerful tool for controlling navigation.
They allow you to check the state of the router and mutate/cancel navigation if necessary.
For example, you can check the user's authorization and redirect them to the login page if they are not authorized.

Examples:

1. [How to make an authentification guard and restore the previous state after login](https://github.com/PlugFox/octopus/blob/master/example/lib/src/common/router/authentication_guard.dart)
2. [How to place a Home route at the root of the navigation stack](https://github.com/PlugFox/octopus/blob/master/example/lib/src/common/router/home_guard.dart)

## [Glossary](https://github.com/PlugFox/octopus/wiki/Glossary)

1. State - the overall state of the router can be mutable (while the user mutates the new desired state and in guards) or immutable (all other times). The state can include a hash table of arguments, which are global arguments of the current state. These can be used at your discretion.

2. Node - the components that constitute the state form a tree structure in the case of nested navigation. Each node has a name and arguments (usually parameters passed to a screen, like an identifier). At each level, within each list of nodes, the combination of name and arguments must be unique, as this forms the unique key of the node.

3. Route - router has a list of possible routes that can be used in the project. The router matches nodes and routes by their names. Routes contain information on how to construct a page for the navigator.

## [State structure](https://github.com/PlugFox/octopus/wiki/State-structure)

Let's take a look at the next nested tree which we want to get:

```
Home
Shop
├─Catalog-Tab
│ ├─Catalog
│ ├─Category {id: electronics}
│ ├─Category {id: smartphones}
│ └─Product {id: 3}
└─Basket-Tab
  ├─Basket
  └─Checkout
```

Also, we want the global argument `shop` with the value `catalog` to refer to a tab bar state.

Let's create the following state to represent our expectations:

```dart
final state = OctopusState(
  intention: OctopusStateIntention.auto,
  arguments: <String, String>{'shop': 'catalog'},
  children: <OctopusNode>[
    OctopusNode(
      name: 'home',
      arguments: <String, String>{},
      children: <OctopusNode>[],
    ),
    OctopusNode(
      name: 'shop',
      arguments: <String, String>{},
      children: <OctopusNode>[
        OctopusNode(
          name: 'catalog-tab',
          arguments: <String, String>{},
          children: <OctopusNode>[
            OctopusNode(
              name: 'catalog',
              arguments: <String, String>{},
              children: <OctopusNode>[],
            ),
            OctopusNode(
              name: 'category',
              arguments: <String, String>{'id': 'electronics'},
              children: <OctopusNode>[],
            ),
            OctopusNode(
              name: 'category',
              arguments: <String, String>{'id': 'smartphones'},
              children: <OctopusNode>[],
            ),
            OctopusNode(
              name: 'product',
              arguments: <String, String>{'id': '3'},
              children: <OctopusNode>[],
            ),
          ],
        ),
        OctopusNode(
          name: 'basket-tab',
          arguments: <String, String>{},
          children: <OctopusNode>[
            OctopusNode(
              name: 'basket',
              arguments: <String, String>{},
              children: <OctopusNode>[],
            ),
            OctopusNode(
              name: 'checkout',
              arguments: <String, String>{},
              children: <OctopusNode>[],
            ),
          ],
        ),
      ],
    ),
  ],
);
```

Take a look closer. That's a tree structure.
Each component of that tree has a `List<OctopusNode> children` for children nodes and arguments for the current node.
States have arguments, too; it's your global arguments.
Each node also has a name; by this name, you can identify this node and link it with your routes table.

If we try to represent this state as a location string, we get something like that:
`/home/shop/.catalog-tab/..catalog/..category~id=electronics/..category~id=smartphones/..product~id=3/.basket-tab/..basket/..checkout?shop=catalog`

## Changelog

Refer to the [Changelog](https://github.com/PlugFox/octopus/blob/master/CHANGELOG.md) to get all release notes.

## Maintainers

- [Matiunin Mikhail aka Plague Fox](https://plugfox.dev)

## Funding

If you want to support the development of our library, there are several ways you can do it:

- [Buy me a coffee](https://www.buymeacoffee.com/plugfox)
- [Support on Patreon](https://www.patreon.com/plugfox)
- [Subscribe through Boosty](https://boosty.to/plugfox)

We appreciate any form of support, whether it's a financial donation or just a star on GitHub. It helps us to continue developing and improving our library. Thank you for your support!

## [MIT License](https://opensource.org/licenses/MIT)
