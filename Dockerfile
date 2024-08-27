# This stage will compile sources to get the build folder
FROM dart:stable AS build

# Install the dart_frog cli from pub.dev
RUN dart pub global activate dart_frog_cli

# Set the working directory
WORKDIR /app

# Copy Dependencies in our working directory
COPY pubspec.* /app/
COPY routes /app/routes
# Uncomment the following line if you are serving static files.
# COPY --from=build public /app/public

# Add all of your custom directories here, for example if you have a "models" directory:
# COPY models /app/models

# Get dependencies
RUN dart pub get

# 📦 Create a production build
RUN dart_frog build

# Compile the server to get the executable
RUN dart compile exe /app/build/bin/server.dart -o /app/build/bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/build/bin/server /app/bin/server
# Uncomment the following line if you are serving static files.
# COPY --from=build /app/build/public /public/

# Expose the server port (useful for binding)
EXPOSE 8080

# Run the server
CMD ["/app/bin/server"]