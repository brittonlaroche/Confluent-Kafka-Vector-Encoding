# Gen AI First Step: Vector Encoding for Retrieval-Augmented Generation (RAG)
Embark on an exciting journey into the world of Retrieval-Augmented Generation (RAG) for Generative AI! The foundational step in this innovative process is creating a vector store, a dynamic tool designed for performing vector or semantic searches based on meaning. RAG is used to generate prompts to the Large Language Model (LLM) with proprietary data, enabling the LLM to make precise recommendations. 

|Complete Walkthrough Video|    
|---------------------------|   
|[Click here to watch a 25 Minute Video on what you will create](https://www.youtube.com/watch?v=Sv_59o66hRE)|   
|<a href="https://www.youtube.com/watch?v=Sv_59o66hRE" target="video"><img src="https://img.youtube.com/vi/Sv_59o66hRE/0.jpg" width="700px" height="480px"></a>|   

In the context of Generative AI, a vector is a mathematical representation of data that captures its semantic meaning. It is a numerical array, where each element of the array represents a feature or characteristic of the data. Vectors are used to encode information in a way that can be easily processed by machine learning models, particularly for tasks that involve understanding and generating natural language.

### How Vectors Are Used by Gen AI     
   
***Data Representation:***   
   
Vectors transform raw data (such as text, images, or audio) into a structured format that models can understand. For text, this involves converting words, sentences, or documents into fixed-length arrays of numbers.   

***Semantic Search:***   
   
Vectors allow for semantic search, meaning searches based on the meaning of the data rather than just keywords. For example, similar words or phrases will have similar vector representations, enabling more accurate and relevant search results.   

***Retrieval-Augmented Generation (RAG):***   
   
In RAG, vectors are used to retrieve relevant data from a vector database. When a query is made, the system converts it into a vector and searches the vector database for the closest matches. This relevant data is then used to generate context-aware responses or recommendations. [Learn more about RAG here](https://www.confluent.io/learn/retrieval-augmented-generation-rag/)      

***Training and Inference:***   
   
During the training phase, AI models learn to convert input data into vectors that capture the essential features and relationships. During inference, these vectors are used to generate outputs, such as text generation, image recognition, or recommendation systems.   
   
***Contextual Understanding:***

Vectors enable AI models to understand the context and relationships between different pieces of data. For instance, in natural language processing (NLP), vectors can represent the context of words within a sentence, helping the model generate coherent and contextually appropriate responses.

### Example Use in Generative AI
Imagine a Generative AI system designed to recommend clothing items based on user preferences:   
   
User Query: "Find me a red summer dress in medium size."   
Vectorization: The query is converted into a vector.   
Semantic Search: The vector is used to search a vector database of clothing items.   
Data Retrieval: The most relevant items (red, summer dresses, medium size) are retrieved.   
Prompt Generation: These items are used to create a prompt for the LLM.   
LLM Response: The LLM generates a response with specific and accurate recommendations for the user.   
   
In summary, vectors are essential for transforming unstructured data into a format that Generative AI can effectively process, enabling tasks like semantic search, contextual understanding, and precise data retrieval.   


[Learn more about Generative AI here](https://www.confluent.io/learn/generative-ai/)   

## Getting started ##

In this github example, retail data from source systems will be vector encoded in real-time as data changes. It will be inserted as the data sourced from a connector int a topic.  It will then be converted into a vector with flink SQL inserted into a new topic.  The connector architecture will then sink this data into a vector database. This GitHub example shows you how to do this first step of hydrating and maintaing a vector database with out using any batch ETL processes. 

Next the Gennerative AI application will query this vector database. With the user profile data and questions the meaning will be matched to the size of clothing and the fashion type requested by the user's query. The results will be sent to the LLM as prompts, ensuring that the recommendations made by the LLM are specific and accurate.
[See a demo of the vector database query in action here](https://www.youtube.com/watch?v=pLU7dS9DJJg)    
[The github behind this demo is here](https://github.com/brittonlaroche/GenAI-ChatGPT4-Confluent-MongoDB-Vector-Retail/)

Traditional developers often rely on batch processes to vector enocde their data, leading to stale data and a labyrinth of point-to-point ETL integrations that demand constant maintenance. But what if there was a better way? Imagine building and maintaining a vector database with real-time data, free from the cumbersome batch ETL processes.

This GitHub repository is your gateway to that future. Dive in and discover how to revolutionize your approach to data augmentation for Generative AI, making your workflows smarter, faster, and more efficient. Let's get started on transforming the way you handle data!  
   
![Flink SQL from CC GUI](/img/DataAugmentation.png)

## DataGen Connector
Before we can convert data into vectors, we need some sample data. Setting up a connector to a retail database would be time-consuming, so for the purposes of this demo, we will generate some random data using Confluent Cloud's datagen connector. To get started, we need to create the datagen connector and have it insert data into a `product-updates` topic.  

[Oracle Connector Example in Github Here](https://github.com/brittonlaroche/Oracle-Confluent-MongoDB)

![Flink SQL from CC GUI](/img/setupconnector.png) 

Create a topic named `product-updates` 
Set up the datagen conector for product updates... Add a new connector, select datagen, then use the link for "additional configuration"    
   
![Datagen](/img/datagen.png) 

Use the **product-updates** topic.   
You will need an api key, use one if you have it if not create one and save the secret.   
new connector --> datagen --> custom schema on configuration tab  

Use the link for "additional configuration" and select JSON_SR for JSON and Schema Registry.  
   
![Additional Config](/img/additionalconfig.png) 
   
Now we need a custom schema for product updates, we will use the custom schema "Provide Your Own Schema" on configuration tab.  
   
Get the product schema that datagen will use to update random products here:      
[Product Schema](https://raw.githubusercontent.com/brittonlaroche/Confluent-Kafka-Vector-Encoding/main/files/datagen/productSchema.json)   

Paste it in the configuration tab.   

![Flink SQL from CC GUI](/img/additionalconfigjsonsr.png)   
   
Get the product schema that datagen will use to update random products here:      
[Product Schema](https://raw.githubusercontent.com/brittonlaroche/Confluent-Kafka-Vector-Encoding/main/files/datagen/productSchema.json)   
   
The datagen connector will generate random product data simulating a real connector from an operational data store recieveing product updates as inventory is recieved from each retail store.

You will need to adjust a couple of settings to get some of the data to display properly in the cloud gui.  Go to the Datagen Connector we just created and under "settings" Set the following parameters:   
   
`JSON output decimal format: BASE64`   
`Schema Context: Default`   
`Max interval between messages (MS): 25000`   

**Trasforms**   
Add a new value single message transform.   
For the value of the price field set the spec to `price:float64`   
   
![Transforms from CC GUI](/img/transforms.png)   

## Flink SQL


### First Steps
Flink can be accessed through the environments menu on the left-hand side of the Confluent Cloud interface. Select your environment, then navigate to the "Flink SQL" tab, which is located in the middle of the screen, instead of the default "Clusters" tab. As of this GitHub update (August 13th, 2024), the ML_Predict function used in this github is in Early Access.    
   
**If you have issues with the ML_Predict Function because it is not available for your organization send me an email from your work email address to blaroche@confluent.io with the subject "Requesting EA ML_Predict function"** I will add your organization to the EA request list.  You should be good to go with in a day or so provided you do have an existing cloud organization for your company.  

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
 
   

#### 1. Set the connection information
Before we enter the flink environment we need to create the connection to the endpoint for the vector embedding service.  For this step you need an API key.  Theis example uses OPENAI, there are plenty to choose from, but to follow along and if you do not have an API key, no worries, you can get started by using the link below to get your own OPENAI API key.   
[https://platform.openai.com/docs/quickstart](https://platform.openai.com/docs/quickstart)
   

An example of creating a connection in the confluent cli is provided below:    
   
```
confluent flink connection create openai_vector_connection --endpoint 'https://api.openai.com/v1/embeddings' --api_key 'secret_key'
```   

After setting the connection information we can now start working in Flink SQL.  A quick getting started guide can on the flink shell can be found [here](https://docs.confluent.io/cloud/current/flink/get-started/quick-start-shell.html#step-1-log-in-to-ccloud-with-the-confluent-cli).  
   
You should be able to connect to the Flink Shell with the following.   
   
![Flink SQL Copy Login](/img/flinksqllogincopy.png)   
   
Your specific environment and the connect information is displayed with a copy button (center near the bottom) in the image above. 
   
```
confluent flink shell --compute-pool lfcp-pool-from-gui --environment env-myenv-from-gui
```


Useful documentation for getting started with Flink Shell via the Confluent command line client can be found [here](https://docs.confluent.io/cloud/current/flink/get-started/quick-start-shell.html)






#### 2. Create the model for vector encoding

Below is an example of succesful output:  
```
CREATE MODEL `vector_encoding`
INPUT (input STRING)
OUTPUT (vector ARRAY<FLOAT>)
WITH(
  'TASK' = 'embedding',
  'PROVIDER' = 'openai',
  'OPENAI.CONNECTION' = 'openai_vector_connection',
);
Statement name: cli-2024-05-20-125717-5a83ee6c-1d05-4e27-b7f0-141e0b6bd416
Statement successfully submitted. 
Waiting for statement to be ready. Statement phase is PENDING. 


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

Very cool! We did vector embedding for the article type, and it was pretty effortless.  Now we need to build some content to vector encode, we want to make it more like natural language.  Lets do this by concatenating fields.   

We may also want to enrich this data so we are breaking this down into a few steps.

**Trouble Shooting**   
If you are not getting data back it could be your API key check with your API provider and try a postman or a curl command.   
[https://platform.openai.com/docs/guides/embeddings](https://platform.openai.com/docs/guides/embeddings)

```
curl https://api.openai.com/v1/embeddings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{
    "input": "Your text string goes here",
    "model": "text-embedding-3-small"
  }'
```   
   

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
) WITH (
  'value.format' = 'json-registry'
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
) WITH (
  'value.format' = 'json-registry'
);
```

#### 6. Call the embedding function and insert the data into the product-vector table
This statement will call the vector embedding service and will run in the background in FlinkSQL. For testing or demo purposes you may wish to stop it as it will use tokens against the embedding service.
You can see this under the running querries tab

```
insert into `product-vector` select * from `product-content`,
lateral table (ml_predict('vector_encoding', content));
```
To view and stop running Flink SQL statements click the "running statements" tab   
![Flink SQL from CC GUI](/img/flinkStatements.png)

#### 7.  Create a sink connector for your favorite vector database
My favorite is MongoDB Atlas Vector Search. I created the `product-vector` table with additional fields because MongoDB can create a vector index on the vector field and still be able to query the rest of the fields like a regular database.  MongoDB combines the Operational Data Store (ODS) and the Vector search in one place!  The sink connector will create a document. There is a powerful synergy between Kafka, Confluent and MongoDB that we like to call Kafcongo.

Start by opening the Confluent Cloud and MongoDB Atlas clusters in the browser:   

[https://confluent.cloud](https://confluent.cloud) and [https://cloud.mongodb.com](https://cloud.mongodb.com)

Lets start by opening the [Confluent Cloud](https://confluent.cloud) console window.  Navigate to "Enviroments" and select the "default" environment where we created our basic cluster. Click on the basic cluster we used for this exercise and select "Connectors" on the left hand side menu.   

In the connectors console we will see a list of connectors (if we have any) and a button in the upper right that says "Add a Connector."  Click the add a connector button and search for MongoDB.  Lets select the fully managed "MongoDB Sink Connector" and we will begin configuration.
    
| Hands on Video: Creating a Fully Managed MongoDB Atlas Sink Connector in the Confluent Cloud  |
|----------------|
|[Click here to watch a 6 Minute Video on creating a mongoDB sink connector](https://www.youtube.com/watch?v=_9cvz7kmeCg&list=PLjGEA1Gur_Sm_1MRUwXFngYeAQ1wV7lah&index=6)|   
|<a href="https://www.youtube.com/watch?v=_9cvz7kmeCg&list=PLjGEA1Gur_Sm_1MRUwXFngYeAQ1wV7lah&index=6" target="video"></a>| 

Once the document is in MongoDB we create an index on the vector field for vector searches.  
[MongoDB Vector Index Example Here](https://www.mongodb.com/developer/products/atlas/building-generative-ai-applications-vector-search-open-source-models/)
   
And we are done!    
   
   


Another github on the power of Confluent with MongoDB Atlas showing how to perform legacy migration from relational databases like Oracle to a modern cloud native database like MongoDB Atlas is below.  The github is useful for trouble shooting connector data types with Single Message Transform (SMT):   
[https://github.com/brittonlaroche/Oracle-Confluent-MongoDB](https://github.com/brittonlaroche/Oracle-Confluent-MongoDB)



