import Combine
import StaticPublished

struct Example {
    @StaticPublished
    static var input: Int = 10
}

var cancellable = Set<AnyCancellable>()
Example.inputPublisher.sink { newValue in
    print("receive \(newValue)")
}.store(in: &cancellable)
