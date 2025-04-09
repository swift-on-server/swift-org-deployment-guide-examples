FROM swift:6.1-noble AS build
WORKDIR /build
COPY ./Package.* ./
RUN swift package resolve
COPY ./ .
RUN swift build -c release --static-swift-stdlib
WORKDIR /staging
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Server" ./
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

FROM ubuntu:noble
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -r /var/lib/apt/lists/*
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app hummingbird
WORKDIR /app

COPY --from=build --chown=hummingbird:hummingbird /staging /app

# Copy additional SSL certificate files needed for the application
COPY ./docker/server/eu-central-1-bundle.pem /app/

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static
USER hummingbird:hummingbird
EXPOSE 8080
ENTRYPOINT ["/app/Server"]
CMD ["--hostname", "0.0.0.0", "--port", "8080"]
