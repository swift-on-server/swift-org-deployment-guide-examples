# Example projects for the deployment guides

This repository contains example projects for the swift.org deployment guides.

## hummingbird-docker

A basic Todo app written using the Hummingbird framework and a local PostgreSQL database. The app connects to the database using a secure connection.

```sh
# generate certificates and keys
cd hummingbird-docker/docker/certificates/
./generate.sh

cd ../..
# run the services
docker-compose up
```

## vapor-docker

A basic Todo app written using the Vapor framework and a local PostgreSQL database. The app connects to the database using a secure connection. 

```sh
# generate certificates and keys
cd vapor-docker/docker/certificates/
./generate.sh

cd ../..

# run the services
docker-compose up db server
# run migrations
docker-compose run migrations
```

## Notes

Re-configure database service:

```sh
docker compose down --volumes && docker compose up db --build db
```

Create a Todo using cURL:

```sh
curl -X POST http://localhost:8080/todos \
-H "Content-Type: application/json" \
-d '{"title": "Buy milk"}'
```
