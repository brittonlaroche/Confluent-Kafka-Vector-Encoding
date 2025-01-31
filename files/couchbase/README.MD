
|Complete Walkthrough Video|    
|---------------------------|   
|[Click here to watch a 25 Minute Video on what you will create](https://youtu.be/uYxm7Yg7rgo)|   
|<a href="https://youtu.be/uYxm7Yg7rgo" target="video"><img src="../../img/CouchbaseCapella.png" width="700px" height="480px"></a>|

```json
{
    "confluent.custom.schema.registry.auto":"true",
    "couchbase.bucket":"confluent",
    "couchbase.enable.tls":"true",
    "couchbase.password":"Password1$",
    "couchbase.seed.nodes":"couchbases://cb.gdmqo64s1yetoahc.cloud.couchbase.com",
    "couchbase.topic.to.collection":"product-vector=demo.product-vector",
    "couchbase.username":"confluent",
    "key.converter":"io.confluent.connect.json.JsonSchemaConverter",
    "topics":"product-vector",
    "value.converter":"io.confluent.connect.json.JsonSchemaConverter"
}
```
