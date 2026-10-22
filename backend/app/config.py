from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "KZ Domestic Flights Price Monitor API"
    VERSION: str = "0.1.0-prob-period-1"
    DATABASE_URL: str = "postgresql+psycopg2://kz_user:kz_password@127.0.0.1:5433/kz_flights"
    TRAVELPAYOUTS_TOKEN: str = ""
    CACHE_FRESHNESS_HOURS: int = 48

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()