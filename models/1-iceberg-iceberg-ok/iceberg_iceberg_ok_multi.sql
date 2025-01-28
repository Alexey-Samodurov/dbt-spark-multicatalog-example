{{
  config(
    pre_hook=['USE metastore_2'],
    file_format='iceberg',
    materialized='table'
   )
}}

with final as (
    select * from metastore_1.{{ ref("iceberg_iceberg_ok_1") }}
    union all
    select * from metastore_2.{{ ref("iceberg_iceberg_ok_2") }}
)

select * from final
