FROM node:20.12.1-alpine

WORKDIR /app

# Copy package files first for caching
COPY app/package.json app/package-lock.json* ./

# Install dependencies
RUN npm install

# Copy app source
COPY app/ .

EXPOSE 3000

# Run app as non-root user for better security (optional)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

CMD ["npm", "start"]
