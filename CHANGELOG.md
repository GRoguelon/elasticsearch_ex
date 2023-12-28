# Changelog


## v0.6.1 (2023-12-28)

* **Changes:**
  * Updated the dependency `any_http` to get rid of the issue with Dialyzer

## v0.6.0 (2023-12-21)

* **New features:**
  * Delegated `ElasticsearchEx.index/2`

* **Changes:**
  * Renamed the modules to remove the scope (tests are untouched)
  * Added more tests

* **Bug fixes:**
  * Fixed a bug on `ElasticsearchEx.Api.Document.update/2` preventing to update.

## v0.5.0 (2023-12-20)

* **New features:**
  * Added the ability to specify clusters which configure an endpoint, default headers and default
  options

* **Changes:**
  * Removed the function to make `PATCH` request which isn't used by Elasticsearch
  * Removed most of the Dialyzer types causing issues
  * Added all the tests for `ElasticsearchEx.Api.Search`

* **Bug fixes:**
  * Fixed an issue preventing to make `POST` request without body

## v0.4.0 (2023-12-19)

* **New features:**
  * Added new functions related to single document operations:
    * `ElasticsearchEx.Api.Document.index/2`
    * `ElasticsearchEx.Api.Document.create/2`
    * `ElasticsearchEx.Api.Document.get_document/1`
    * `ElasticsearchEx.Api.Document.get_source/1`
    * `ElasticsearchEx.Api.Document.document_exists?/1`
    * `ElasticsearchEx.Api.Document.source_exists?/1`
    * `ElasticsearchEx.Api.Document.delete/1`
    * `ElasticsearchEx.Api.Document.update/2`

## v0.3.1 (2023-12-19)

* **Changes:**
  * Added unit tests for:
    * `ElasticsearchEx.Api.Utils`
    * `ElasticsearchEx.Client`
    * `ElasticsearchEx.Error`
    * `ElasticsearchEx.Ndjson`

* **Bug fixes:**
  * Fixed the return value for the function `ElasticsearchEx.Client.head/2` in case of error
  * Fixed the typespec for the function `ElasticsearchEx.Client.head/2` in case of error
  * Added the ability to have no body to create an exception with `ElasticsearchEx.Error`
  * Ensured the `ElasticsearchEx.Error.original` attribute is provided

## v0.3.0 (2023-12-19)

* **New features:**
  * Added new functions related to `async_search`:
    - `ElasticsearchEx.Api.Search.async_search/2`
    - `ElasticsearchEx.Api.Search.get_async_search/2`
    - `ElasticsearchEx.Api.Search.get_async_search_status/2`
    - `ElasticsearchEx.Api.Search.delete_async_search/2`
  * Added new functions related to `pit`:
    - `ElasticsearchEx.Api.Search.create_pit/1`
    - `ElasticsearchEx.Api.Search.close_pit/2`
  * Added new functions related to `scroll`:
    - `ElasticsearchEx.Api.Search.get_scroll/2`
    - `ElasticsearchEx.Api.Search.clear_scroll/2`
  * Added a new module `ElasticsearchEx.Ndjson` to manipulate NDJSON
  * Added new functions related to `multi_search`:
    - `ElasticsearchEx.Api.Search.multi_search/2`
  * Added new functions related to `terms_enum`:
    - `ElasticsearchEx.Api.Search.terms_enum/2`

* **Changes:**
  * Added Github actions matrix to test different versions
  * Changed the development versions of Elixir and Erlang to 1.13.4 and 24.3.4.14

## v0.2.0 (2023-12-18)

* **New features:**
  * Delegated the function `ElasticsearchEx.Api.Search.search/2` in `ElasticsearchEx` module
  * Added a `ElasticsearchEx.Error` exception to return an error.

* **Changes:**
  * Added Credo
  * Added Dialyxir

## v0.1.0 (2023-12-02)

* **New features:**
  * Added the function `ElasticsearchEx.Api.Search.Core.search/2` to search Elasticsearch
