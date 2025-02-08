## ลำดับขั้นตอนในการสร้าง โมเดลข้อมูล (Data Model) ง่ายๆ ใน DBT โดยใช้ SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000 dataset จาก Snowflake:

### ขั้นตอนที่ 1: ติดตั้ง DBT พร้อมกับ Snowflake Adapter
หากคุณยังไม่ได้ติดตั้ง DBT คุณสามารถติดตั้ง DBT พร้อมกับ Snowflake adapter ด้วยคำสั่ง:

```bash
pip install dbt-snowflake
```
### ขั้นตอนที่ 2: สร้างโปรเจ็กต์ DBT
หากคุณยังไม่มีโปรเจ็กต์ DBT ให้สร้างโปรเจ็กต์ใหม่โดยใช้คำสั่งนี้:

```bash
dbt init my_dbt_project
```
คำสั่งนี้จะสร้างโครงสร้างของโปรเจ็กต์ DBT สำหรับคุณ

### ขั้นตอนที่ 3: ตั้งค่า profiles.yml สำหรับเชื่อมต่อกับ Snowflake
ไฟล์ profiles.yml ใช้สำหรับเก็บข้อมูลการเชื่อมต่อของ Snowflake คุณต้องสร้างไฟล์นี้ในโฟลเดอร์ ~/.dbt/ และตั้งค่าดังนี้:

```yaml
my_dbt_project:  # ตั้งชื่อโปรเจ็กต์ DBT ของคุณ
  target: dev  # กำหนดเป้าหมายเริ่มต้น (target) เป็น dev สำหรับ environment การพัฒนา
  outputs:  # กำหนดการเชื่อมต่อ (outputs) สำหรับแต่ละ environment
    dev:  # เชื่อมต่อกับ Snowflake สำหรับ dev environment
      type: snowflake  # ประเภทฐานข้อมูลเป็น Snowflake
      account: gynanmd-sb40860.snowflakecomputing.com  # ชื่อบัญชี Snowflake
      user: SAKDALOET  # ชื่อผู้ใช้ในการเชื่อมต่อ
      password: <your_password>  # รหัสผ่าน
      role: ACCOUNTADMIN  # บทบาทของผู้ใช้
      database: SNOWFLAKE_SAMPLE_DATA  # ชื่อฐานข้อมูล
      warehouse: <your_warehouse>  # ชื่อคลังข้อมูล
      schema: <your_schema>  # ชื่อสคีมาของฐานข้อมูล
      threads: 1  # จำนวนเธรดที่ใช้ในการประมวลผล
      client_session_keep_alive: False  # การเก็บเซสชัน

    prod:  # เชื่อมต่อกับ Snowflake สำหรับ prod environment
      type: snowflake  # ประเภทฐานข้อมูลเป็น Snowflake
      account: <your_account>.snowflakecomputing.com  # ชื่อบัญชี Snowflake
      user: <your_prod_user>  # ชื่อผู้ใช้สำหรับ production
      password: <your_prod_password>  # รหัสผ่านสำหรับ production
      role: <your_prod_role>  # บทบาทของผู้ใช้สำหรับ production
      database: PROD_DATABASE  # ชื่อฐานข้อมูลสำหรับ production
      warehouse: <your_prod_warehouse>  # ชื่อคลังข้อมูลสำหรับ production
      schema: <your_prod_schema>  # ชื่อสคีมาของฐานข้อมูลสำหรับ production
      threads: 4  # จำนวนเธรดที่ใช้ในการประมวลผลใน production
      client_session_keep_alive: True  # การเก็บเซสชันใน production

    staging:  # เชื่อมต่อกับ Snowflake สำหรับ staging environment
      type: snowflake  # ประเภทฐานข้อมูลเป็น Snowflake
      account: <your_account>.snowflakecomputing.com  # ชื่อบัญชี Snowflake
      user: <your_staging_user>  # ชื่อผู้ใช้สำหรับ staging
      password: <your_staging_password>  # รหัสผ่านสำหรับ staging
      role: <your_staging_role>  # บทบาทของผู้ใช้สำหรับ staging
      database: STAGING_DATABASE  # ชื่อฐานข้อมูลสำหรับ staging
      warehouse: <your_staging_warehouse>  # ชื่อคลังข้อมูลสำหรับ staging
      schema: <your_staging_schema>  # ชื่อสคีมาของฐานข้อมูลสำหรับ staging
      threads: 2  # จำนวนเธรดที่ใช้ในการประมวลผลใน staging
      client_session_keep_alive: False  # การเก็บเซสชันใน staging

```
หมายเหตุ: คุณต้องแทนที่ <your_account>, <your_user>, <your_password> และค่าต่างๆ ด้วยข้อมูลที่แท้จริงจาก Snowflake ของคุณ

