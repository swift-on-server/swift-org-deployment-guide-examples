import ArgumentParser
import Hummingbird
import Logging
import PostgresNIO
import ServiceLifecycle

@main
struct Entrypoint: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

//    @Flag
    var inMemoryTesting: Bool = false

    func run() async throws {
        // create application
        let app = try await buildApplication(self)
        // run application
        try await app.runService()
    }
}

extension Entrypoint: ServerConfiguration {}


