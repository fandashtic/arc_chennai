CREATE function getBrandName(@Product_Code nvarchar(15), @Level int)      
returns nvarchar(255)    
as      
begin      
if @level = 0 begin return -1  end     
declare @Cat  nvarchar(100)    
 Declare @Key int, @categoryid int      
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
return  @Cat      
end    
    
  


