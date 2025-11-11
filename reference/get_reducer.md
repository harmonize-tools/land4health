# Internal: Get an Earth Engine reducer Returns a reducer object (e.g., `ee$Reducer$mean()`) based on a string name.

Internal: Get an Earth Engine reducer Returns a reducer object (e.g.,
`ee$Reducer$mean()`) based on a string name.

## Usage

``` r
get_reducer(name)
```

## Arguments

- name:

  A string: one of `"mean"`, `"sum"`, `"min"`, `"max"`, `"median"`,
  `"stdDev"` and `"first"`

## Value

An Earth Engine reducer object.
