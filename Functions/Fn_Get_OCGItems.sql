--Select Distinct(Product_Code),ProductName From dbo.Fn_Get_Items_ITC('2,4,5,6,7')
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'Fn_Get_OCGItems')
BEGIN
    DROP FUNCTION [Fn_Get_OCGItems]
END
GO    
CREATE Function Fn_Get_OCGItems()
Returns @Items Table  
(  
GroupID Int, CategoryID Int,
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
As  
Begin
	If (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS') = 1
		Begin
			Insert Into @Items (GroupID, CategoryID, Product_Code, ProductName)
			select GroupID, CategoryID, Product_Code, ProductName from Fn_GetOCGSKU('%')
		End
	Else
		Begin
			Insert Into @Items (GroupID, CategoryID, Product_Code, ProductName)
			Select PCGA.GroupID, I.CategoryID, I.Product_Code, I.ProductName
			From ItemCategories IC1, ItemCategories IC2, ItemCategories IC3,ProductCategoryGroupAbstract PCGA, 
			Items I,tblCGDivMapping CGDIV
			Where CGDIV.Division = IC3.Category_Name
			  And IC3.CategoryID = IC2.ParentID 
			  And IC2.CategoryID = IC1.ParentID 
			  And IC1.CategoryID = I.CategoryID
			  And I.Active = 1 
			  And CGDIV.CategoryGroup = PCGA.GroupName
		End
	Return  
End
