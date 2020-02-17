### The following functions are used to communicate with the local API

#' Check if connection to server is possible
#'
#' @importFrom httr http_error
#'
#' @export
check_connection <- function() {
  serv <- Sys.getenv("CUSTOMFP_SERVER")
  # Get retinas from the api
  httr::http_error(serv)
}

#' Register the address of the host server
#'
#' @param url url of the retina server host
#'
#' @export
set_host <- function(url) {
  Sys.setenv("CUSTOMFP_SERVER" = url)
}

#' Get the names of the retinas that are currently available
#'
#' @return list containing the names of the retinas that are currently available
#'
#' @importFrom httr GET
#' @importFrom httr stop_for_status
#' @importFrom httr content
#'
#' @export
get_custom_retinas <- function() {
  # Retrieve the server host
  serv <- Sys.getenv("CUSTOMFP_SERVER")
  # Get retinas from the api
  retinas <- httr::GET(url = file.path(serv, "retinas"))
  stop_for_status(retinas)
  # Return
  return(content(retinas))
}

#' Function that fingerprints some pieces of text or terms
#'
#' @param records list of length k of textual data
#' @param uids list of length k containing unique identifiers for the textual descriptions.
#' @param retina_name name of the retina you want to use. See the 'get_retinas' function above
#'
#' @importFrom httr POST
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @importFrom magrittr '%>%'
#' @importFrom sfutils Document
#' @importFrom sfutils as.collection
#'
#' @export
fingerprint_texts <- function(records, uids, retina_name) {
  # Get name of the local server
  serv <- Sys.getenv("CUSTOMFP_SERVER")
  # Send post request
  r <- httr::POST(url = file.path(serv,  "fingerprint"), body = list("records"=records,
                                                                         "uids"=uids,
                                                                         "retina_name"=retina_name),
                  encode="json")
  stop_for_status(r)
  # This is an R thing: the results are returned as named lists s.t. <uid> : <list of fingerprint positions>. This is a bit annoying for computations in R.
  # What we will do is unlist the lists so they become vectors.
  r_ret <- mapply(function(x, y, z) {
    # Get positions
    fp <- x %>%
      unlist()
    # If NULL, pass
    if(is.null(fp)) {
      return(NULL)
    }
    # Make document or term
    if(nchar(y) >= 50) {
      sfutils::Document(text = y,
                        fingerprint = fp,
                        uuid = z)
    } else {
      Term(term = y,
           fingerprint = fp)
    }

  }, content(r), records, uids)
  # Remove empty docs
  r_ret <- r_ret[map_lgl(r_ret, function(x) !is.null(x))] %>%
    as.collection()
  # Return
  return(r_ret)
}

#' Function that fingerprints a single text
#'
#' @param record single character string containing the text you want to fingerprint
#' @param retina_name name of the retina you want to use. See the 'get_retinas' function above
#'
#' @return sfutils Document containing the fingerprinted text
#'
#' @importFrom httr POST
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @importFrom magrittr '%>%'
#' @importFrom sfutils Document
#'
#' @export
fingerprint_text <- function(record, retina_name) {
  # Assert length 1 vector
  if(length(record) > 1) {
    stop("Cannot pass multiple records to this function. Use the function 'fingerprint_texts()'")
  }
  if(mode(record) == "list") {
    stop("Input document must be a character vector of length 1. You passed a list.")
  }
  # Get name of the local server
  serv <- Sys.getenv("CUSTOMFP_SERVER")
  # Send post request
  r <- httr::POST(url = file.path(serv,  "fingerprint"), body = list("records"=list(record),
                                                                     "uids"=list("tmp"),
                                                                     "retina_name"=retina_name),
                  encode="json")
  stop_for_status(r)
  # Get content and transform
  out <- r %>%
    content() %>%
    .[[1]] %>%
    unlist() %>%
    Document(text = record,
             fingerprint = .)
  # Return
  return(out)
}

#' Function that fingerprints a single term
#'
#' @param record single character string containing the term you want to fingerprint
#' @param retina_name name of the retina you want to use. See the 'get_retinas' function above
#'
#' @return sfutils Term containing the fingerprinted text
#'
#' @importFrom httr POST
#' @importFrom httr stop_for_status
#' @importFrom httr content
#' @importFrom magrittr '%>%'
#'
#' @export
fingerprint_term <- function(record, retina_name) {
  # Assert length 1 vector
  if(length(record) > 1) {
    stop("Cannot pass multiple records to this function.")
  }
  if(mode(record) == "list") {
    stop("Input document must be a character vector of length 1. You passed a list.")
  }
  # Assert one term only
  if(length(strsplit(record, " ")) > 2) {
    warning("You are passing a record that contains more than two words. Are you sure you are fingerprinting a single term?")
  }
  # Get name of the local server
  serv <- Sys.getenv("CUSTOMFP_SERVER")
  # Send post request
  r <- httr::POST(url = file.path(serv,  "fingerprint"), body = list("records"=list(record),
                                                                     "uids"=list("tmp"),
                                                                     "retina_name"=retina_name),
                  encode="json")
  stop_for_status(r)
  # Get content and transform
  out <- r %>%
    content() %>%
    .[[1]] %>%
    unlist() %>%
    Term(term = record,
         fingerprint = .)
  # Return
  return(out)
}

#' Retrieve all terms in the retina
#'
#' @param retina_name name of the retina
#'
#' @importFrom httr POST
#' @importFrom httr stop_for_status
#' @importFrom httr content
retrieve_terms <- function(retina_name) {
  serv <- Sys.getenv("CUSTOMFP_SERVER")
  r <- httr::POST(url = file.path(serv, "terms/all"), body = list("retina_name"= retina_name),
                  encode= "json")
  stop_for_status(r)
  return(content(r))
}

#' Retrieve similar terms for a fingerprint
#'
#' @param retina_name name of the retina
#' @param fingerprint fingerprint for which you want to retrieve similar terms
#' @param num_terms number of similar terms to retrieve
#'
#' @importFrom httr POST
#' @importFrom httr stop_for_status
#' @importFrom httr content
#'
#' @export
retrieve_similar_terms <- function(retina_name, fingerprint, num_terms = 10) {
  serv <- Sys.getenv("CUSTOMFP_SERVER")
  r <-httr::POST(url = file.path(serv, "terms/similar/fingerprint"), body = list("retina_name"= retina_name,
                                                                                       "num_terms" = num_terms,
                                                                                       "fingerprint" = fingerprint),
                  encode= "json")
  stop_for_status(r)
  return(content(r))
}
