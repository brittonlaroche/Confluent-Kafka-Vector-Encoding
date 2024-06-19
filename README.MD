# Gen AI first step - Vector Embedding for Kafka Topics

## DataGen Connector
Set up the datagen conector for product updates...   
new connector -- datagen -- custom schema   
topic name `product-updates`   

Get the product schema that data gen will use to update random products here:   
[Product Schema](https://github.com/brittonlaroche/Confluent-Kafka-Vector-Encoding/blob/main/files/datagen/productSchema.json)

## Flink SQL


### First Steps

#### Create the model
```
Secret for key OPENAI.API_KEY must be set with 'set sql.secrets.<some_key> = <your_secret>' first.   
Then refer it in model options with 'OPENAI.API_KEY' = '{{sessionconfig/sql.secrets.<some_key>}}'   
   
   
set 'sql.secrets.openaikey' = 'sk-Babbmpndff5CkyrFuuVTBCiKyrAaaaBBBwwwwwxxxxdsssaa';
Statement successfully submitted.
Statement phase is COMPLETED.
configuration updated successfully.
+-----------------------+-----------------------------------------------------+
|          Key          |                        Value                        |
+-----------------------+-----------------------------------------------------+
| sql.secrets.openaikey | sk-Babbmpndff5CkyrFuuVTBCiKyrAaaaBBBwwwwwxxxxdsssaa |
+-----------------------+-----------------------------------------------------+


CREATE MODEL `vector_encoding`
INPUT (input STRING)
OUTPUT (vector ARRAY<FLOAT>)
WITH(
  'TASK' = 'classification',
  'PROVIDER' = 'OPENAI',
  'OPENAI.ENDPOINT' = 'https://api.openai.com/v1/embeddings',
  'OPENAI.API_KEY' = '{{sessionconfig/sql.secrets.openaikey}}'
);
Statement name: cli-2024-05-20-125717-5a83ee6c-1d05-4e27-b7f0-141e0b6bd416
Statement successfully submitted. 
Waiting for statement to be ready. Statement phase is PENDING. 


```

#### Now test the model agains the product updates

```
select  * from `product-updates`, lateral table (ml_predict('vector_encoding', articleType));
```

Very cool we did vector embedding for the article type.  Now we need to build some content to vector imbed, we want to make it more like natural language.  Lets do this by concatentationg fields.   

We may also want to enrich this data so we are breaking this down into a few steps.

```
CREATE TABLE `product-content` (
    `store_id` INT,                 
    `product_id`   INT,                         
    `count`        INT,                         
    `articleType`  STRING,                      
    `size`         STRING,                      
    `fashionType`  STRING,                      
    `brandName`    STRING,                      
    `baseColor`    STRING,                      
    `gender`       STRING,                      
    `ageGroup`     STRING,                     
    `price`        DOUBLE,                     
    `season`       STRING,
    `content`      STRING
);
```
