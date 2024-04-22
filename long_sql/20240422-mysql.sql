
sql 执行器
from  join on 可以看成一步
where 
group by 
聚合max()
having 
select
distinct
order by
limit

sql索引
带头大哥不能死。中间兄弟不能断。
索引列上不计算。
范围之后全失效。
不等有时会失效。
like百分加右边。
覆盖索引尽量用。
一般SQL少用or
字符要加单引号。


----------------------------------------------1.理解多表联查 + 优化理论----------------------------------------------

1.3表联查
    select
         case a.invoice_type when '0' then '专票' when '1' then '普票' end  invoice_type,
         case a.invoice_status  when '1' then '正常开具' when '3' then '作废' end upload_status,
         CONCAT(a.invoice_code, a.invoice_no) invoice_no,
         STR_TO_DATE(a.issue_date, '%Y%m%d') issue_date,
         a.purepremium,
         a.tax_amount，

         b.cust_name,
         b.item_name,
         b.standard,
         b.taxrate

    from ts_s_output_invoice a
    join ts_s_invoice_info_edit b on  a.order_no = b.order_no 
    join cf_invoice_type_info c   on  b.invoice_type_code = c.invoice_type_code

    where a.issue_date like  '${monthId}%'
          and find_in_set(c.editor, #{scanuser}) &gt; 0
          and c.invoice_type_name like '%${flagName}%'
    order by a.issue_date,b.taxrate

    索引%放在左

a为主表，left join  a全量未查询到order_no的数据行项数据null



2.子查询的结果再连表
select 
    v.id
    v.name,
    v.attr_key_id,
    k.name attr as key_name
from ((select id, name as  attr_key_id 
        from attr_value
        where is_deleted = 0 
        and id in(select attr_valve_id from room_attr_value where is_deleted=0and room_id = #fid)
     ) v
left join(select id,namefrom attr keywhere is deleted=0) k 
on v.attr_key_id = k.id;l


3.复杂sql

        select
            #{monthId} month_id,
            -- 主表
            twbi.busi_name, twbi.busi_type_code, twbi.busi_type_name,
            twbi.busi_event_code, twbi.busi_event_name, twbi.busi_share_code,
            twbi.busi_share_name, twbi.share_basis, twbi.sort,

            -- 左表1
            IFNULL(stat.dmbtr,0) dmbtr,
            stat.gnfw,
            stat.ybbb,
            stat.project,
            stat.jygz,
            stat.qskm,
            stat.kmmc

            -- 左表2
            IFNULL(twaa.groupftbl,0) groupftbl,
            IFNULL(twaa.dqftje,0) dqftje,
            IFNULL(twaa.dqftje_ratio_6,0) dqftje_ratio_6,
            IFNULL(twaa.dqftje_6,0) dqftje_6,
            IFNULL(twaa.dqftje_9,0) dqftje_9,
            IFNULL(twaa.dqftje_13 ,0) dqftje_13,
            IFNULL(twaa.dqbftje,0) dqbftje, 

            -- 左表3
            IFNULL(twar.tzje,0) tzje,
        from ta_wna_b_info twbi
        left join (
            select twas.busi_share_code,twas.gnfw,twas.ybbb,
                   twas.project,twas.jygz,twas.qskm,twas.kmmc,
                   twms.dmbtr
            from (
                select distinct b.busi_type_code,a.busi_share_code, a.qskm,a.jygz,a.gnfw,a.ybbb,a.kmmc,a.project
                from ta_wna_a_subject a
                left join ta_wna_b_info b on a.busi_share_code = b.busi_share_code
                where a.del_flag = '0'
            ) twas
            left join ta_wna_month_statistics twms  
            on twas.qskm = twms.qskm 
            and twas.gnfw = twms.gnfw  
            and twas.busi_type_code = twms.busi_type_code
            and twas.busi_share_code = twms.busi_share_code
            and twms.month_id = #{monthId}
            and twms.busi_share_code = #{busiShareCode}
            ) stat 
            on twbi.busi_share_code = stat.busi_share_code
        left join ta_wna_a_amount twaa
            on twbi.busi_share_code = twaa.busi_share_code 
            and twaa.del_flag = '0'
            and stat.qskm = twaa.qskm 
            and stat.gnfw = twaa.gnfw 
            and twaa.month_id = #{monthId}
        left join (
            select busi_share_code,month_id,qskm,gnfw,SUM(tzje) tzje
            from ta_wna_a_readjust where month_id = #{monthId} and  del_flag = '0'
            group by busi_share_code,month_id,qskm,gnfw 
            ) twar
            on twbi.busi_share_code = twar.busi_share_code
            and stat.qskm = twar.qskm 
            and stat.gnfw = twar.gnfw
        where twbi.del_flag = '0'
            and twbi.busi_share_code = #{busiShareCode}
            and twbi.busi_type_code = #{busiTypeCode}
        order by twbi.sort,stat.qskm,stat.gnfw

主表：ta_wna_b_info
左表1：stat (twas(ta_wna_a_subject + ta_wna_b_info) + ta_wna_month_statistics)
左表2：ta_wna_a_amount
左表3：twar(ta_wna_a_readjust)

关联条件：busi_share_code


4.



----------------------------------------------2.理解多表设计----------------------------------------------








----------------------------------------------3.写多表联查----------------------------------------------