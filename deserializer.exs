default_opts = [cluster: %{
  headers: %{
    "Authorization" =>
      "ApiKey VG5obFBvQUI1WUl4TjlTOE14ZXY6VzRnVG82SENUZUtRTnZZQ1JEbkEwUQ=="
  },
  endpoint:
    "https://728f055801f246699358af768edfcd29.vpce.us-east-1.aws.elastic-cloud.com:9243"
}]


{:ok, mappings} =  ElasticsearchEx.Client.get("/latest-biller-views-tx-hha/_mapping", nil, nil, default_opts)
[%{"mappings" => mappings}] = Map.values(mappings)
{:ok, document} =  ElasticsearchEx.Client.get("/latest-biller-views-tx-hha/_doc/2PUqM44BgEK069YMaLvW", nil, nil, default_opts)

ElasticsearchEx.Deserializer.deserialize_document(document, mappings) |> IO.inspect()
# result2 = ElasticsearchEx.Serializer.serialize_document(result, mappings) |> IO.inspect()
