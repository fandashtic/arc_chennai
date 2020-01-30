CREATE Procedure sp_ser_rpt_ItemSpareList(@Item nvarchar(255))  
AS  
Declare @ParamSep nVarchar(10)  
Declare @TaskID int  
Declare @Task int
Declare @ITemTaskID nvarchar(50)
Declare @SpareCode nvarchar(50)  
Set @ParamSep = Char(2)  
Set @Task = CHARINDEX(@ParamSep,@Item,1)  
set @ItemTaskID = cast(Substring(@Item,1,@Task-1) as nvarchar(255)) 
Set @TaskID = CHARINDEX(@ParamSep,@Item,1)  
set @SpareCode = cast(Substring(@Item,@TaskID + 1,len(@Item) - @TaskID) as nvarchar(255))    
select SpareCode,'Spare Code'=Task_Items_Spares.SpareCode,  
'Spare Name' = Items.ProductName,  
'UOM' = uom.[Description],  
'Qty' = UOMQty  
from Task_items_spares,UOM,Items  
where Task_items_spares.uom = UOM.uom  
and task_items_spares.sparecode = Items.Product_code   
and task_items_spares.Product_code = @SpareCode  
and task_items_spares.TaskID = @ItemTaskID

