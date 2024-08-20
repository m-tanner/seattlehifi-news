# Step 1: Use an official Node.js runtime as the base image
FROM node:20-alpine AS build

# Set environment variables for the build process
ARG REACT_APP_BACKEND_BASE_URL
ARG REACT_APP_FRONTEND_BASE_URL

# Step 2: Set the working directory in the container
WORKDIR /app

# Step 3: Copy the package.json and package-lock.json to the working directory
COPY package*.json ./

# Step 4: Install the dependencies
RUN npm install

# Step 5: Copy the rest of the app's source code to the working directory
COPY . .

# Step 7: Build the React app
RUN npm run build

FROM node:20-alpine

# Install `serve` globally
RUN npm install -g serve

# Step 9: Copy the built React app from the previous step to the NGINX web root
COPY --from=build /app/build /app/build

# Step 10: Expose port
EXPOSE 3000

# Serve the React app
CMD ["serve", "-s", "/app/build"]
