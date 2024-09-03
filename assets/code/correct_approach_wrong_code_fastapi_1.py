# default/codellama_7b_greedy_beams_3/fastapi_1.py
from contextlib import asynccontextmanager
from fastapi import FastAPI

def startup(app: FastAPI):
    app.state.startup = True

def shutdown(app: FastAPI):
    app.state.shutdown = True

def create_fastapi_app() -> FastAPI:
    """Create a new FastAPI app which calls the lifespan functions startup and shutdown.

    Returns:
        FastAPI: New FastAPI instance
    """
    return FastAPI(on_startup=startup, on_shutdown=shutdown) -> FastAPI
