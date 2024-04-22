

https://leetcode.cn/problemset/database/

1、175. 组合两个表
select p.firstName,p.lastName ,a.city,a.state
from Person p left join Address a on p.personId = a.personId
order by firstName;



2、577. 员工奖金
select 
e.name , b.bonus 
from Employee  e  
left join Bonus  b
on e.empId  = b.empId 
where b.bonus is null or bonus < 1000

防止少数据
b.bonus is null


3、176. 第二高的薪水

1、对不同的薪资进行降序排序，然后利用 LIMIT 子句来获得第二高的薪资。
SELECT (SELECT DISTINCT Salary FROM Employee ORDER BY Salary DESC LIMIT 1 OFFSET 1) AS SecondHighestSalary

2、窗口函数
select if(max(rk)<2,null,t1.salary) SecondHighestSalary 
from (select *,dense_rank(over(order by salary desc) rk  from Employee) t1 
where t1.rk=2;

dense_rank(over(order by salary desc)
窗口排名函数dense_rank()同值同排名无跳级
max(rk)取rk的最大值，用if判断是否存在第二名



