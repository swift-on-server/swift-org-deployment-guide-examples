import Hummingbird
import Logging
import PostgresNIO
import ServiceLifecycle
@testable import Server

struct TestServerConfiguration: ServerConfiguration {
    let hostname = "127.0.0.1"
    let port = 8080
}

func buildTestApplication(
    _ config: some ServerConfiguration
) async throws -> some ApplicationProtocol {
    
    var logger = Logger(label: "Server")
    logger.logLevel = .trace
    
    let controller = TodoController(
        repository: TodoMemoryRepository()
    )
    
    let router = Router()
    router.add(middleware: LogRequestsMiddleware(.info))
    
    router.get("/") { _, _ in
        "Hello, world!\n"
    }
    controller.addRoutes(
        to: router.group("todos")
    )

    let app = Application(
        router: router,
        configuration: .init(
            address: .hostname(
                config.hostname,
                port: config.port
            )
        ),
        logger: logger
    )
    
    return app
}
