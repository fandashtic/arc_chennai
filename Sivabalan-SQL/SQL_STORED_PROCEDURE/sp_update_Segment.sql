Create procedure sp_update_Segment
as   
declare @Count int  
declare @i int  
set @i = 0  
select @count = count(*) from CustomerHierarchy  
create table #temp (SegmentID int, Level int)  
while @i < @Count  
begin  
 if @i = 0   
 begin  
 	insert into #temp select SegmentID, @i+1 from CustomerSegment where parentid = @i  
 end  
 else  
 begin  
	 insert into #temp select SegmentID, @i+1 from CustomerSegment where parentid in   
	 ( select SegmentID from #temp where #temp.level = @i)  
 end  
 set @i = @i + 1  
end  
Update CustomerSegment set CustomerSegment.level = #temp.Level   
From CustomerSegment, #temp  
Where CustomerSegment.SegmentID = #temp.SegmentID  
drop table #temp  

