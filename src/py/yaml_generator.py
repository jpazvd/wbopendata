"""
YAML Generator
Transforms WB API JSON responses to wbopendata YAML schema v2.0.0
"""

from __future__ import annotations

import hashlib
import re
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, List

import yaml

logger = logging.getLogger(__name__)


class YAMLGenerator:
    """Generate YAML files from WB API data"""
    
    SCHEMA_VERSION = "2.0.0"
    GENERATOR_VERSION = SCHEMA_VERSION
    
    def __init__(self, output_dir: Path | None = None):
        """
        Initialize YAML generator
        
        Args:
            output_dir: Directory for output YAML files
        """
        default_dir = Path(__file__).resolve().parents[2] / "src" / "_"
        self.output_dir = Path(output_dir) if output_dir else default_dir
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def generate_all(self, indicators: List[Dict], sources: List[Dict], 
                     topics: List[Dict]) -> Dict[str, Path]:
        """
        Generate all three YAML files
        
        Returns:
            Dictionary mapping file type to output path
        """
        return {
            'indicators_file': self.generate_indicators_yaml(indicators),
            'sources_file': self.generate_sources_yaml(sources),
            'topics_file': self.generate_topics_yaml(topics)
        }
    
    def generate_indicators_yaml(self, indicators: List[Dict]) -> Path:
        """
        Generate _wbopendata_indicators.yaml
        
        Args:
            indicators: List of indicator dicts from API
        
        Returns:
            Path to generated YAML file
        """
        logger.info(f"Generating indicators YAML for {len(indicators)} indicators...")

        valid_indicators = []
        for ind in indicators:
            code = str(ind.get("id", "")).strip()
            # Numeric-only codes are treated as invalid for parity with Stata output.
            if not code or code.isdigit():
                continue
            valid_indicators.append(ind)
        
        # Build YAML structure
        yaml_data = {
            '_metadata': {
                'version': self.SCHEMA_VERSION,
                'generated_at': datetime.utcnow().isoformat() + 'Z',
                'source': 'World Bank Open Data API',
                'total_indicators': len(valid_indicators),
                'compression': 'none',
                'encoding': 'UTF-8'
            },
            'indicators': {}
        }
        
        # Transform each indicator
        for ind in valid_indicators:
            code = str(ind.get("id", "")).strip()
            
            yaml_data['indicators'][code] = {
                'code': code,
                'name': ind.get('name', ''),
                'source_id': self._extract_source_id(ind),
                'source_name': self._extract_source_name(ind),
                'topic_ids': self._extract_topic_ids(ind),
                'topic_names': self._extract_topic_names(ind),
                'description': self._clean_text(ind.get('sourceNote', '')),
                'unit': ind.get('unit', ''),
                'source_org': ind.get('sourceOrganization', ''),
                'note': ind.get('note', ''),
                'limited_data': False
            }
        
        # Calculate checksum
        yaml_str = yaml.dump(yaml_data, allow_unicode=True, sort_keys=False)
        checksum = hashlib.sha256(yaml_str.encode('utf-8')).hexdigest()
        yaml_data['_metadata']['checksum_sha256'] = checksum
        
        # Write to file
        output_file = self.output_dir / '_wbopendata_indicators.yaml'
        self._write_yaml(yaml_data, output_file)
        
        logger.info(f"Generated {output_file} ({output_file.stat().st_size:,} bytes)")
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
                'description': self._clean_text(src.get('description', '')),
                'url': src.get('url', ''),
                'data_availability': src.get('dataavailability', ''),
                'metadata_availability': src.get('metadataavailability', '')
            }
        
        output_file = self.output_dir / '_wbopendata_sources.yaml'
        self._write_yaml(yaml_data, output_file)
        
        logger.info(f"Generated {output_file} ({output_file.stat().st_size:,} bytes)")
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
                'description': self._clean_text(topic.get('sourceNote', ''))
            }
        
        output_file = self.output_dir / '_wbopendata_topics.yaml'
        self._write_yaml(yaml_data, output_file)
        
        logger.info(f"Generated {output_file} ({output_file.stat().st_size:,} bytes)")
        return output_file
    
    def _write_yaml(self, data: Dict, output_file: Path):
        """Write YAML data to file with proper string formatting"""

        header = (
            f"# Generated by Python yaml_generator.py v{self.GENERATOR_VERSION} "
            f"(schema {self.SCHEMA_VERSION})\n"
        )
        
        # Custom string representer following unicefData approach:
        # - Use literal block style (|) for multi-line strings
        # - Use plain (unquoted) scalars for single-line strings
        # This avoids all quote-related parsing issues in Stata
        def str_representer(dumper, data):
            if '\n' in data:
                return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
            return dumper.represent_scalar('tag:yaml.org,2002:str', data)
        
        yaml.add_representer(str, str_representer, Dumper=yaml.SafeDumper)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(header)
            yaml.safe_dump(
                data,
                f,
                allow_unicode=True,
                sort_keys=False,
                default_flow_style=False,
                width=10000,  # unicefData standard: no line wrapping
            )
    
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
        """Extract topic names from indicator."""
        topics = indicator.get('topics', [])
        if not isinstance(topics, list):
            return []
        return [t.get('value', '').strip() for t in topics if isinstance(t, dict)]
    
    def _clean_text(self, text: str) -> str:
        """Clean and normalize text - ensure single line
        Also applies light normalizations for known upstream typos.
        """
        if not text:
            return ''
        # Remove all line breaks and excessive whitespace
        text = ' '.join(text.split())
        # Normalize known content issues (e.g., "workers\ remittances" -> "workers' remittances")
        text = re.sub(r"workers\\\s+remittances", "workers' remittances", text, flags=re.IGNORECASE)
        return text.strip()


if __name__ == '__main__':
    # Quick test
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Sample data
    sample_indicators = [
        {
            'id': 'SP.POP.TOTL',
            'name': 'Population, total',
            'source': {'id': '2', 'value': 'World Development Indicators'},
            'topics': [{'id': '8', 'value': 'Health'}],
            'sourceNote': 'Total population based on...',
            'unit': 'people'
        }
    ]
    
    sample_sources = [
        {'id': '2', 'name': 'World Development Indicators', 'description': 'Primary WB database'}
    ]
    
    sample_topics = [
        {'id': '8', 'value': 'Health', 'sourceNote': 'Health-related indicators'}
    ]
    
    generator = YAMLGenerator(output_dir=Path('test_output'))
    files = generator.generate_all(sample_indicators, sample_sources, sample_topics)
    
    print("\nGenerated YAML files:")
    for file_type, path in files.items():
        print(f"  - {file_type}: {path}")
