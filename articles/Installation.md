# 1. Introduction

This vignette shows how to install the required components and register
a new user on the **Google Earth Engine platform**, in order to use its
API within the `land4health` package to access and extract multiple
variables relevant to **Spatial Epidemiology**.

### 1.1 What is Google Earth Engine?

![](https://user-images.githubusercontent.com/23284899/152171996-54afdafa-4456-4d63-9c92-dca515b100a8.png)

**Google Earth Engine** is a cloud-based platform that helps access
high-performance computing resources for processing and analyzing large
geospatial datasets (Noel Golerick et al.,2017).

### 1.2 Objectives:

- Be accessible to various professionals without being experts in
  handling supercomputers.
- Reduce pre-post processing time of satellite images on a local,
  regional or global scale.
- Implement application development without being a backend/frontend
  expert.
- Boost the development of big data for remote sensing.

### 1.3 Components:

- **Data catalog**: Curated collection of several petabytes of
  geospatial datasets widely used in remote sensing available to the
  general public.

- **High performance computing service**: Google’s computational
  infrastructure to optimize parallel processing and distribution of
  geospatial data.

- **API and client libraries**: Application programming interface for
  making requests to Earth Engine servers.

  - API
    - Client libraries
    - Code Editor
    - REST API
  - Client libraries:
    - JavaScript
    - Python
    - R (no official)

### 1.4 Quickly review of Data catalog

![](https://user-images.githubusercontent.com/23284899/152204233-96e00f05-7b2e-479c-b19a-43aee33b3d7c.jpg)

## 2. Installation and setup land4health

### 2.1 GMAIL register

To access all the benefits offered by the Earth Engine platform, you
must have an active Google (Gmail) account. To register, go to 👉
<https://code.earthengine.google.com/register>.

Earth Engine offers two registration options:

- **Commercial user**: For commercial product development, service
  monetization, and related purposes.

- **Non-commercial user**: For research, education, and academic
  activities.

For our purposes, we will proceed by selecting the non-commercial user
option.

![](https://user-images.githubusercontent.com/23284899/258835768-d84c50b2-0c74-4ee9-a7d8-c5bf7137360b.png)

You can install the development version of `land4health` from GitHub
with:

``` r
# install.packages("pak")
pak::pak("harmonize-tools/land4health")
```

``` r
library(land4health)
```

``` r
── Welcome to land4health ───────────────────────────────────────────────────────────────────────────────
A tool of Harmonize Project to calculate and extract Remote Sensing Metrics for Spatial Health Analysis.
Currently,`land4health` supports metrics in the following categories:
• Accesibility
• Climate
• Enviroment
• and more!
For a complete list of available metrics, use the `l4h_list_metrics()` function.

─────────────────────────────────────────────────────────────────────────────────────────────────────────
Attaching core land4health packages:
→ rgee v1.1.7
→ sf v1.0.21
```

``` r
rgee::ee_install()
```

``` r
── Installing land4health Python dependencies ───────────────
ℹ Step 1/3: Checking Python environment
ℹ Step 2/3: Installing Python packages
✔ Python packages installed successfully
ℹ Step 3/3: Finalizing setup
✔ land4health setup completed.
```

``` r
ee_Initialize()
```

``` r
#> ── rgee 1.1.7 ─────────────────────────────────────── earthengine-api 0.1.370 ── 
#>  ✔ user: not_defined 
#>  ✔ Initializing Google Earth Engine: ✔ Initializing Google Earth Engine:  DONE!
#>  ✔ Earth Engine account: users/geografo2023 
#>  ✔ Python Path: C:/Users/mvcs_dgppvu_ambi/AppData/Local/R/cache/R/reticulate/uv/cache/archive-v0/At8gJm7EZeLgoj4R1d2hk/Scripts/python.exe 
#> ────────────────────────────────────────────────────────────────────────────────
```

``` r
land4health::l4h_packages()
#> [1] "rgee"        "sf"          "land4health"
```
