import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let host = Environment.get("DATABASE_HOST") ?? "localhost"
    let port = Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber
    let user = Environment.get("DATABASE_USER")!
    let pass = Environment.get("DATABASE_PASSWORD")!
    let db = Environment.get("DATABASE_NAME")!
    let rootCertPath = Environment.get("ROOT_CERT_PATH")!
    
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
    
    app.databases.use(
        DatabaseConfigurationFactory.postgres(
            configuration: .init(
                hostname: host,
                port: port,
                username: user,
                password: pass,
                database: db,
                tls: .require(try .init(configuration: tlsConfig)))
        ),
        as: .psql
    )

    app.migrations.add(CreateTodo())

    // register routes
    try routes(app)
}