### ขั้นตอนที่ 4: สร้าง Model ใหม่
ไปที่โฟลเดอร์ models ในโปรเจ็กต์ DBT ของคุณ
สร้างไฟล์ SQL ใหม่ เช่น customer_sales.sql ภายในโฟลเดอร์ models
### ขั้นตอนที่ 5: กำหนด SQL สำหรับ DBT Model
ในไฟล์ customer_sales.sql ให้เขียนคำสั่ง SQL สำหรับการรวมข้อมูลยอดขายจากตาราง customer และ orders:

```sql
-- models/customer_sales.sql

{{ config(
    database='my_db',  
    schema='my_schema'  
) }}
WITH customer_sales AS (
    SELECT
        c.c_custkey AS customer_id,
        c.c_name AS customer_name,
        SUM(o.o_totalprice) AS total_sales
    FROM
        {{ source('TPCH_SF1000', 'customer') }} c
    JOIN
        {{ source('TPCH_SF1000', 'orders') }} o
    ON
        c.c_custkey = o.o_custkey
    GROUP BY
        c.c_custkey, c.c_name
)

SELECT * FROM customer_sales
```

### ขั้นตอนที่ 6: กำหนด Sources ในไฟล์ schema.yml
DBT ใช้ไฟล์ schema.yml สำหรับกำหนดแหล่งข้อมูล (sources) และการทดสอบ (tests) ให้เพิ่มไฟล์ schema.yml ในโฟลเดอร์ models ดังนี้:

```yaml
version: 2

sources:
  - name: TPCH_SF1000
    database: SNOWFLAKE_SAMPLE_DATA
    schema: TPCH_SF1000
    tables:
      - name: customer
      - name: orders

models:
  - name: customer_sales
    description: "การรวมยอดขายทั้งหมดตามลูกค้า"
    columns:
      - name: customer_id
        description: "รหัสลูกค้าที่ไม่ซ้ำ"
      - name: customer_name
        description: "ชื่อลูกค้า"
      - name: total_sales
        description: "ยอดขายรวมของลูกค้า"
```
### ขั้นตอนที่ 7: รัน DBT Model
หลังจากที่ตั้งค่าทุกอย่างเสร็จแล้ว คุณสามารถรันโมเดล DBT โดยใช้คำสั่ง:

```bash
dbt run
```
คำสั่งนี้จะรัน SQL ที่คุณเขียนในไฟล์ customer_sales.sql และสร้างตารางหรือมุมมอง (view) ใน Snowflake

### ขั้นตอนที่ 8: ทดสอบโมเดล
คุณสามารถทดสอบโมเดลของคุณด้วยคำสั่ง dbt test โดยเพิ่มการทดสอบ (เช่น ทดสอบคอลัมน์ total_sales ว่ามีค่า not null) ในไฟล์ schema.yml ดังนี้:

```yaml
models:
  - name: customer_sales
    description: "การรวมยอดขายทั้งหมดตามลูกค้า"
    columns:
      - name: customer_id
        description: "รหัสลูกค้าที่ไม่ซ้ำ"
      - name: customer_name
        description: "ชื่อลูกค้า"
      - name: total_sales
        description: "ยอดขายรวมของลูกค้า"
        tests:
          - not_null
```
จากนั้นให้รันคำสั่ง:

```bash
dbt test
```
### ขั้นตอนที่ 9: สร้างเอกสาร DBT
สุดท้าย คุณสามารถสร้างเอกสารสำหรับโปรเจ็กต์ DBT โดยใช้คำสั่ง:

```bash
dbt docs generate
```
แล้วรันคำสั่งนี้เพื่อเปิดเอกสารในเบราว์เซอร์:

```bash
dbt docs serve
```
### สรุป
- ติดตั้ง DBT พร้อม Snowflake adapter
- ตั้งค่าการเชื่อมต่อ Snowflake ในไฟล์ profiles.yml
- สร้างโมเดล DBT (SQL file) ที่เชื่อมโยงข้อมูลจากตาราง TPCH_SF1000
- รันโมเดล ด้วยคำสั่ง dbt run
- ทดสอบ และ สร้างเอกสาร สำหรับโมเดล DBT
