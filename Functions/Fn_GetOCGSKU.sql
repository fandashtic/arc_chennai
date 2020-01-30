--Select Distinct(Product_Code),ProductName From dbo.Fn_Get_Items_ITC('2,4,5,6,7')
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'Fn_GetOCGSKU')
BEGIN
    DROP FUNCTION [Fn_GetOCGSKU]
END
GO
Create Function Fn_GetOCGSKU(@RecdGroupID Nvarchar(1000))  
Returns  
@tmpOUT table (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID Int,GroupID Int)  
AS  
BEGIN  
 Declare @Group as table (GroupID Int  
  ,GroupName Nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS  
  ,GroupCode Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)  

   Declare @ItemsNew as table (Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS ,ProductName Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
   INSERT INTO @ItemsNew(Product_Code, ProductName)
   --SELECT DISTINCT Product_Code, ProductName FROM Product_Mappings WITH (NOLOCK)
   SELECT DISTINCT Product_Code, ProductName FROM Items WITH (NOLOCK)
  
 If Isnull(@RecdGroupID,'') = '%'  
  Begin  
   Insert Into @Group (GroupID,GroupName,GroupCode)  
   Select Distinct GroupID,GroupName,GroupCode from ProductCategoryGroupAbstract   
   Where Isnull(OCGType,0) = 1  
   And Active = 1     
  End  
 Else  
  Begin  
   Insert Into @Group (GroupID,GroupName,GroupCode)  
   Select Distinct GroupID,GroupName,GroupCode from ProductCategoryGroupAbstract Where GroupID In  
   (Select * From dbo.sp_splitIn2Rows(@RecdGroupID,','))  
   And Isnull(OCGType,0) = 1  
   And Active = 1  
  End  
   
  
 Insert Into @TmpOUT   
 select O.SystemSKU,
 (SELECT TOP 1 ProductName FROM @ItemsNew WHERE Product_Code = O.SystemSKU) ProductName,
 I.CategoryID,G.GroupID 
 from (Select Distinct SystemSKU, Exclusion, GroupName From OCGItemMaster WITH (NOLOCK)) O, Items I  WITH (NOLOCK), @Group G  
 Where O.GroupName = G.GroupName  
 And I.Product_Code = O.SystemSKU  
 And O.Exclusion = 0  
 Order By O.SystemSKU  
  
 Delete From @Group  
 Return   
End  
GO
