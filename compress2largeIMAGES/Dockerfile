FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    libjpeg-turbo-progs \
    exiftool \
    coreutils \
    findutils \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy the optimizer script
COPY inplace_jpg_optimizer.sh /app/inplace_jpg_optimizer.sh

# Make the script executable
RUN chmod +x /app/inplace_jpg_optimizer.sh

# Set default environment variables
ENV PROCESS_DIR=/workdir
ENV JPEG_QUALITY=85

# Create a new user and group
RUN groupadd -r myuser && useradd -r -g myuser myuser

# Set permissions for the working directory (if needed)
RUN mkdir -p /workdir && chown -R myuser:myuser /workdir

# Switch to the newly created user
USER myuser

# Set the script as the default command
CMD ["/app/inplace_jpg_optimizer.sh"]
