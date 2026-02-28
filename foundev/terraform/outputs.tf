6. Let's create the Docker Compose file for local development:

```yaml
version: '3.8'

services:
  # PostgreSQL service
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: foundevadmin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: foundevdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Redis service
  redis:
    image: redis:6
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  # MinIO for local S3
  minio:
    image: minio/minio
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: ${MINIO_PASSWORD}
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    command: server /data --console-address ":9001"

  # Backend service
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=foundevadmin
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=foundevdb
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - AWS_ACCESS_KEY_ID=minioadmin
      - AWS_SECRET_ACCESS_KEY=${MINIO_PASSWORD}
      - AWS_S3_ENDPOINT=http://minio:9000
      - AWS_S3_BUCKET=foundev-images
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
      - minio
    volumes:
      - ./backend:/app
      - /app/node_modules

  # AI service
  ai:
    build:
      context: ./ai
      dockerfile: Dockerfile.dev
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    ports:
      - "8000:8000"
    depends_on:
      - redis
    volumes:
      - ./ai:/app
      - /app/venv

volumes:
  postgres_data:
  redis_data:
  minio_data:
```