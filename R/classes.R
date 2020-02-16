### Classes used for custom API. These will override the classes in the sfutils library

#' Fingerprint class
#'
#' This class forms the basis for the core cortical API classes (Document, Term, Expression, Filter). It should not be called by the user directly.
#'
#' @slot uuid unique id for the fingerprint. Can be passed, else generated.
#' @slot type type of fingerprint (e.g. document if text, filter if filter)
#'
#' @seealso See the \href{http://documentation.cortical.io/intro.html}{Cortical documentation} for more information about semantic fingerprinting
#'
#' @importFrom methods is
#' @importFrom methods new
#' @importFrom methods slot
#'
#' @name Fingerprint-class

.Fingerprint <- setClass(

  # Name
  "Fingerprint",
  # Slots
  slots = c(
    uuid = "character",
    type = "character"
  )

)

#' @slot term term to be fingerprinted
#' @slot df the df value of the term
#' @slot score the score of this term
#' @slot pos_types the position type of this term
#' @slot fingerprint numeric vector of the fingerprint
#'
#' @seealso See the \href{http://documentation.cortical.io/working_with_terms.html}{Cortical documentation} for more information about semantic fingerprinting and terms
#'
#' @name Term-class

.Term <- setClass(

  # Name
  "Term",
  # data
  slots = c(
    term = "character",
    fingerprint = "numeric"
  ),
  # Inherits
  contains = "Fingerprint"

)

#' Term class
#'
#' The Term class is one of the four core classes in the sfutils package. A Term is a single word.
#'
#' (From \href{Cortical documentation}{http://documentation.cortical.io/working_with_terms.html}) The basic building blocks for performing semantic computations are the representations for single terms. Each Retina contains semantic representations (fingerprints) for a large number of terms, and this page describes how to retrieve these from the API. Furthermore we describe how to query the Retina for semantically similar terms, and retrieve a list of contexts in which a given term can occur.
#'
#' @param term term to be fingerprinted
#' @param fingerprint fingerprint of the term
#' @param ... other options to be passed (uuid)
#'
#' @importFrom uuid UUIDgenerate
#'
#' @rdname Term-class
#' @export
#' @examples
#' \dontrun{
#' # Fingerprint a term
#' trm_fp <- do_fingerprint_term("Finance")
#' }

Term <- function(term,
                 fingerprint,
                 ...) {

  # If (...)
  opts <- list(...)
  uuid <- ifelse("uuid" %in% names(opts), opts$uuid, uuid::UUIDgenerate())

  # Call fingerprint class
  fp <- .Fingerprint(type = "term",
                     uuid = uuid)

  # Create class and return
  .Term(
    fp,
    term = term,
    fingerprint = (fingerprint) # SF positions run from 0:16383 but R indexes from 1
  )
}
