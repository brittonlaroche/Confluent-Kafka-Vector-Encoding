# Gen AI first step Vector Embedding for Kafka Topics

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
