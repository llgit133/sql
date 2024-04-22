


建立索引的字段为：month_id,trade_type_name,trade_type_code
分析下面2个sql
explain select * from tl_check_result where month_id ='202403';
explain select month_id ,trade_type_name ,trade_type_code from tl_check_result where month_id ='202403';

QUERY PLAN