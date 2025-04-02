# Build stage using a Swift image with version 6.0.3-noble
FROM swift:6.1-noble AS build

# Set the working directory for building the Swift application
WORKDIR /build

# Copy package manifest files to leverage Docker cache during dependency resolution
COPY ./Package.* ./

# Resolve and download package dependencies
RUN swift package resolve

# Copy the rest of the Swift project source files
COPY ./ .

# Build the Swift application in release mode with a static Swift standard library
RUN swift build -c release --static-swift-stdlib 

# Switch working directory to a staging area for assembling the final artifacts
WORKDIR /staging

# Copy the compiled executable from the build output into the staging directory
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Server" ./

# Copy the swift-backtrace-static tool, used for improved backtraces in Swift binaries
RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./

# Find and copy all resource directories from the build output into the staging directory
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

# Final stage based on an Ubuntu image with the 'noble' tag
FROM ubuntu:noble

# Update package lists, upgrade packages, and clean up to reduce image size
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && rm -r /var/lib/apt/lists/*

# Create a dedicated system user 'hummingbird' with its home directory at /app
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app hummingbird

# Set the working directory to the application directory
WORKDIR /app

# Copy the staging files from the build stage into /app and set proper ownership
COPY --from=build --chown=hummingbird:hummingbird /staging /app

# Copy additional SSL certificate files needed for the application
COPY docker/certificates/ca.pem /app/
# COPY ./eu-central-1-bundle.pem /app/

# Set an environment variable to configure Swift backtraces for debugging
ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

# Switch to the non-root 'hummingbird' user for security
USER hummingbird:hummingbird

# Expose the port on which the application will listen
EXPOSE 8080

# Define the entrypoint to run the 'Todos' executable and default command-line arguments
ENTRYPOINT ["/app/Server"]
CMD ["--hostname", "0.0.0.0", "--port", "8080"]
