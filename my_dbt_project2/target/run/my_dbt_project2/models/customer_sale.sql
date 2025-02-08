
  create or replace   view my_db.TPCDS_SF10TCL_my_schema.customer_sale
  
   as (
    
WITH customer_sales AS (
    SELECT
        C.C_CUSTOMER_SK AS customer_id,
        C.C_FIRST_NAME AS customer_name,
        SUM(O.SS_NET_PAID) AS total_sales
    FROM
        SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER C
    JOIN
        SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.STORE_SALES O
    ON
        C.C_CUSTOMER_SK = O.SS_CUSTOMER_SK
    GROUP BY
       C.C_CUSTOMER_SK, C.C_FIRST_NAME 
)

SELECT * FROM customer_sales limit 1000
  );

