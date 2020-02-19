# customFingerprinteR

This R package enables you to easily fingerprint textual data using custom retinas.

## Installation instructions

1. Install the devtools R package on your computer. Follow the instructions given [here](https://www.rdocumentation.org/packages/devtools/versions/1.13.6).
2. Install this library: 

```r
devtools::install_github("FinTxt/customFingerprinteR")
```

## Using the library

The following image schematically shows how this package works together with the custom retina fingerprinter.

![api](img/package_and_fp.png)

There are two important pieces you need:

1. You need to set up a custom fingerprinter API using the instructions in the [docker-fingerprinter](https://github.com/FinTxt/docker-fingerprinter) repository.
2. This package!

If you follow the standard setup procedure for the custom retina API, then you will not need to change the default settings in this R package.

### Setting up

First, you need to ensure that the custom docker retina container is running. The default command, which I suggest you use, is:

```shell
docker run --rm --name fingerprinter -p 5002:5002 fintxt/fingerprinter
```

Once the API is up and running, you can start an R session and load the package:

```r
library(sfutils)
library(customFingerprinteR)
```

Make sure that the R package knows where to find the API:

```r
check_connection()
```

If there are no problems, this will return `TRUE`. If there are problems, post an issue on the [issues page](https://github.com/FinTxt/customFingerprinteR/issues).

The next thing you want to do is find out which retinas are running on your local API service:

```r
retina_names <- get_custom_retinas()
# Print
print(retina_names)
```

This will show you which retinas are loaded and ready for use.

### Fingerprinting texts and terms

There are three core functions that you can use to fingerprint documents. 

1. `fingerprint_text` fingerprints a single document of arbritary length, as long as the document is at least 50 characters long. An example is given below:

```r
io <- fingerprint_text("A trade war happens when one country retaliates against another by raising import tariffs 
                        or placing other restrictions on the opposing country's imports. A tariff is a tax or duty 
                        imposed on the goods imported into a nation.", 
                      "TenK")
```

2. `fingerprint_term` fingerprints a single term or short texts.

```r
io <- fingerprint_term("trade", "TenK")
```

3. `fingerprint_texts` fingerprints multiple documents or a mix of documents and terms.

```r
io <- fingerprint_texts(list("A trade war happens when one country retaliates against another by raising import tariffs # Document 1
                              or placing other restrictions on the opposing country's imports.",                        # Document 2
                             "A tariff is a tax or duty imposed on the goods imported into a nation."), 
                        list("text1", "text2"),                                                                         # Unique ids for documents 1 and 2
                        "TenK")                                                                                         # Name of the retina you want to use
```

### The return values

The fingerprinted documents or terms are returned using the object classes from the [sfutils library](https://jasperhg90.github.io/sfutils/). To learn more about these classes, please read the vignette [Extended introduction to sfutils](https://jasperhg90.github.io/sfutils/articles/basics.html).

### Extended example

The following example uses company descriptions data from the sfutils library.

Load the data as follows:

```r
library(purrr)
data("SAP500")
```

Next, we put the company descriptions in a list. We also use the company names as unique identifiers.

```r
# Get the descriptions
descs <- map(SAP500, function(x) x$desc) %>%
  unname() %>%
  unlist()
# Get the company names (use these as unique IDs but we could also use tickers)
uids <- map(SAP500, function(x) paste0(x$company, "-", x$ticker)) %>%
  unname() %>%
  unlist()
```

Fingerprinting these texts is as simple as executing the following command.

```r
# Fingerprint
bd <- fingerprint_texts(descs, uids, "TenK")
```

This will return a Collection class from the sfutils package. This can be useful if, for example, you want to compute distance metrics between fingerprints. However, you can easily convert these values to a list and extract the fingerprint for each company description.

```r
fps <- map(as.list(bd), function(x) fingerprint(x))
```

Note that the length of `fps` (495) is shorter than that of the list `descs` (497). This happens because there are two empty texts that we send to the API. The customFingeprinteR library automatically filters these texts out of the returned data.
