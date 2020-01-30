
CREATE procedure sp_update_categories
as 
declare @Count int
declare @i int
set @i = 0
select @count = count(*) from ItemHierarchy
create table #temp (categoryid int, Level int)
while @i < @Count
begin
	if @i = 0 
	begin
		insert into #temp select categoryid, @i+1 from itemcategories where parentid = @i
	end
	else
	begin
		insert into #temp select categoryid, @i+1 from itemcategories where parentid in 
		( select categoryid from #temp where #temp.level = @i)
	end
	set @i = @i + 1
end
Update ItemCategories set Itemcategories.level = #temp.Level 
From ItemCategories, #temp
Where ItemCategories.CategoryID = #temp.CategoryID
drop table #temp

