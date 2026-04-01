# Use an official Python runtime as a parent image
FROM python:3.10.12-slim

# Set working directory
WORKDIR /app

# Add user for application
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application directory
COPY . .

# Set permissions for the application directory
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 5002

# Command to run the application
CMD ["python", "app.py"]
