CREATE Procedure sp_ser_rpt_ItemList(@Personnel as nvarchar(255))  
As  

Declare @ParamSep nVarchar(10)  
Declare @PersonnelID nvarchar(50)  
Declare @CategoryID Int  
Declare @tempString nvarchar(50)
Declare @ParamSepcounter int 
Set @ParamSep = Char(2)  
Set @tempString = @Personnel                                                          
                                                          
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                                                              
set @PersonnelID = substring(@tempString, 1, @ParamSepcounter-1)                                                           
                                                
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Personnel))                                                           
set @CategoryID =  @tempString                                

select Personnel_item_category.product_Code,  
'Item Code' = Personnel_item_category.Product_code,  
'Item Name' = ProductName  
from Personnel_item_category,Items  
where Personnel_item_category.PersonnelID = @PersonnelID
and Personnel_item_category.CategoryID = @CategoryID
and Personnel_item_category.Product_code = items.Product_code  



