{{
  config(
    pre_hook=['USE spark_catalog'],
    file_format='hudi',
    materialized='table'
   )
}}

with final as (
    select
        format_number(rand()*1000, 0) as id,
        cast(rand() as string) as name,
        current_timestamp() as ts
)

select * from final
