# multigroup.vaccine 0.1.1

* Fixed bug in `contactMatrixPolymod()` where age limits exceeding 70 caused
  dimension mismatch errors. The function now warns and automatically adjusts
  age limits to 70, aggregating corresponding populations into the 70+ group.
  (#39)
