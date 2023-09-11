import Foundation

public extension RequestModifier {

    static func path(_ path: String) -> RequestModifier {
        .init {
            $0.url = $0.url?.appendingPathComponent(path)
        }
    }
}
