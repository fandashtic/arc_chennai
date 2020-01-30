CREATE Procedure sp_han_ValidateStockReturn (@ReturnNumber as nvarchar(100))        
as        
Create Table #TempValid (PC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,         
     IPC nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,         
     UOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS ,         
     IUOM nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,        
    GroupID integer,         
    Flag tinyint)        
Insert into #TempValid         
Select SR.Product_Code, Items.Product_Code, SR.UOM, UOM.UOM,        
 Isnull(dbo.sp_han_GetCategoryGroup(Items.CategoryID), 0) GroupID, 1         
from Stock_Return SR        
Left Outer Join Items On SR.Product_Code = Items.Product_Code        
Left Outer Join UOM On SR.UOM = UOM.UOM        
Where SR.ReturnNumber = @ReturnNumber         
Select PC, UOM, (Case when IPC is null then 'Item code ['+ Isnull(PC, '')+'] is invalid in Return Number ['+@ReturnNumber+']' else '' end) I_PC,         
(Case when IUOM is null then 'UOMID is invalid in Return Number ['+@ReturnNumber+'] for the Item Code - [' + Isnull(PC, '')+']' else '' end) I_UOM  
from #TempValid        
Where IPC is null or IUOM is null or GroupID = 0        
Drop table #TempValid     
