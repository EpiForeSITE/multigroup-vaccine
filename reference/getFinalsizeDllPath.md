# Get the Loaded `multigroup.vaccine` Shared Library Path

Internal helper used to initialize parallel workers during local
development, where the package may be loaded from a temporary `pkgload`
path rather than an installed library tree.

## Usage

``` r
getFinalsizeDllPath()
```

## Value

The path to the loaded shared library, or `NULL` if the package DLL is
not currently loaded.
