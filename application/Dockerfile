FROM python:3.10-alpine

# Security updates
RUN apk update && apk upgrade 

# Copy code
COPY *.py requirements.txt /app/
WORKDIR /app

# Install dependencies
RUN python -m pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Add non-root user
RUN addgroup -g 20020 -S appuser && adduser -S -D -H -u 10020 -h /app -s /bin/ash -G appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

# Document that the service listens on port 5000.
EXPOSE 5000
ENTRYPOINT [ "python", "-u", "./app.py" ]