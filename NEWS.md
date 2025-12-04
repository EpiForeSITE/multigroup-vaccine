# multigroup.vaccine 0.1.1

* Fixed bug in `contactMatrixPolymod()` where age limits exceeding 90 caused
  dimension mismatch errors. The function now warns and automatically adjusts
  age limits to 90, aggregating corresponding populations into the 90+ group.
  (#39)
