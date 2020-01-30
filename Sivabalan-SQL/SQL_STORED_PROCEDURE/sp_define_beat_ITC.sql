
CREATE Procedure sp_define_beat_ITC  
as  

Create Table #temp (BeatID Int, [Description] nVarchar(256), SalesmanID Int, 
Salesman_Name nVarChar(256), MON int, TUE int, WED int, THU int, FRI int, SAT int, SUN int)

Insert Into #temp (BeatID, [Description], SalesmanID, Salesman_Name) 
select b.beatid, b.description ,s.salesmanid , s.salesman_name 
from beat b
Inner Join beat_salesman bs On b.beatid = bs.beatid 
Left Outer Join salesman s  On  bs.salesmanid = s.salesmanid 
where b.Active = 1  
group by b.beatid, b.description ,s.salesmanid , s.salesman_name   

-- Select * From #temp

Update #temp set #temp.mon = Case IsNull(al.mon, 0) When 0 Then #temp.mon 
						    When 1 Then al.mon end,
#temp.tue = Case IsNull(al.tue, 0) When 0 Then #temp.tue
				   When 1 Then al.tue end,
#temp.wed = Case IsNull(al.wed, 0) When 0 Then #temp.wed
				   When 1 Then al.wed end,
#temp.thu = Case IsNull(al.thu, 0) When 0 Then #temp.thu 
				   When 1 Then al.thu end,
#temp.fri = Case IsNull(al.fri, 0) When 0 Then #temp.fri
				   When 1 Then al.fri end,
#temp.sat = Case IsNull(al.sat, 0) When 0 Then #temp.sat
				   When 1 Then al.sat end,
#temp.sun = Case IsNull(al.sun, 0) When 0 Then #temp.sun
				   When 1 Then al.sun end
From #temp , beat_salesman al where #temp.beatid = al.beatid
And (al.mon = 1 or al.tue = 1 or al.wed = 1 or al.thu = 1 
or al.fri = 1 or al.sat = 1 or al.sun = 1)

Select BeatID , [Description] , SalesmanID , 
Salesman_Name , MON , TUE , WED , THU , FRI , SAT , SUN 
From #temp Order By [Description]


drop table #temp

