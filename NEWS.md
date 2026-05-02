# multigroup.vaccine 0.2.1

* Pass `survey_pop` explicitly to `socialmixr::contact_matrix()` in
  `contactMatrixPolymod()` to avoid deprecation warning introduced in
  socialmixr 0.6.0, which will become an error in socialmixr 0.8.0.
* Update minimum required version of socialmixr to >= 0.6.0.
* Update deprecated dot-separated argument names to underscore-separated
  equivalents in `contactMatrixPolymod()` and vignette code.


* Add C++ SIR loop function for faster stochastic simulation of SIR model
* Add parallel processing capabilities for stochastic simulations

# multigroup.vaccine 0.1.1

* Initial release on CRAN

# multigroup.vaccine 0.1.0

* Initial version of package for internal research use
