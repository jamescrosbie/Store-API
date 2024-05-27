# Use a base Python image
FROM python:3.10 as python-base

# Set environment variables for Poetry installation
ENV POETRY_VERSION=1.5.1
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VENV=/opt/poetry-venv
ENV POETRY_CACHE_DIR=/opt/.cache

# Create stage for Poetry installation
FROM python-base as poetry-base

# Install Poetry in a dedicated virtual environment
RUN python3 -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip setuptools wheel \
    && $POETRY_VENV/bin/pip install poetry==${POETRY_VERSION}

# Create a new stage from the base python image
FROM python-base as example-app

# Copy Poetry to the application image
COPY --from=poetry-base ${POETRY_VENV} ${POETRY_VENV}

# Add Poetry to PATH
ENV PATH="${PATH}:${POETRY_VENV}/bin"

WORKDIR /FLASK_API

# Copy Poetry configuration files
COPY poetry.lock pyproject.toml ./

# Validate the project is properly configured
RUN poetry check

# Install dependencies without installing the package itself
RUN poetry install --no-root

# Verify that Poetry environment is correctly set up
RUN echo "Checking Poetry virtual environment:" \
    && ${POETRY_VENV}/bin/python -m pip list

RUN echo "Checking if flask is installed:" \
    && ${POETRY_VENV}/bin/python -m pip show flask || echo "Flask is not installed"

# Copy the application code
COPY ./app /FLASK_API/app/
COPY .flaskenv stores_items.db /FLASK_API/

# Expose the application port
EXPOSE 5000

# Run the application
# CMD ["poetry", "run", "flask", "run", "--host=0.0.0.0"]
CMD ["poetry", "run", "gunicorn", "-w", "1", "-b", "0.0.0.0:5000", "app:create_app()"]
