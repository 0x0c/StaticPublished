# StaticPublished

StaticPublished is Swift Macro to avoid boilerplate codes to observe changes of static variables.

```swift
import Combine
import StaticPublished

struct Example {
    // Adding @StaticPublished macro to observe changes of the static variable.
    @StaticPublished
    static var input: Int = 10
}

// @StaticPublished generates `static let inputPublisher: AnyPublisher<Int, Never>`
// and we can observe changes of `input`.
var cancellable = Set<AnyCancellable>()
Example.inputPublisher.sink { newValue in
    print("receive \(newValue)")
}.store(in: &cancellable)
```

`@StaticPublished` expands this code

```swift
@StaticPublished
static var input: Int = 0
```

to below.
```swift
static var input: Int = 0 {
    didSet {
        _inputSubject.send(input)
    }
}

private static let _inputSubject = PassthroughSubject<Int, Never>()

static let inputPublisher = _inputSubject.eraseToAnyPublisher()
```