
CREATE function getBrandID(@Product_Code nvarchar(15), @Level int)  
returns int
as  
begin  
if @level = 0 begin return -1  end 
declare @Cat  nvarchar(100)
	Declare @Key int, @categoryid int  
     
      -- If product not available in the  Items table, then it is in  looping; To avoid that we check this condition
      Select @Categoryid = CategoryId From Items Where Product_Code = @Product_Code
      If @@RowCount  = 0 Begin  Return -1 End 

	select @categoryid = ItemCategories.categoryid, @key = [Level] from   
	ItemCategories where categoryid =   
	(select categoryid from items where Product_code = @Product_Code)   
StartCheck:  
if @Key < @level begin return -1  end 
if @Key = @Level  
	goto StopCheck
else  
	begin  
		Select @categoryid = ItemCategories.categoryid, @Key = [level] from ItemCategories where categoryid =   
		(select parentid from ItemCategories where [Level] = @Key  
		and categoryid = @categoryid)  
		Goto StartCheck  
	end  
StopCheck:
select @key = categoryid, @Cat = Category_Name from Itemcategories where level = @key and categoryid = @Categoryid  
return  @Key  
end

