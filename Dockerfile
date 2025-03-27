# Use the latest Alpine image as the base
FROM alpine:latest AS build
#TODO Include versions in build args
ENV SBOM_URL="https://amazon-inspector-sbomgen.s3.amazonaws.com/1.6.3/linux/amd64/inspector-sbomgen.zip"
ENV TRIVY_URL="https://github.com/aquasecurity/trivy/releases/download/v0.60.0/trivy_0.60.0_Linux-64bit.tar.gz"
ENV INSTALL_DIR="/usr/bin"
RUN apk update && apk add --no-cache bash zip curl
RUN curl -LO "$SBOM_URL" && \
    unzip inspector-sbomgen.zip && \
    mv ./inspector-sbomgen-1.6.3/linux/amd64/* . && \
    chmod +x inspector-sbomgen && \
    mv inspector-sbomgen "$INSTALL_DIR/"
RUN curl -LO "$TRIVY_URL" && \
    tar -xvf trivy_0.60.0_Linux-64bit.tar.gz && \
    chmod +x trivy && \
    mv trivy "$INSTALL_DIR/"
#trivy requires a cache directory
RUN trivy image --download-db-only
RUN mkdir -p /tmp && chmod 1777 /tmp

# Build a dispatcher
FROM golang:latest AS builder
WORKDIR /build
COPY ./dispatcher.go /build/
RUN CGO_ENABLED=0 GOOS=linux go build -o dispatcher dispatcher.go


# Use the scratch image as the base
FROM scratch
COPY --from=build /usr/bin/inspector-sbomgen usr/bin/inspector-sbomgen
COPY --from=build /usr/bin/trivy usr/bin/trivy
COPY --from=build /root/.cache/trivy /root/.cache/trivy
COPY --from=build /tmp /tmp
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build/dispatcher /usr/bin/dispatcher
WORKDIR /project
# Create a non-root user and switch to it
HEALTHCHECK --retries=1 CMD [ "dispatcher --help" ]
ENTRYPOINT ["dispatcher"]
CMD ["--help"]