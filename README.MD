# Gen AI first step - Vector Embedding for Kafka Topics

## DataGen Connector
Set up the datagen conector for product updates...   
new connector -- datagen -- custom schema   
topic name `product-updates`   

Get the product schema that data gen will use to update random products here:   
[Product Schema](https://github.com/brittonlaroche/Confluent-Kafka-Vector-Encoding/blob/main/files/datagen/productSchema.json)

## Flink SQL


### First Steps

#### 1. Create the model for vector encoding
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

```
set 'sql.secrets.openaikey' = '<your openAI API key>';
```

```
CREATE MODEL `vector_encoding`
INPUT (input STRING)
OUTPUT (vector ARRAY<FLOAT>)
WITH(
  'TASK' = 'classification',
  'PROVIDER' = 'OPENAI',
  'OPENAI.ENDPOINT' = 'https://api.openai.com/v1/embeddings',
  'OPENAI.API_KEY' = '{{sessionconfig/sql.secrets.openaikey}}'
);
```

#### 2.  Now test the model agains the product updates

```
select  * from `product-updates`, lateral table (ml_predict('vector_encoding', articleType));
```

Very cool we did vector embedding for the article type.  Now we need to build some content to vector imbed, we want to make it more like natural language.  Lets do this by concatentationg fields.   

We may also want to enrich this data so we are breaking this down into a few steps.

#### 3. create a table to hold a new content field
This table is backed up by a kafka topic with the same name for storage.

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

#### 4. Insert data into the product content table
Lets put in a new field that seems more like a natual language description that we can send to the vector encoding service.  We will create a field called "content" which concatenates all the fields except count which is the number of items in the store.  We can check inventory in a post processing step.
For now we need a product description the price, store number and product id.

```
insert into `product-content` (
				`store_id`,
				`product_id`,
				`count`,
				`price`,
				`size`, 
				`ageGroup`, 
				`gender`, 
				`season`, 
				`fashionType`, 
				`brandName`, 
				`baseColor`, 
				`articleType`,
				`content`
)
select  `store_id`,
				`product_id`,
				`count`,
				`price`,
				`size`, 
				`ageGroup`, 
				`gender`, 
				`season`, 
				`fashionType`, 
				`brandName`, 
				`baseColor`, 
				`articleType`, 
				INITCAP(
					concat_ws(' ', 
						size, 
						ageGroup, 
						gender, 
						season, 
						fashionType, 
						brandName, 
						baseColor, 
						articleType,
						', price: '||cast(price as string),
						', store number: '||cast(store_id as string),	
						', product id: '||cast(product_id as string))
				) 
		from `product-updates`;
```

#### 5.  Create the product vector table
You will notice that the table will create a new " product-vector" kafka topic and that it creates the schema for us. The vector field is an array of floats.

```
CREATE TABLE `product-vector` (
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
    `content`      STRING,
    `vector`      ARRAY<FLOAT>
);
```

#### 6. Call the embedding function and insert the data into the product-vector table
```
CREATE TABLE `product-vector` (
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
    `content`      STRING,
    `vector`      ARRAY<FLOAT>
);
```

#### 7.  Create a sink connector for your favorite vector database
My favorite is MongoDB the sink connector will create a document. Once the document is in MongoDB we create an index on the vector field for vector searches.
And we are done!
[MongoDB Example](https://www.mongodb.com/developer/products/atlas/building-generative-ai-applications-vector-search-open-source-models/)




