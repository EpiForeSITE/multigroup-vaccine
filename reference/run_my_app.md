# Runs the shiny app

Runs the shiny app

## Usage

``` r
run_my_app(...)
```

## Arguments

- ...:

  Further arguments passed to
  [`shiny::shinyAppDir()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

## Value

Starts the execution of the app, printing the port on the console.

## Details

The app featured in this package is the one presented in the shiny demo:
<https://shiny.posit.co/r/getstarted/shiny-basics/lesson1/index.html>.

## Examples

``` r
# To be executed interactively only
if (interactive()) {
  run_my_app()
}
```
