# Pathway C: Python Automation Scripts - Detailed Specifications

**Date:** January 20, 2026  
**Project:** wbopendata-dev  
**Scope:** Detailed Python implementation for automated metadata updates

---

## Table of Contents

1. [Architecture](#architecture)
2. [Core Modules](#core-modules)
3. [Configuration](#configuration)
4. [Error Handling](#error-handling)
5. [Testing](#testing)
6. [Deployment](#deployment)

---

## Architecture

### Directory Structure

```
wbopendata-dev/
├── scripts/
│   ├── __init__.py
│   ├── update_metadata.py          # Main CLI
│   ├── wb_api_client.py           # API wrapper
│   ├── yaml_generator.py          # YAML generation
│   ├── schema_validator.py        # Validation
│   ├── git_manager.py             # Git operations
│   ├── diff_analyzer.py           # Change detection
│   └── utils.py                   # Utilities
│
├── config/
│   ├── config_update.yaml         # Pipeline config
│   └── schema_yaml_v2.json        # JSON Schema for validation
│
├── tests/
│   ├── test_api_client.py
│   ├── test_yaml_generator.py
│   ├── test_validator.py
│   ├── test_git_manager.py
│   └── test_integration.py
│
├── .github/
│   └── workflows/
│       └── update-metadata.yml    # GitHub Actions
│
├── requirements-metadata.txt       # Python dependencies
└── setup.py                       # Package setup
```

---

## Core Modules

### 1. WB API Client (`wb_api_client.py`)

```python
"""
World Bank Open Data API Client
Handles all API interactions with retry logic and caching
"""

import requests
import time
import json
from pathlib import Path
from typing import List, Dict, Optional
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class WBAPIClient:
    """Client for World Bank Open Data API"""
    
    BASE_URL = "https://api.worldbank.org/v2"
    DEFAULT_TIMEOUT = 30
    MAX_RETRIES = 3
    RETRY_DELAY = 2  # seconds
    
    def __init__(self, timeout: int = DEFAULT_TIMEOUT):
        """
        Initialize API client
        
        Args:
            timeout: Request timeout in seconds
        """
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'wbopendata-metadata-updater/1.0',
            'Accept': 'application/json'
        })
    
    def fetch_indicators(self, per_page: int = 10000) -> List[Dict]:
        """
        Fetch all indicators from WB API
        
        Args:
            per_page: Number of results per page (max 20000)
        
        Returns:
            List of indicator dictionaries
        """
        logger.info("Fetching indicators from WB API...")
        
        indicators = []
        page = 1
        total_pages = None
        
        while True:
            url = f"{self.BASE_URL}/indicators"
            params = {
                'format': 'json',
                'per_page': per_page,
                'page': page
            }
            
            logger.info(f"Fetching page {page}/{total_pages or '?'}...")
            
            data = self._make_request(url, params)
            
            # WB API returns [metadata, data]
            if len(data) < 2:
                logger.warning("Unexpected API response format")
                break
            
            metadata = data[0]
            records = data[1]
            
            if total_pages is None:
                total_pages = metadata.get('pages', 1)
                total_indicators = metadata.get('total', 0)
                logger.info(f"Total indicators: {total_indicators}, Pages: {total_pages}")
            
            indicators.extend(records)
            
            # Check if more pages
            if page >= total_pages:
                break
            
            page += 1
            time.sleep(0.5)  # Rate limiting
        
        logger.info(f"Fetched {len(indicators)} indicators")
        return indicators
    
    def fetch_sources(self) -> List[Dict]:
        """Fetch all data sources"""
        logger.info("Fetching sources from WB API...")
        
        url = f"{self.BASE_URL}/sources"
        params = {'format': 'json', 'per_page': 100}
        
        data = self._make_request(url, params)
        
        if len(data) < 2:
            return []
        
        sources = data[1]
        logger.info(f"Fetched {len(sources)} sources")
        return sources
    
    def fetch_topics(self) -> List[Dict]:
        """Fetch all topics"""
        logger.info("Fetching topics from WB API...")
        
        url = f"{self.BASE_URL}/topics"
        params = {'format': 'json', 'per_page': 100}
        
        data = self._make_request(url, params)
        
        if len(data) < 2:
            return []
        
        topics = data[1]
        logger.info(f"Fetched {len(topics)} topics")
        return topics
    
    def _make_request(self, url: str, params: Dict) -> Dict:
        """
        Make HTTP request with retry logic
        
        Args:
            url: API endpoint URL
            params: Query parameters
        
        Returns:
            Parsed JSON response
        
        Raises:
            requests.RequestException: If all retries fail
        """
        for attempt in range(self.MAX_RETRIES):
            try:
                response = self.session.get(
                    url,
                    params=params,
                    timeout=self.timeout
                )
                response.raise_for_status()
                return response.json()
                
            except requests.exceptions.Timeout:
                logger.warning(f"Timeout on attempt {attempt + 1}/{self.MAX_RETRIES}")
                if attempt < self.MAX_RETRIES - 1:
                    time.sleep(self.RETRY_DELAY * (attempt + 1))
                else:
                    raise
            
            except requests.exceptions.RequestException as e:
                logger.error(f"Request failed: {e}")
                if attempt < self.MAX_RETRIES - 1:
                    time.sleep(self.RETRY_DELAY * (attempt + 1))
                else:
                    raise
    
    def save_raw_data(self, data: Dict[str, List], output_dir: Path = Path('data/raw')):
        """
        Save raw API responses to JSON files
        
        Args:
            data: Dictionary of data type → records
            output_dir: Output directory for JSON files
        """
        output_dir.mkdir(parents=True, exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        
        for data_type, records in data.items():
            output_file = output_dir / f"{data_type}_{timestamp}.json"
            
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(records, f, indent=2, ensure_ascii=False)
            
            logger.info(f"Saved {len(records)} {data_type} to {output_file}")


# Example usage
if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    
    client = WBAPIClient()
    
    # Fetch all data
    indicators = client.fetch_indicators()
    sources = client.fetch_sources()
    topics = client.fetch_topics()
    
    # Save to disk
    client.save_raw_data({
        'indicators': indicators,
        'sources': sources,
        'topics': topics
    })
```

---

### 2. YAML Generator (`yaml_generator.py`)

```python
"""
YAML Generator
Transforms WB API JSON responses to wbopendata YAML schema
"""

import yaml
import hashlib
from pathlib import Path
from typing import List, Dict, Any
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class YAMLGenerator:
    """Generate YAML files from WB API data"""
    
    SCHEMA_VERSION = "2.0.0"
    
    def __init__(self, output_dir: Path = Path('src/_')):
        """
        Initialize YAML generator
        
        Args:
            output_dir: Directory for output YAML files
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def generate_indicators_yaml(self, indicators: List[Dict]) -> Path:
        """
        Generate _wbopendata_indicators.yaml
        
        Args:
            indicators: List of indicator dicts from API
        
        Returns:
            Path to generated YAML file
        """
        logger.info(f"Generating indicators YAML for {len(indicators)} indicators...")
        
        # Build YAML structure
        yaml_data = {
            '_metadata': {
                'version': self.SCHEMA_VERSION,
                'generated_at': datetime.utcnow().isoformat() + 'Z',
                'source': 'World Bank Open Data API',
                'total_indicators': len(indicators),
                'compression': 'none',
                'encoding': 'UTF-8'
            },
            'indicators': {}
        }
        
        # Transform each indicator
        for ind in indicators:
            code = ind.get('id', '')
            if not code:
                continue
            
            yaml_data['indicators'][code] = {
                'code': code,
                'name': ind.get('name', ''),
                'source_id': self._extract_source_id(ind),
                'source_name': self._extract_source_name(ind),
                'topic_ids': self._extract_topic_ids(ind),
                'topic_names': self._extract_topic_names(ind),
                'description': self._clean_description(ind.get('sourceNote', '')),
                'unit': ind.get('unit', ''),
                'source_org': ind.get('sourceOrganization', ''),
                'note': ind.get('note', ''),
                'limited_data': False  # Can be enhanced based on coverage
            }
        
        # Calculate checksum
        yaml_str = yaml.dump(yaml_data, allow_unicode=True, sort_keys=False)
        checksum = hashlib.sha256(yaml_str.encode('utf-8')).hexdigest()
        yaml_data['_metadata']['checksum_sha256'] = checksum
        
        # Write to file
        output_file = self.output_dir / '_wbopendata_indicators.yaml'
        with open(output_file, 'w', encoding='utf-8') as f:
            yaml.dump(yaml_data, f, 
                     allow_unicode=True, 
                     sort_keys=False,
                     default_flow_style=False,
                     width=80)
        
        logger.info(f"Generated {output_file} ({output_file.stat().st_size} bytes)")
        return output_file
    
    def generate_sources_yaml(self, sources: List[Dict]) -> Path:
        """Generate _wbopendata_sources.yaml"""
        logger.info(f"Generating sources YAML for {len(sources)} sources...")
        
        yaml_data = {
            '_metadata': {
                'version': self.SCHEMA_VERSION,
                'generated_at': datetime.utcnow().isoformat() + 'Z',
                'total_sources': len(sources)
            },
            'sources': {}
        }
        
        for src in sources:
            code = str(src.get('id', ''))
            if not code:
                continue
            
            yaml_data['sources'][code] = {
                'code': code,
                'name': src.get('name', ''),
                'description': self._clean_description(src.get('description', '')),
                'url': src.get('url', '')
            }
        
        output_file = self.output_dir / '_wbopendata_sources.yaml'
        with open(output_file, 'w', encoding='utf-8') as f:
            yaml.dump(yaml_data, f, allow_unicode=True, sort_keys=False)
        
        logger.info(f"Generated {output_file}")
        return output_file
    
    def generate_topics_yaml(self, topics: List[Dict]) -> Path:
        """Generate _wbopendata_topics.yaml"""
        logger.info(f"Generating topics YAML for {len(topics)} topics...")
        
        yaml_data = {
            '_metadata': {
                'version': self.SCHEMA_VERSION,
                'generated_at': datetime.utcnow().isoformat() + 'Z',
                'total_topics': len(topics)
            },
            'topics': {}
        }
        
        for topic in topics:
            code = str(topic.get('id', ''))
            if not code:
                continue
            
            yaml_data['topics'][code] = {
                'code': code,
                'name': topic.get('value', ''),
                'description': self._clean_description(topic.get('sourceNote', ''))
            }
        
        output_file = self.output_dir / '_wbopendata_topics.yaml'
        with open(output_file, 'w', encoding='utf-8') as f:
            yaml.dump(yaml_data, f, allow_unicode=True, sort_keys=False)
        
        logger.info(f"Generated {output_file}")
        return output_file
    
    def _extract_source_id(self, indicator: Dict) -> str:
        """Extract source ID from indicator"""
        source = indicator.get('source', {})
        if isinstance(source, dict):
            return str(source.get('id', ''))
        return ''
    
    def _extract_source_name(self, indicator: Dict) -> str:
        """Extract source name from indicator"""
        source = indicator.get('source', {})
        if isinstance(source, dict):
            return source.get('value', '')
        return ''
    
    def _extract_topic_ids(self, indicator: Dict) -> List[str]:
        """Extract topic IDs from indicator"""
        topics = indicator.get('topics', [])
        if not isinstance(topics, list):
            return []
        return [str(t.get('id', '')) for t in topics if isinstance(t, dict)]
    
    def _extract_topic_names(self, indicator: Dict) -> List[str]:
        """Extract topic names from indicator"""
        topics = indicator.get('topics', [])
        if not isinstance(topics, list):
            return []
        return [t.get('value', '') for t in topics if isinstance(t, dict)]
    
    def _clean_description(self, text: str) -> str:
        """Clean and normalize description text"""
        if not text:
            return ''
        
        # Remove excessive whitespace
        text = ' '.join(text.split())
        
        # Remove HTML tags if present
        import re
        text = re.sub(r'<[^>]+>', '', text)
        
        return text.strip()


# Example usage
if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    
    # Load raw data
    import json
    with open('data/raw/indicators_latest.json') as f:
        indicators = json.load(f)
    
    generator = YAMLGenerator()
    generator.generate_indicators_yaml(indicators)
```

---

### 3. Schema Validator (`schema_validator.py`)

```python
"""
YAML Schema Validator
Validates YAML files against JSON Schema
"""

import yaml
import jsonschema
from pathlib import Path
from typing import Dict, Any, List, Tuple
import logging

logger = logging.getLogger(__name__)

class SchemaValidator:
    """Validate YAML files against schema"""
    
    def __init__(self, schema_file: Path = Path('config/schema_yaml_v2.json')):
        """
        Initialize validator
        
        Args:
            schema_file: Path to JSON Schema file
        """
        self.schema_file = schema_file
        self.schema = self._load_schema()
    
    def _load_schema(self) -> Dict:
        """Load JSON Schema"""
        import json
        with open(self.schema_file) as f:
            return json.load(f)
    
    def validate(self, yaml_file: Path) -> Tuple[bool, List[str]]:
        """
        Validate YAML file against schema
        
        Args:
            yaml_file: Path to YAML file
        
        Returns:
            Tuple of (is_valid, error_messages)
        """
        logger.info(f"Validating {yaml_file}...")
        
        # Load YAML
        with open(yaml_file, encoding='utf-8') as f:
            data = yaml.safe_load(f)
        
        errors = []
        
        try:
            # Validate against schema
            jsonschema.validate(data, self.schema)
            
            # Additional custom validations
            errors.extend(self._validate_metadata(data))
            errors.extend(self._validate_indicators(data))
            errors.extend(self._validate_no_duplicates(data))
            
            if errors:
                for err in errors:
                    logger.error(f"Validation error: {err}")
                return False, errors
            
            logger.info(f"✓ {yaml_file} is valid")
            return True, []
            
        except jsonschema.ValidationError as e:
            error_msg = f"Schema validation failed: {e.message}"
            logger.error(error_msg)
            return False, [error_msg]
    
    def _validate_metadata(self, data: Dict) -> List[str]:
        """Validate _metadata block"""
        errors = []
        
        if '_metadata' not in data:
            errors.append("Missing _metadata block")
            return errors
        
        metadata = data['_metadata']
        
        # Required fields
        required = ['version', 'generated_at']
        for field in required:
            if field not in metadata:
                errors.append(f"Missing required metadata field: {field}")
        
        # Version format
        version = metadata.get('version', '')
        if not self._is_valid_version(version):
            errors.append(f"Invalid version format: {version}")
        
        return errors
    
    def _validate_indicators(self, data: Dict) -> List[str]:
        """Validate indicators block"""
        errors = []
        
        if 'indicators' not in data:
            errors.append("Missing indicators block")
            return errors
        
        indicators = data['indicators']
        
        if not isinstance(indicators, dict):
            errors.append("indicators must be a dictionary")
            return errors
        
        # Check each indicator has required fields
        for code, ind in indicators.items():
            if not isinstance(ind, dict):
                errors.append(f"Indicator {code} is not a dictionary")
                continue
            
            required = ['code', 'name']
            for field in required:
                if field not in ind:
                    errors.append(f"Indicator {code} missing required field: {field}")
            
            # Code must match key
            if ind.get('code') != code:
                errors.append(f"Indicator code mismatch: key={code}, code={ind.get('code')}")
        
        return errors
    
    def _validate_no_duplicates(self, data: Dict) -> List[str]:
        """Check for duplicate codes"""
        errors = []
        
        if 'indicators' not in data:
            return errors
        
        codes = list(data['indicators'].keys())
        duplicates = [code for code in codes if codes.count(code) > 1]
        
        if duplicates:
            errors.append(f"Duplicate indicator codes: {set(duplicates)}")
        
        return errors
    
    def _is_valid_version(self, version: str) -> bool:
        """Check if version follows semver format"""
        import re
        pattern = r'^\d+\.\d+\.\d+$'
        return bool(re.match(pattern, version))


# Example usage
if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    
    validator = SchemaValidator()
    is_valid, errors = validator.validate(Path('src/_/_wbopendata_indicators.yaml'))
    
    if is_valid:
        print("✓ Validation passed")
    else:
        print("✗ Validation failed:")
        for err in errors:
            print(f"  - {err}")
```

---

### 4. Git Manager (`git_manager.py`)

```python
"""
Git Manager
Handles git operations (commit, tag, version bump)
"""

import git
from pathlib import Path
from typing import Optional, List
import re
import logging

logger = logging.getLogger(__name__)

class GitManager:
    """Manage git operations for metadata updates"""
    
    def __init__(self, repo_path: Path = Path('.')):
        """
        Initialize git manager
        
        Args:
            repo_path: Path to git repository
        """
        self.repo = git.Repo(repo_path)
    
    def has_changes(self, pattern: str = 'src/_/_wbopendata_*.yaml') -> bool:
        """
        Check if there are uncommitted changes
        
        Args:
            pattern: File pattern to check
        
        Returns:
            True if changes detected
        """
        # Check staged and unstaged changes
        diff_staged = self.repo.index.diff('HEAD')
        diff_unstaged = self.repo.index.diff(None)
        
        # Filter by pattern
        import fnmatch
        changed_files = [item.a_path for item in diff_staged] + \
                       [item.a_path for item in diff_unstaged]
        
        matching = [f for f in changed_files if fnmatch.fnmatch(f, pattern)]
        
        return len(matching) > 0
    
    def commit_changes(self, message: str, files: Optional[List[str]] = None):
        """
        Commit changes to git
        
        Args:
            message: Commit message
            files: List of files to commit (None = all YAML files)
        """
        if files is None:
            files = [
                'src/_/_wbopendata_indicators.yaml',
                'src/_/_wbopendata_sources.yaml',
                'src/_/_wbopendata_topics.yaml'
            ]
        
        # Stage files
        self.repo.index.add(files)
        
        # Commit
        commit = self.repo.index.commit(message)
        logger.info(f"Committed: {commit.hexsha[:8]} - {message}")
        
        return commit
    
    def create_tag(self, tag_name: str, message: str):
        """
        Create annotated git tag
        
        Args:
            tag_name: Tag name (e.g., metadata-v2.1.0)
            message: Tag message
        """
        tag = self.repo.create_tag(tag_name, message=message)
        logger.info(f"Created tag: {tag_name}")
        return tag
    
    def push(self, remote: str = 'origin', tags: bool = True):
        """
        Push commits and tags to remote
        
        Args:
            remote: Remote name
            tags: Whether to push tags
        """
        self.repo.remote(remote).push()
        logger.info(f"Pushed to {remote}")
        
        if tags:
            self.repo.remote(remote).push(tags=True)
            logger.info(f"Pushed tags to {remote}")
    
    def get_latest_version(self, prefix: str = 'metadata-v') -> str:
        """
        Get latest version from git tags
        
        Args:
            prefix: Tag prefix to filter
        
        Returns:
            Latest version string (e.g., "2.1.0")
        """
        tags = [tag.name for tag in self.repo.tags if tag.name.startswith(prefix)]
        
        if not tags:
            return "2.0.0"  # Default starting version
        
        # Extract versions
        versions = []
        for tag in tags:
            match = re.search(r'(\d+\.\d+\.\d+)$', tag)
            if match:
                versions.append(match.group(1))
        
        if not versions:
            return "2.0.0"
        
        # Sort versions
        versions.sort(key=lambda v: [int(x) for x in v.split('.')])
        
        return versions[-1]
    
    def bump_version(self, current: str, bump_type: str = 'minor') -> str:
        """
        Bump version number
        
        Args:
            current: Current version (e.g., "2.1.0")
            bump_type: 'major', 'minor', or 'patch'
        
        Returns:
            New version string
        """
        major, minor, patch = map(int, current.split('.'))
        
        if bump_type == 'major':
            return f"{major + 1}.0.0"
        elif bump_type == 'minor':
            return f"{major}.{minor + 1}.0"
        elif bump_type == 'patch':
            return f"{major}.{minor}.{patch + 1}"
        else:
            raise ValueError(f"Invalid bump_type: {bump_type}")


# Example usage
if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    
    git_mgr = GitManager()
    
    # Check for changes
    if git_mgr.has_changes():
        # Get next version
        current = git_mgr.get_latest_version()
        next_version = git_mgr.bump_version(current, 'minor')
        
        # Commit
        git_mgr.commit_changes(f"Update metadata: v{next_version}")
        
        # Tag
        git_mgr.create_tag(f"metadata-v{next_version}", f"Metadata v{next_version}")
        
        # Push
        git_mgr.push()
```

---

## Configuration

### `config/config_update.yaml`

```yaml
# Metadata Update Pipeline Configuration

# World Bank API settings
wb_api:
  base_url: "https://api.worldbank.org/v2"
  timeout: 30
  max_retries: 3
  retry_delay: 2
  per_page: 10000  # Max results per API call

# Output settings
output:
  yaml_dir: "src/_"
  raw_data_dir: "data/raw"
  logs_dir: "logs"

# YAML generation
yaml:
  schema_version: "2.0.0"
  encoding: "utf-8"
  compression: "none"
  sort_keys: false

# Git settings
git:
  auto_commit: true
  tag_prefix: "metadata-v"
  commit_message_template: "Update metadata: v{version} ({date})"
  auto_push: false  # Manual push for safety

# Validation
validation:
  schema_file: "config/schema_yaml_v2.json"
  strict_mode: true
  check_duplicates: true

# Notifications (optional)
notifications:
  enabled: false
  slack_webhook: ""
  email_to: ""
```

---

## Error Handling

### Exception Hierarchy

```python
class MetadataUpdateError(Exception):
    """Base exception for metadata updates"""
    pass

class APIFetchError(MetadataUpdateError):
    """Error fetching data from WB API"""
    pass

class YAMLGenerationError(MetadataUpdateError):
    """Error generating YAML files"""
    pass

class ValidationError(MetadataUpdateError):
    """YAML validation failed"""
    pass

class GitOperationError(MetadataUpdateError):
    """Git operation failed"""
    pass
```

### Logging Configuration

```python
import logging
from logging.handlers import RotatingFileHandler

def setup_logging(log_file='logs/metadata_update.log'):
    """Setup logging configuration"""
    
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # File handler
    file_handler = RotatingFileHandler(
        log_file,
        maxBytes=10*1024*1024,  # 10 MB
        backupCount=5
    )
    file_handler.setFormatter(formatter)
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    
    # Root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    root_logger.addHandler(file_handler)
    root_logger.addHandler(console_handler)
```

---

## Testing

### `tests/test_api_client.py`

```python
import pytest
from scripts.wb_api_client import WBAPIClient

def test_fetch_indicators():
    client = WBAPIClient()
    indicators = client.fetch_indicators(per_page=100)
    
    assert len(indicators) > 0
    assert all('id' in ind for ind in indicators)
    assert all('name' in ind for ind in indicators)

def test_fetch_sources():
    client = WBAPIClient()
    sources = client.fetch_sources()
    
    assert len(sources) > 0
    assert all('id' in src for src in sources)

def test_retry_logic(monkeypatch):
    """Test retry logic on timeout"""
    import requests
    
    call_count = 0
    
    def mock_get(*args, **kwargs):
        nonlocal call_count
        call_count += 1
        if call_count < 3:
            raise requests.exceptions.Timeout()
        # Succeed on 3rd try
        return type('Response', (), {
            'json': lambda: [{}, []],
            'raise_for_status': lambda: None
        })()
    
    monkeypatch.setattr('requests.Session.get', mock_get)
    
    client = WBAPIClient()
    client._make_request('http://test.com', {})
    
    assert call_count == 3  # 2 retries + 1 success
```

---

## Deployment

### Requirements File

```
# requirements-metadata.txt
requests>=2.31.0
pyyaml>=6.0
jsonschema>=4.20.0
gitpython>=3.1.40
python-dateutil>=2.8.2
pytest>=7.4.0
pytest-cov>=4.1.0
```

### Setup Script

```python
# setup.py
from setuptools import setup, find_packages

setup(
    name='wbopendata-metadata-updater',
    version='1.0.0',
    packages=find_packages(),
    install_requires=[
        'requests>=2.31.0',
        'pyyaml>=6.0',
        'jsonschema>=4.20.0',
        'gitpython>=3.1.40',
    ],
    entry_points={
        'console_scripts': [
            'update-metadata=scripts.update_metadata:main',
        ],
    },
)
```

---

**Document Status:** Technical Specification Complete  
**Next:** Begin implementation of Python modules
