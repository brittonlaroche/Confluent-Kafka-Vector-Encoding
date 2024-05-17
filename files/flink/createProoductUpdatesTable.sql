CREATE TABLE product_vector (
    id INT,
    product_id INT,
    store_id INT,
    name STRING,
    price DECIMAL(10, 2),
    ageGroup STRING,
    articleType STRING,
    baseColor STRING,
    brandName STRING,
    productCount INT,
    fashionType STRING,
    gender STRING,
    season STRING,
    size STRING,
    content STRING,
    vector ARRAY<DOUBLE>
);
