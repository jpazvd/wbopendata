## Annex: Technical Details on datalibweb, DataZoom, and unicefData

### 1. World Bank — datalibweb

**Repository**: https://github.com/worldbank/datalibweb

**Purpose**: datalibweb is a Stata-frontend for the World Bank's microdata API, created by the Poverty Global Practice and ITS teams to support access to microdata catalogs across regions and collections. It integrates with a microdata API to explore and load both non-harmonized (raw) and harmonized survey data directly within Stata.

**Key features**:
- Browse catalog of available microdata collections
- API endpoints for accessing microdata with appropriate permissions  
- Stata package integration (`datalibweb` / `dlw`) that enhances workflows for analysts working with complex surveys
- Version-controlled access to harmonized household survey datasets
- Structured metadata retrieval and dataset documentation

**Constraints**: The datalibweb infrastructure is not publicly available outside the World Bank network; Stata integration works primarily within the Bank's computing environment. Data access requires catalog access rights and internal workflows, limiting external reproducibility despite sophisticated internal capabilities.

### 2. DataZoom — datazoom_social_Stata

**Repository**: https://github.com/datazoompuc/datazoom_social_Stata

**Purpose**: Part of the Data Zoom project developed by PUC-Rio's Economics Department to support access and standardization of Brazilian household survey microdata from Brazil's IBGE (Instituto Brasileiro de Geografia e Estatística).

**Coverage of Brazilian surveys**:
- **Censo Demográfico** (Demographic Census): 1970-2010
- **PNAD** (National Household Sample Survey): 1981-2015 (except census years and 1994)
- **PNAD Contínua** (Continuous PNAD): 2012-present (quarterly and annual)
- **PNAD Covid**: 2020 (monthly during pandemic)
- **PME** (Monthly Employment Survey): 1990-2015 (PME Antiga and PME Nova)
- **PNS** (National Health Survey): 2013, 2019
- **POF** (Consumer Expenditure Survey): 1995-96, 2002-03, 2008-09, 2017-18
- **ECINF** (Urban Informal Economy): 1997, 2003

**Key capabilities**:
- Automated data extraction from original IBGE microdata files (reads fixed-width format using dictionaries)
- Cross-year variable harmonization with documented compatibility procedures
- Panel identification algorithms for longitudinal surveys:
  - PME: Two algorithms based on Ribas and Soares (2008) for linking individuals across survey waves
  - PNAD Contínua: Basic and advanced identification methods for constructing household panels
- Deflation tools for monetary variables (converting nominal to real values)
- Standardized variable naming and labeling across survey years
- Customizable consumption baskets for POF (allowing researchers to define their own aggregations)

**Technical approach**: The package provides Stata `.ado` files for each survey type, allowing users to specify years, states (UFs), and options (e.g., person vs. household files, compatibility mode, panel construction). Unlike API-based tools, it requires researchers to download original microdata files from IBGE first, then harmonizes them locally.

**Relevant context**: The Data Zoom ecosystem includes multiple packages beyond social microdata. The approach demonstrates how national statistical agencies' complex survey structures can be systematically documented and harmonized for research use, though geographic scope is limited to Brazil.

### 3. UNICEF — unicefData

**Repository**: https://github.com/unicef-drp/unicefData

**Purpose**: Trilingual (R, Python, Stata) library for downloading UNICEF child welfare indicators via SDMX API, providing unified access to UNICEF's data warehouse across statistical computing environments.

**Coverage**:
- **733 indicators** across **15 thematic categories**
- Categories include: Child Mortality (CME), Nutrition, Education (UIS SDG), Immunization, HIV/AIDS, WASH (Water/Sanitation/Hygiene), Maternal/Newborn/Child Health (MNCH), Child Protection (PT), Child Marriage (PT_CM), Female Genital Mutilation (PT_FGM), Early Childhood Development (ECD), Child Poverty (CHLD_PVTY), Demographics, Migration, Gender, Functional Difficulties, Social Protection, Economics

**Key features**:
- **Unified API across languages**: Same `unicefData()` function signature in R, Python, and Stata
- **Automatic dataflow detection**: System determines correct dataflow (CME, NUTRITION, etc.) from indicator code
- **Discovery functions**: 
  - `search_indicators(query, category)` — Search 733 indicators by keyword/category
  - `list_categories()` — Display all 15 categories with counts
  - `dataflow_schema(flow)` — Show disaggregation dimensions available for each dataflow
- **Filtering capabilities**: Country (ISO3 codes), year (ranges, lists, circa matching), sex, age, wealth quintile, residence (urban/rural), maternal education
- **Post-production options**: 
  - Multiple output formats (long, wide by year/indicator/sex/wealth)
  - Latest values only (`latest = TRUE`)
  - Circa year matching (finds nearest available year when exact year unavailable)
  - Most Recent Values (`mrv = n` for last n observations per country/indicator)
  - Metadata addition (region, income group, indicator name)
- **Comprehensive error handling**: Retry logic, automatic fallback to alternative dataflows, detailed error messages
- **Decimal year conversion**: Monthly periods (YYYY-MM) converted to decimal years for time-series analysis
- **Validation against YAML metadata**: Uses UNICEF-maintained codelist YAML files for country codes, indicators, and dataflows

**Technical architecture**:
- **R**: Source functions using httr/jsonlite for API calls, dplyr/tidyr for data manipulation
- **Python**: Object-oriented `UNICEFSDMXClient` class with pandas DataFrames
- **Stata**: Native `.ado` implementation with JSON parsing via Stata 14+ insheetjson
- All three implementations share synchronized metadata from YAML files generated from UNICEF SDMX API

**Reproducibility features**: Following wbopendata's design philosophy, all data access is scripted with explicit parameters (indicator codes, countries, years), enabling exact replication and systematic updates as new data are released. Cross-language consistency allows multi-platform research teams to maintain identical analytical workflows.

**Methodological significance**: unicefData demonstrates that API-enabled, reproducible data access can be achieved across the statistical computing ecosystem while maintaining metadata consistency. The automatic dataflow detection and discovery functions lower barriers to use compared to raw SDMX endpoints.

---

### Synthesis: What These Repositories Tell Us

Across these three projects, a consistent pattern emerges regarding how open data and reproducible research infrastructure is being operationalized within the social sciences:

**1. Stata package architecture as infrastructure**: All three tools leverage Stata's extensible package architecture to embed data-access logic directly into user workflows. This aligns with the idea that software ecosystems with stable extension points (like SSC/net install workflows) reduce barriers to programmatic data access and reproducibility.

**2. Scope and constraints differ**:
- **datalibweb** shows how internal microdata APIs can integrate with Stata, but remains largely institution-bound, limiting broader reproducibility external to the World Bank
- **datazoom_social_Stata** illustrates a national microdata standardization effort that complements API-style access by harmonizing complex survey data, but still requires manual ingestion of source files
- **unicefData** represents a multi-language, open-source indicator ecosystem that explicitly foregrounds reproducible access to child-related statistics at global scale

**3. Common methodological advances**: All projects encapsulate data access + preprocessing logic into reusable code—reducing ad-hoc workflows and increasing transparency. They reflect a broader shift toward programmatic, versioned data retrieval as a foundation for reproducible analysis.
