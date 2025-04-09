import Hummingbird
import Logging
import PostgresNIO
import ServiceLifecycle

func buildApplication(
    _ config: some ServerConfiguration
) async throws -> some ApplicationProtocol {
    
    var logger = Logger(label: "Server")
    logger.logLevel = .trace

    let env = Environment()
    let host = env.get("DATABASE_HOST")!
    let port = env.get("DATABASE_PORT", as: Int.self)!
    let user = env.get("DATABASE_USER")!
    let pass = env.get("DATABASE_PASSWORD")!
    let db = env.get("DATABASE_NAME")!
    let rootCertPath = env.get("ROOT_CERT_PATH")!
    
    // Disables client-side certificate verification, making the connection vulnerable to MITM attacks
    // or malicious servers. While SSL/TLS encryption remains, without proper verification, the connection
    // cannot be trusted.
    //        var tlsConfig = TLSConfiguration.makeClientConfiguration()
    //        tlsConfig.certificateVerification = .none
    
    // Properly configure TLS to ensure secure communication by loading a trusted root certificate.
    // This prevents potential MITM attacks and ensures the server's authenticity.
    // The root certificate is loaded from the specified PEM file and used as the trust anchor.
    var tlsConfig = TLSConfiguration.makeClientConfiguration()
    let rootCert = try NIOSSLCertificate.fromPEMFile(rootCertPath)
    tlsConfig.trustRoots = .certificates(rootCert)
    tlsConfig.certificateVerification = .fullVerification
    
    let client = PostgresClient(
        configuration: .init(
            host: host,
            port: port,
            username: user,
            password: pass,
            database: db,
            tls: .require(tlsConfig)
        ),
        backgroundLogger: logger
    )
    let postgresRepository = TodoPostgresRepository(
        client: client,
        logger: logger
    )
    
    let controller = TodoController(
        repository: postgresRepository
    )
    
    let router = Router()
    router.add(middleware: LogRequestsMiddleware(.info))
    
    router.get("/") { _, _ in
        "Hello, world!\n"
    }
    controller.addRoutes(
        to: router.group("todos")
    )

    var app = Application(
        router: router,
        configuration: .init(
            address: .hostname(
                config.hostname,
                port: config.port
            )
        ),
        logger: logger
    )
    
    app.addServices(postgresRepository.client)
    app.beforeServerStarts {
        try await postgresRepository.createTable()
    }
    
    return app
}
