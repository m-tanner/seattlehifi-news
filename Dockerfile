# Stage 1: Build the React app
FROM node:20-alpine AS build

# Set environment variables for the build process
ARG REACT_APP_FRONTEND_BASE_URL

# Step 2: Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies for both React and Express
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the React app
RUN npm run build

# Stage 2: Set up the Express server
FROM node:20-alpine

# Set working directory inside the container
WORKDIR /app

# Copy only the package.json and package-lock.json files to install production dependencies
COPY package*.json ./

# Install only the production dependencies
RUN npm install --only=production

# Copy the build from the first stage
COPY --from=build /app/build ./build

# Copy the server files
COPY src/server.js .

# Expose the port the app runs on
EXPOSE 3000

# Command to start the server
CMD ["node", "server.js"]
