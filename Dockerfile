# **************************************************************************** #
#                            SIMPLE DOCKERFILE                                   #
# **************************************************************************** #

# 1. Use an official lightweight base image.
# We choose Alpine Linux for its small footprint.
FROM alpine:3.15

# 2. Set an environment variable for the message.
ENV MESSAGE="Hello, Docker!"

# 3. Command to run when the container starts.
# Here we use the shell to print the message.
CMD ["/bin/sh", "-c", "echo $MESSAGE"]
