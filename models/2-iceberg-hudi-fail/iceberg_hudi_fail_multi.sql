{{
  config(
    pre_hook=['USE metastore_2'],
    file_format='hudi',
    materialized='table'
   )
}}

with final as (
    select * from metastore_1.{{ ref("iceberg_hudi_fail_1") }}
    union all
    select id, name, ts from metastore_2.{{ ref("iceberg_hudi_fail_2") }}
)

select * from final
