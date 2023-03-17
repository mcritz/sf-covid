enum Status: CustomStringConvertible {
    case pristine
    case loading
    case ready
    case error
    
    var description: String {
        switch self {
        case .loading:
            return "Loading…"
        case .error:
            return "Error"
        case .pristine:
            return "Hello"
        case .ready:
            return "Ready"
        }
    }
}
