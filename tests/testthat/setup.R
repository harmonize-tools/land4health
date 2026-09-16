if (requireNamespace("rgee", quietly = TRUE)) {
  tryCatch(
    {
      ee <- rgee::ee
      ee$Number(1)$getInfo()
    },
    error = function(e) {
      tryCatch(
        rgee::ee_Initialize(
          email = Sys.getenv("GEE_EMAIL", "antony.barja8@gmail.com"),
          credentials = "persistent",
          auth_mode = "appdefault",
          drive = FALSE,
          gcs = FALSE,
          quiet = TRUE
        ),
        error = function(e2) {
          message("GEE could not be initialized: ", conditionMessage(e2))
        }
      )
    }
  )
}
