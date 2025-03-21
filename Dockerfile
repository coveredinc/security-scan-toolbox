# Use the latest Alpine image as the base
FROM alpine:latest AS build
ENV SBOM_URL="https://amazon-inspector-sbomgen.s3.amazonaws.com/1.6.3/linux/amd64/inspector-sbomgen.zip"
ENV TRIVY_URL="https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.tar.gz"
ENV INSTALL_DIR="/usr/local/bin"
RUN apk update && apk add --no-cache bash zip curl
RUN curl -LO "$SBOM_URL" && \
    unzip inspector-sbomgen.zip && \
    mv ./inspector-sbomgen-1.6.3/linux/amd64/* . && \
    chmod +x inspector-sbomgen && \
    mv inspector-sbomgen "$INSTALL_DIR/"
RUN curl -LO "$TRIVY_URL" && \
    tar -xvf trivy_0.18.3_Linux-64bit.tar.gz && \
    chmod +x trivy && \
    mv trivy "$INSTALL_DIR/"
FROM scratch
COPY --from=build /usr/local/bin/inspector-sbomgen /bin/inspector-sbomgen
COPY --from=build /usr/local/bin/trivy /bin/trivy
COPY ./security-toolbox /usr/bin/security-toolbox
WORKDIR /project
ENTRYPOINT ["security-toolbox"]
CMD ["--help"]