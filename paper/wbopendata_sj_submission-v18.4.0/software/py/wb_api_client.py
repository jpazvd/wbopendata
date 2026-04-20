"""
World Bank Open Data API Client
Handles all API interactions with retry logic and pagination
"""

from __future__ import annotations

import json
import logging
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List

import requests

logger = logging.getLogger(__name__)


class WBAPIClient:
    """Client for World Bank Open Data API v2."""

    BASE_URL = "https://api.worldbank.org/v2"
    DEFAULT_TIMEOUT = 30
    MAX_RETRIES = 3
    RETRY_DELAY = 2  # seconds
    MAX_PER_PAGE = 20000

    def __init__(self, timeout: int = DEFAULT_TIMEOUT):
        """Initialize the API client with a persistent session."""
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update(
            {
                "User-Agent": "wbopendata-metadata-updater/1.0",
                "Accept": "application/json",
            }
        )

    def __enter__(self) -> "WBAPIClient":
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.close()

    def close(self) -> None:
        self.session.close()

    def fetch_indicators(self, per_page: int = 10000) -> List[Dict]:
        """Fetch all indicators from WB API with pagination."""
        logger.info("Fetching indicators from WB API...")

        per_page = max(1, min(per_page, self.MAX_PER_PAGE))
        indicators: List[Dict] = []
        page = 1
        total_pages = None

        while True:
            url = f"{self.BASE_URL}/indicators"
            params = {
                "format": "json",
                "per_page": per_page,
                "page": page,
            }

            logger.info("Fetching page %s/%s...", page, total_pages or "?")
            data = self._make_request(url, params)

            if not data or len(data) < 2:
                raise ValueError(f"Unexpected API response format for indicators (page {page})")

            metadata = data[0]
            records = data[1]

            if total_pages is None:
                total_pages = metadata.get("pages", 1)
                total_indicators = metadata.get("total", 0)
                logger.info("Total indicators: %s, Pages: %s", total_indicators, total_pages)

            indicators.extend(records)

            if page >= total_pages:
                break

            page += 1
            time.sleep(self.RETRY_DELAY)

        logger.info("Fetched %s indicators", len(indicators))
        return indicators

    def fetch_sources(self) -> List[Dict]:
        """Fetch all data sources."""
        logger.info("Fetching sources from WB API...")

        url = f"{self.BASE_URL}/sources"
        params = {"format": "json", "per_page": 100}
        data = self._make_request(url, params)

        if not data or len(data) < 2:
            raise ValueError("Unexpected API response format for sources")

        sources = data[1]
        logger.info("Fetched %s sources", len(sources))
        return sources

    def fetch_topics(self) -> List[Dict]:
        """Fetch all topics."""
        logger.info("Fetching topics from WB API...")

        url = f"{self.BASE_URL}/topics"
        params = {"format": "json", "per_page": 100}
        data = self._make_request(url, params)

        if not data or len(data) < 2:
            raise ValueError("Unexpected API response format for topics")

        topics = data[1]
        logger.info("Fetched %s topics", len(topics))
        return topics

    def _make_request(self, url: str, params: Dict[str, Any]) -> Any:
        """Make HTTP request with retry logic."""
        last_error: Exception | None = None
        for attempt in range(self.MAX_RETRIES):
            try:
                response = self.session.get(url, params=params, timeout=self.timeout)
                response.raise_for_status()
                return response.json()
            except requests.exceptions.Timeout as exc:
                last_error = exc
                logger.warning(
                    "Timeout on attempt %s/%s for %s; retrying in %ss",
                    attempt + 1,
                    self.MAX_RETRIES,
                    url,
                    self.RETRY_DELAY * (attempt + 1),
                )
            except requests.exceptions.RequestException as exc:
                last_error = exc
                logger.warning(
                    "Request failed on attempt %s/%s for %s: %s",
                    attempt + 1,
                    self.MAX_RETRIES,
                    url,
                    exc,
                )

            if attempt < self.MAX_RETRIES - 1:
                time.sleep(self.RETRY_DELAY * (attempt + 1))

        raise RuntimeError(f"API request failed after {self.MAX_RETRIES} attempts: {url}") from last_error

    def save_raw_data(self, data: Dict[str, List], output_dir: Path = Path("data/raw")) -> None:
        """Save raw API responses to JSON files."""
        output_dir.mkdir(parents=True, exist_ok=True)

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        for data_type, records in data.items():
            output_file = output_dir / f"{data_type}_{timestamp}.json"

            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(records, f, indent=2, ensure_ascii=False)

            logger.info("Saved %s %s to %s", len(records), data_type, output_file)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s")

    with WBAPIClient() as client:
        indicators = client.fetch_indicators(per_page=5000)
        sources = client.fetch_sources()
        topics = client.fetch_topics()

        print("\nFetched:")
        print(f"  - {len(indicators)} indicators")
        print(f"  - {len(sources)} sources")
        print(f"  - {len(topics)} topics")

        client.save_raw_data({"indicators": indicators, "sources": sources, "topics": topics})
