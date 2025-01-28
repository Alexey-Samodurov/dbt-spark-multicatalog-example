{{
  config(
    pre_hook=['USE spark_catalog'],
    file_format='hudi',
    materialized='table'
   )
}}

with final as (
    select * from metastore_1.{{ ref("iceberg_hudi_ok_1") }}
    union all
    select id, name, ts from spark_catalog.{{ ref("iceberg_hudi_ok_2") }}
)

select * from final
