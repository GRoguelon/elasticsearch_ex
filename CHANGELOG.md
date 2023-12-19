# Changelog

## v0.3.0

* **New features:**
  * Added new functions related to `async_search`:
    - `ElasticsearchEx.Api.Search.Core.async_search/2`
    - `ElasticsearchEx.Api.Search.Core.get_async_search/2`
    - `ElasticsearchEx.Api.Search.Core.get_async_search_status/2`
    - `ElasticsearchEx.Api.Search.Core.delete_async_search/2`
  * Added new functions related to `pit`:
    - `ElasticsearchEx.Api.Search.Core.create_pit/1`
    - `ElasticsearchEx.Api.Search.Core.close_pit/2`

* **Changes:**
  * Added Github actions matrix to test different versions
  * Changed the development versions of Elixir and Erlang to 1.13.4 and 24.3.4.14

## v0.2.0 (2023-12-18)

* **New features:**
  * Delegated the function `ElasticsearchEx.Api.Search.Core.search/2` in `ElasticsearchEx` module ([PR-4](https://github.com/CoreCareinc/elasticsearch_ex/pull/4))
  * Added a `ElasticsearchEx.Error` exception to return an error.

* **Changes:**
  * Added Credo
  * Added Dialyxir

## v0.1.0 (2023-12-02)

* **New features:**
  * Added the function `ElasticsearchEx.Api.Search.Core.search/2` to search Elasticsearch
