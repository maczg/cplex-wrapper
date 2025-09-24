from functools import lru_cache
from typing import List, Dict, Any

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

class AppConfig(BaseSettings):
    """App configuration"""

    testing: bool = Field(default=False, alias="TESTING")
    debug: bool = Field(default=False, alias="DEBUG")
    title: str = Field(default="COAT API", alias="API_TITLE")
    version: str = Field(default="0.1.0", alias="API_VERSION")
    api_prefix: str = Field(default="/api", alias="API_PREFIX")
    doc_url: str = Field(default="/docs", alias="API_DOC_URL")
    openapi_url: str = Field(default="/openapi.json", alias="API_OPENAPI_URL")

    class Config:
        env_prefix = "APP_"


class Config(BaseSettings):
    """Main configuration class"""

    model_config = SettingsConfigDict(extra="ignore", case_sensitive=False, env_file='.env')

    app: AppConfig = Field(default_factory=AppConfig)

    @property
    def fastapi_kwargs(self) -> Dict[str, Any]:
        return {
            "debug": self.app.debug,
            "title": self.app.title,
            "version": self.app.version,
            "prefix": self.app.api_prefix,
            "doc_url": self.app.doc_url,
            "openapi_url": self.app.openapi_url,
            "cors_origins": self.app.cors.allow_origins,
        }


@lru_cache()
def get_config() -> Config:
    """Get cached config instance"""
    return Config()


config = get_config()
