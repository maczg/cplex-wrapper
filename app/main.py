from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_config
from app.routes import router


def create_app() -> FastAPI:
    config = get_config()
    application = FastAPI(**config.fastapi_kwargs)

    # Include all routes
    application.include_router(router)

    return application


app = create_app()

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
