# Changelog


## v1.9.1 (2025-06-17)

* **Changes:**
  * Removed the option to specify custom mapper
  * Wrapped the options `:deserialize` and `:keys_as_atoms` in a key: `[deserialize: true, keys_as_atoms: true]`
  * Fixed an issue where the response wasn't fully converted with keys as atoms

## v1.9.0 (2025-06-13)

* **Changes:**
  * Added an option `deserialize: true` to `ElasticsearchEx.Client.request/4` to deserialize the documents
  * Added an option `keys: :atoms` to `ElasticsearchEx.Client.request/4` to return a `Map` with keys as `atoms`
  * Added a GenServer to cache the mappings based on the index name.

## v1.8.5 (2025-05-23)

* **Chores:**
  * Upgraded Elixir and Erlang development version to 1.15.8 and 25.3.2.21

* **Bug fixes:**
  * Ensure the exception to be generated independently of the map keys being atoms or strings

## v1.8.4 (2025-04-18)

* **Chores:**
  * Upgraded Elixir requirement to Elixir 1.15
  * Updated development dependencies
  * Fixed Credo warning
  * Updated CI matrix to support latest versions

## v1.8.3 (2025-02-03)

* **Changes:**
  * Fixed an issue with Date values being `nil`

## v1.8.2 (2024-12-23)

* **Changes:**
  * Removed compilation dependency

## v1.8.1 (2024-12-20)

* **Changes:**
  * Added support for Elixir 1.18
  * Dropped support for Elixir 1.13

## v1.8.0 (2024-10-31)

* **Changes:**
  * Renamed the modules from `ElasticsearchEx.Api` to `ElasticsearchEx.API`
  * Added JSON as default format for the CAT operations

## v1.7.2 (2024-10-31)

* **Changes:**
  * Updated dependencies

## v1.7.1 (2024-06-30)

* **Bug fixes:**
  * Fixed a bug on `ElasticsearchEx.Sharder` where 0 was excluded from valid number

## v1.7.0 (2024-06-13)

* **New features:**
  * Added support for Elixir 1.17.0 and Erlang 27.0
  * Added a module `ElasticsearchEx.Document` to host a document from Elasticsearch

* **Changes:**
  * Updated dependencies
  * Fixed `Req` deprecations

## v1.6.0 (2024-05-15)

* **New features:**
  * Added a module `ElasticsearchEx.Serializer` to serialize document sources
  * Added a module `ElasticsearchEx.Deserializer` to deserialize document sources

## v1.5.0 (2024-05-09)

* **Changes:**
  * Added variants for `ElasticsearchEx.Api.Search.search/3`
  * Reworked some guards
  * Added variants for `ElasticsearchEx.search/3`
  * Added `ElasticsearchEx.Api.Features` module
  * Added variants for `ElasticsearchEx.Api.Search.multi_search/3`
  * Added variants for `ElasticsearchEx.Api.Search.async_search/3`
  * Added variants for `ElasticsearchEx.Api.Search.create_pit/3`
  * Added variants for `ElasticsearchEx.Api.Search.field_capabilities/3`
  * Added variants for `ElasticsearchEx.Api.Search.search_template/3`
  * Added variants for `ElasticsearchEx.Api.Search.multi_search_template/3`
  * Added variants for `ElasticsearchEx.Api.Search.render_search_template/3`
  * Added `ElasticsearchEx.Sharder` experimental module
  * Added `ElasticsearchEx.Streamer` experimental module
  * Updated some development dependencies

## v1.4.0 (2024-04-04)

* **Breaking Changes:**

  Replace the key `http_opts` by `req_opts`

* **Changes:**
  * Replaced `:any_http` by `:req`, `Req` offers the ability to provide custom `:adapter`
  * Removed the dependency `bypass`

* **Bug fixes:**
  * Fixed a bug on `ElasticsearchEx.Api.Search.create_pid/2` with empty body
  * Fixed a bug on `ElasticsearchEx.Stream.stream/3` where an extra HTTP call was made at the end of the `Stream`

## v1.3.0 (2024-04-04)

* **New features:**
  * Added `ElasticsearchEx.Stream` module to stream documents

* **Changes:**
  * Removed extra `is_list(opts)` from the API because it's already checked in the HTTP client

* **Bug fixes:**
  * Fixed a bug on `ElasticsearchEx.Api.Search.search/2` to allow `index` to be `nil`

## v1.2.0 (2024-04-04)

* **New features:**
  * Added `ElasticsearchEx.Api.Info.xpack/1`
  * Added `ElasticsearchEx.Api.Usage.xpack/1`

## v1.1.0 (2024-04-04)

