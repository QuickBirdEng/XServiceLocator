# XServiceLocator

*"Craving for proper Dependency Injection?"*

<p align="center">
  <img src="https://github.com/quickbirdstudios/XServiceLocator/blob/master/XServiceLocator.jpeg">
</p>

# [![Build Status](https://travis-ci.com/quickbirdstudios/XServiceLocator.svg?branch=master)](https://travis-ci.com/quickbirdstudios/XServiceLocator) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/XServiceLocator.svg)](https://cocoapods.org/pods/XServiceLocator) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/XServiceLocator) [![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](https://github.com/quickbirdstudios/XServiceLocator) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/quickbirdstudios/XServiceLocator/blob/master/LICENSE)

XServiceLocator is a light-weight Swift library/framework for dynamically providing objects with the dependencies they need. The library is based on the Service Locator pattern. The idea is that objects get their dependencies from a certain store. XServiceLocator enables you to use [seamless dependency injection](https://quickbirdstudios.com/blog/swift-dependency-injection-service-locators/) throughout your iOS app without the need for any background magic.

## 🔩 Components

### 📦 Container

Stores the configuration on how to create instances of the registered types

### 🛠️ Resolver

Resolves the actual implementation for a type, by creating an instance of a class, using the configuration of the Container

### 🏭 ServiceFactory

A generic factory solution for creating instances of the generic type


## 🏃‍♀️ Getting started

### 🚶‍♀️ Basic steps

1. Register all of the types using any of the two `register` methods with the container.


```swift
let container = Container()
            .register(Int.self, instance: 10)
            .register(Double.self) { _ in 20 }
```

2. Wherever you need an instance of the type, you can access it using any of the two `resolve` methods of the `Resolver`. Let's first get the Resolver from the `Container` and then use the resolver to resolve the dependencies.

```swift
  let resolver = container.resolver

  let intValue = try! resolver.resolve(Int.self)
  let doubleValue: Double = try! resolver.resolve()
```

### 🎲 Custom Objects

You can also register custom types or instances for protocols, such as:

```swift
// Setting up

protocol Shape {
    var name: String { get }
}

class Circle: Shape {
    let name = "Circle"
    let radius: Double

    init(radius: Double) {
        self.radius = radius
    }

}

class Rectangle: Shape {
    let name = "Rectangle"
    let width: Double
    let height: Double

    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

struct Drawing {
    let shape: Shape
}

// Registering all the dependencies

let container = Container()
    .register(Shape.self, instance: Circle(radius: 10))
    .register(Circle.self) { _ in Circle(radius: 20) }
    .register(Rectangle.self, instance: Rectangle(width: 30, height: 15))
    .register(Drawing.self) { _ in
        let shape = Rectangle(width: 10, height: 5)
        return Drawing(shape: shape)
    }


// Resolving the dependencies

let resolver = container.resolver

let rectangle = try! resolver.resolve(Rectangle.self)
let shape = try! resolver.resolve(Shape.self)
let circle: Circle = try! resolver.resolve()
let drawing: Drawing = try! resolver.resolve()

// Accessing values

print(rectangle.name) // Rectangle
print(shape.name) // Circle
print(circle.name) // Circle
print(drawing.shape.name) // Rectangle

print("\(rectangle.width), \(rectangle.height)") // 30.0, 15.0
print((shape as! Circle).radius) // 10.0
print(circle.radius) // 20.0
```


### 🎩 Using already registered instances for subsequent registrations

```swift
// Registering all the dependencies
let container = Container()
    .register(Double.self, instance: 30)
    .register(Rectangle.self, instance: Rectangle(width: 10, height: 20))
    .register(Circle.self) { resolver in Circle(radius: try! resolver.resolve()) }


// Resolving the dependencies

let resolver = container.resolver

let circle: Circle = try! resolver.resolve()


// Accessing values

circle.radius // 30.0
```

## 👶 Using (Child) Dependency Resolver

A container can have another resolver as a dependency which can be used for resolution if the main resolver (container) fails to resolve the dependency.

```swift
// Registering all the dependencies

let dependency = Container()
            .register(Double.self, instance: 100)
            .register(Shape.self, instance: Rectangle(width: 10, height: 20))

let container = Container(dependency: dependency)
    .register(Rectangle.self, instance: Rectangle(width: 15, height: 7.5))


// Resolving the dependencies

let resolver = container.resolver

let shapeRectangle = try! resolver.resolve(Shape.self) as! Rectangle
let rectangle: Rectangle = try! resolver.resolve()
let doubleValue: Double = try! resolver.resolve()


// Accessing values

print("\(shapeRectangle.width), \(shapeRectangle.height)") // 10.0, 20.0
print("\(rectangle.width), \(rectangle.height)") // 15.0, 7.5
print(doubleValue) // 100
```

## 💪 Array of Resolvers

An array of resolvers also act as a resolver. As soon as any element of the array is able to resolve successfully, the object is returned.

```swift
// Registering all the dependencies

let container = Container()
    .register(Int.self, instance: 10)
    .register(Double.self, instance: 20)

let container1 = Container()
    .register(Float.self, instance: 30)
    .register(Double.self, instance: 50)

let arrayOfResolvers: Resolver = [
    container,
    container1,
]


// Resolving the dependencies
let intValue = try! arrayOfResolvers.resolve(Int.self)   // 10
let floatValue = try! arrayOfResolvers.resolve(Float.self)   // 30.0
let doubleValue = try! arrayOfResolvers.resolve(Double.self)   // 20.0
```

## ‍🤷‍♂️ Why the ServiceLocator pattern?
1. Loose coupling between classes/objects
2. Provides better testability
3. Provides extensibility. New instances can be easily registered and implementations can be switched without changing a lot.

## ‍🤔 Why XServiceLocator?
1. **Plug and Play**. Integrate the library and you are ready to go.  
2. **Supports Array of resolvers**. A combination of resolvers can be used for resolution of a type.
3. Supports registration and resolution of any type.
4. Developed and maintained by a group of developers who really care about the community and the quality of their solutions.
5. Everything is built using Swift only. No Objective-C legacy code.

## 🛠 Installation

#### CocoaPods

To integrate `XServiceLocator` into your Xcode project using CocoaPods, add this to your `Podfile`:

```ruby
pod 'XServiceLocator', '~> 1.0'
```

#### Carthage

To integrate `XServiceLocator` into your Xcode project using Carthage, add this to your `Cartfile`:

```
github "quickbirdstudios/XServiceLocator" ~> 1.0
```

Then run `carthage update`.

If this is your first time using Carthage in the project, you'll need to go through some additional steps as explained [over at Carthage](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

#### Swift Package Manager

See [this WWDC presentation](https://developer.apple.com/videos/play/wwdc2019/408/) about more information how to adopt Swift packages in your app.

Specify `https://github.com/quickbirdstudios/XServiceLocator.git` as the `XServiceLocator` package link.

#### Manually

If you prefer not to use any of the dependency managers, you can integrate `XServiceLocator` into your iOS project manually, by downloading the source code and placing the files in your project directory.  

## 👤 Author
This framework is created with ❤️ by [QuickBird Studios](https://quickbirdstudios.com).

## ❤️ Contributing

Open an issue if you need help, if you found a bug, or if you want to discuss a feature request.

Open a PR if you want to make changes to XServiceLocator.

## 📃 License

XServiceLocator is released under an MIT license. See [License.md](https://github.com/quickbirdstudios/XServiceLocator/blob/master/LICENSE) for more information.
