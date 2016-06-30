# 0.10.0

* BREAKING CHANGE: on request failure, it raises a specific error (BadRequest, InternalServerError or Unknown Error)
  instead of StandardError

# 0.9.2

* Added `OpenCPU::Client#description` to retrieve a packages' description file

# 0.9.1

* Added `convert_na_to_nil=true/false` option to Client#execute

# 0.9.0

* Added support for Github R repos through OpenCPU

# 0.8.2

* Added uri.port 

# 0.8.1

* Better error messages

# 0.8.0

* BREAKING CHANGE: verify ssl of opencpu server by default again.
* Added configuration option verify_ssl so you can disable it.
* Added format: :urlencoded for sending R-code and file parameters.

# 0.7.8

* Fixed gem by forcing json again (will add format option in 0.8)

# 0.7.7 Broken! Do not use!

* Added support for multipart requests [@amaunz]

# 0.7.6

* Made gem compatible with Ruby 1.9.3

# 0.7.0

* Added support for user packages [@ivdma]