* **New features:**
  * Added `ElasticsearchEx.Api.Cat.aliases/2`
  * Added `ElasticsearchEx.Api.Cat.allocation/2`
  * Added `ElasticsearchEx.Api.Cat.anomaly_detectors/2`
  * Added `ElasticsearchEx.Api.Cat.component_templates/2`
  * Added `ElasticsearchEx.Api.Cat.count/2`
  * Added `ElasticsearchEx.Api.Cat.data_frame_analytics/2`
  * Added `ElasticsearchEx.Api.Cat.datafeeds/2`
  * Added `ElasticsearchEx.Api.Cat.fielddata/2`
  * Added `ElasticsearchEx.Api.Cat.health/2`
  * Added `ElasticsearchEx.Api.Cat.indices/2`
  * Added `ElasticsearchEx.Api.Cat.master/1`
  * Added `ElasticsearchEx.Api.Cat.nodeattrs/1`
  * Added `ElasticsearchEx.Api.Cat.nodes/1`
  * Added `ElasticsearchEx.Api.Cat.pending_tasks/1`
  * Added `ElasticsearchEx.Api.Cat.plugins/1`
  * Added `ElasticsearchEx.Api.Cat.recovery/2`
  * Added `ElasticsearchEx.Api.Cat.repositories/1`
  * Added `ElasticsearchEx.Api.Cat.segments/2`
  * Added `ElasticsearchEx.Api.Cat.shards/2`
  * Added `ElasticsearchEx.Api.Cat.snapshots/2`
  * Added `ElasticsearchEx.Api.Cat.tasks/1`
  * Added `ElasticsearchEx.Api.Cat.templates/2`
  * Added `ElasticsearchEx.Api.Cat.thread_pool/2`
  * Added `ElasticsearchEx.Api.Cat.trained_models/1`
  * Added `ElasticsearchEx.Api.Cat.transforms/2`
  *
## v1.0.0 (2024-04-03)

* **Breaking Changes:**

  Changed the signatures of the functions to have dedicated arguments alongside options.

* **New features:**
  * Added `ElasticsearchEx.Api.Document.Source.get/3`
  * Added `ElasticsearchEx.Api.Document.Source.exists?/3`
  * Added `ElasticsearchEx.Api.Document.get_ids/3`
  * Added `ElasticsearchEx.Api.Document.get_docs/3`
  * Added `ElasticsearchEx.Api.Document.multi_get/3`
  * Added `ElasticsearchEx.Api.Search.explain/4`
  * Added `ElasticsearchEx.Api.Search.field_capabilities/3`
  * Added `ElasticsearchEx.Api.Search.profile/3`
  * Added `ElasticsearchEx.Api.Search.rank_evaluation/3`
  * Added `ElasticsearchEx.Api.Search.search_shards/2`
  * Added `ElasticsearchEx.Api.Search.validate/3`
  * Added `ElasticsearchEx.Api.Search.search_template/3`
  * Added `ElasticsearchEx.Api.Search.multi_search_template/3`
  * Added `ElasticsearchEx.Api.Search.render_search_template/3`
  * Added `ElasticsearchEx.Api.Search.search_vector_tile/6`

* **Changes:**
  * Rewrote functions to extract arguments from options:

    * `ElasticsearchEx.Api.Document.index/4`
    * `ElasticsearchEx.Api.Document.create/4`
    * `ElasticsearchEx.Api.Document.get/3`
    * `ElasticsearchEx.Api.Document.exists?/3`
    * `ElasticsearchEx.Api.Document.update/4`
    * `ElasticsearchEx.Api.Document.delete/3`
    * `ElasticsearchEx.Api.Search.search/3`
    * `ElasticsearchEx.Api.Search.multi_search/3`
    * `ElasticsearchEx.Api.Search.async_search/3`
    * `ElasticsearchEx.Api.Search.get_async_search/2`
    * `ElasticsearchEx.Api.Search.get_async_search_status/2`
    * `ElasticsearchEx.Api.Search.delete_async_search/2`
    * `ElasticsearchEx.Api.Search.create_pit/2`
    * `ElasticsearchEx.Api.Search.close_pit/2`

## v0.6.2 (2024-04-01)

* **Changes:**
  * Updated the dependencies
  * Updated Erlang/Elixir/Elasticsearch versions in the testing matrix

## v0.6.1 (2023-12-28)

* **Changes:**
  * Removed an option from the package preventing Dialyzer to work properly when it's used as dependency

## v0.6.0 (2023-12-28)

* **New features:**
  * Delegated `ElasticsearchEx.index/2`

* **Changes:**
  * Renamed the modules to remove the scope (tests are untouched)
  * Added more tests
  * Updated the dependency `any_http` to get rid of the issue with Dialyzer

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
