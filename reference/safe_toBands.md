# Internal: Safe toBands with band count check

Internal: Safe toBands with band count check

## Usage

``` r
safe_toBands(collection, max_bands = 5000)
```

## Arguments

- collection:

  An ee\$ImageCollection.

- max_bands:

  Maximum allowed bands. Default 5000.

## Value

An ee\$Image with named bands.
