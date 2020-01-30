Create Procedure sp_han_ValidateOrderDetails (@OrderNumber as nvarchar(100))
as
Create Table #TempValid	(PC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS , 
  			IPC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS , 
  			UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS , 
  			IUOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
 			GroupID integer, 
 			Flag tinyint)
Insert into #TempValid 
Select OD.Product_Code, Items.Product_Code, OD.UOMID, UOM.UOM,
	Isnull(dbo.sp_han_GetCategoryGroup(Items.CategoryID), 0) GroupID, 1 
from Order_Details OD
Left Outer Join Items On OD.Product_Code = Items.Product_Code
Left Outer Join UOM On OD.UOMID = UOM.UOM
Where OD.OrderNumber = @OrderNumber 

Select PC, UOM, (Case when IPC is null then 'Invalid Item code ' + Isnull(PC, '') else '' end) I_PC, 
(Case when IUOM is null then 'Invalid UOM For the Item Code ' + Isnull(PC, '') else '' end) I_UOM, 
(Case When GroupID = 0 then 'Invalid Product Category Group' + Isnull(PC, '') else '' end) I_Group
from #TempValid
Where IPC is null or IUOM is null or GroupID = 0

Drop table #TempValid
