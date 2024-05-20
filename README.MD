# Gen AI first step - Vector Embedding for Kafka Topics

## DataGen Connector

## Flink SQL

```sql
select *, 
INITCAP(
	concat_ws(' ', 
		size, 
		ageGroup, 
		gender, 
		season, 
		fashionType, 
		brandName, 
		baseColor, 
		articleType)
) as content 
from `product-updates`;
```

### First Steps

```
Secret for key OPENAI.API_KEY must be set with 'set sql.secrets.<some_key> = <your_secret>' first. Then refer it in model options with 'OPENAI.API_KEY' = '{{sessionconfig/sql.secrets.<some_key>}}'   
   
   
set 'sql.secrets.openaikey' = 'sk-Babbmpndff5CkyrFuuVTBCiKyrAaaaBBBwwwwwxxxxdsssaa';
Statement successfully submitted.
Statement phase is COMPLETED.
configuration updated successfully.
+-----------------------+-----------------------------------------------------+
|          Key          |                        Value                        |
+-----------------------+-----------------------------------------------------+
| sql.secrets.openaikey | sk-Babbmpndff5CkyrFuuVTBCiKyrAaaaBBBwwwwwxxxxdsssaa |
+-----------------------+-----------------------------------------------------+
```
