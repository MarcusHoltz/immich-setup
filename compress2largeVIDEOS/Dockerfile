FROM ubuntu

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    exiftool \
    coreutils \
    findutils \
    ffmpeg \    
    bash \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy the optimizer script
COPY inplace_mp4_optimizer.sh /app/inplace_mp4_optimizer.sh

# Make the script executable
RUN chmod +x /app/inplace_mp4_optimizer.sh

# Set default environment variables
ENV PROCESS_DIR=/workdir

# Create a new user and group
RUN groupadd -r myuser && useradd -r -g myuser myuser

# Set permissions for the working directory (if needed)
RUN mkdir -p /workdir && chown -R myuser:myuser /workdir

# Switch to the newly created user
USER myuser

# Set the script as the default command
CMD ["/app/inplace_mp4_optimizer.sh"]
