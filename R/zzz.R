## Load these settings on startup

.onLoad <- function(libname = find.package("customFingerprinteR"), pkgname="customFingerprinteR") {
  # API host
  if(Sys.getenv("CUSTOMFP_SERVER") == "") {
    Sys.setenv("CUSTOMFP_SERVER" = "http://localhost:5002")
  }
}
