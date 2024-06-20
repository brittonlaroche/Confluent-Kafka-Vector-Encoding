# Gen AI First Step: RAG Data Augmentation for Gen AI
Embark on an exciting journey into the world of Retrieval-Augmented Generation (RAG) for Generative AI! The foundational step in this innovative process is creating a vector store, a dynamic tool designed for performing vector or semantic searches based on meaning.   

Traditional developers often rely on batch processes, leading to stale data and a labyrinth of point-to-point ETL integrations that demand constant maintenance. But what if there was a better way? Imagine building and maintaining a vector database with real-time data, free from the cumbersome batch ETL processes.   

This GitHub repository is your gateway to that future. Dive in and discover how to revolutionize your approach to data augmentation for Generative AI, making your workflows smarter, faster, and more efficient. Let's get started on transforming the way you handle data!   

![Flink SQL from CC GUI](/img/DataAugmentation.png)

## DataGen Connector

![Flink SQL from CC GUI](/img/setupconnector.png) 

Create a topic named `product-updates` 
Set up the datagen conector for product updates... Add a new connector, select datagen, then use the link for "additional configuration"    
   
![Datagen](/img/datagen.png) 

Use the product-updates topic.   
You will need an api key, use one if you have it if not create one and save the secret.   
new connector --> datagen --> custom schema on configuration tab  

Use the link for "additional configuration" and select JSON_SR for JSON and Schema Registry.  
   
![Additional Config](/img/additionalconfig.png) 
   
Now we need a custom schema for product updates, we will use the custom schema "Provide Your Own Schema" on configuration tab.     
Get the product schema that data gen will use to update random products here:   
[Product Schema](https://raw.githubusercontent.com/brittonlaroche/Confluent-Kafka-Vector-Encoding/main/files/datagen/productSchema.json)   

Paste it in the configuration tab.   

![Flink SQL from CC GUI](/img/additionalconfigjsonsr.png)   

   
The datagen connector will generate random product data simulating a real connector from an operational data store recieveing product updates as inventory is recieved from each retail store.



## Flink SQL


### First Steps
Flink can be accessed through the environments menu on the left-hand side of the Confluent Cloud interface. Select your environment, then navigate to the "Flink SQL" tab, which is located in the middle of the screen, instead of the default "Clusters" tab. As of this GitHub update (June 19th, 2024), the ML_Model function used in this github is in Early Access and is expected to be generally available (GA) soon.

![Flink SQL from CC GUI](/img/flinksql.png)

If flink is not set up you will need to create a new flink pool in the same region and cloud provider as your confluent cluster.  You can create a free basic cluster at for this exersize if you do not have a confluent cloud cluster here: [https://confluent.cloud/](https://confluent.cloud/)

You should issue these commands from the Confluent CLI. If you do not have the Confluent CLI, you can find the installation instructions [here](https://docs.confluent.io/confluent-cli/current/install.html). Instructions for connecting to your environment through the Confluent CLI are available [here](https://docs.confluent.io/confluent-cli/current/connect.html). 

Here are some useful confluent cli commands
```
confluent login --save --organization-id dacfbee1-acbc-my-org-id-from-the-cloud-gui

confluent environment list
confluent environment use env-myenv-from-list

confluent kafka cluster list
confluent kafka cluster use lkc-mycluster-from-list

confluent kafka topic list

```
A quick getting started guide can on the flink shell can be found [here](https://docs.confluent.io/cloud/current/flink/get-started/quick-start-shell.html#step-1-log-in-to-ccloud-with-the-confluent-cli).  
   
   
You should be able to connect to the Flink Shell with the following.   
   
![Flink SQL Copy Login](/img/flinksqllogincopy.png)   
   
Your specific environment and the connect information is displayed with a copy button (center near the bottom) in the image above. 
   
```
confluent flink shell --compute-pool lfcp-pool-from-gui --environment env-myenv-from-gui
```


Useful documentation for getting started with Flink Shell via the Confluent command line client can be found [here](https://docs.confluent.io/cloud/current/flink/get-started/quick-start-shell.html)






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

#### 2.  Now test the model to generate vector encoding against the real-time product updates

```
select  * from `product-updates`, lateral table (ml_predict('vector_encoding', articleType));
```
![Flink SQL from CC GUI](/img/flinkVectorEncoding.png)

Very cool we did vector embedding for the article type.  Now we need to build some content to vector encode, we want to make it more like natural language.  Lets do this by concatenating fields.   

We may also want to enrich this data so we are breaking this down into a few steps.

#### 3. Create a product-content table to hold a new content field
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
This statement will call the vector embedding service and will run in the background in FlinkSQL. For testing or demo purposes you may wish to stop it as it will use tokens against the embedding service.
You can see this under the running querries tab

```
insert into product_vector select * from `product-content`,
lateral table (ml_predict('vector_encoding', content));
```
To view and stop running Flink SQL statements clisck the "running statements" tab   
![Flink SQL from CC GUI](/img/flinkStatements.png)

#### 7.  Create a sink connector for your favorite vector database
My favorite is MongoDB. I created this table with additional fields because MongoDB can create a vector index on the vector field and still be able to query the rest of the fields like a regular database.  MongoDB combines the ODS and the Vector search in one place!  The sink connector will create a document. Once the document is in MongoDB we create an index on the vector field for vector searches.
And we are done!
[MongoDB Example](https://www.mongodb.com/developer/products/atlas/building-generative-ai-applications-vector-search-open-source-models/)




