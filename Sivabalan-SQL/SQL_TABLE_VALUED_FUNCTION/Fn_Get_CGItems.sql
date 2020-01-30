  
CREATE Function Fn_Get_CGItems( @GroupId int,@CGType nvarchar(20) )
Returns @Items Table  
(  
GroupID Int, CategoryID Int,
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
As  
Begin
	If @CGType ='Operational' --(select Top 1 OCGtype from ProductCategoryGroupAbstract where GroupId = @GroupId ) = 1
		Begin
			Insert Into @Items (GroupID, CategoryID, Product_Code, ProductName)
			select GroupID, CategoryID, Product_Code, ProductName from dbo.Fn_GetOCGSKU(@GroupId)
		End
	Else
		Begin
			Insert Into @Items (GroupID, CategoryID, Product_Code, ProductName)
			Select PCGA.GroupID, I.CategoryID, I.Product_Code, I.ProductName
			From ItemCategories IC1, ItemCategories IC2, ItemCategories IC3,ProductCategoryGroupAbstract PCGA, 
			Items I,tblCGDivMapping CGDIV
			Where pcga.GroupId = @groupid and CGDIV.Division = IC3.Category_Name
			  And IC3.CategoryID = IC2.ParentID 
			  And IC2.CategoryID = IC1.ParentID 
			  And IC1.CategoryID = I.CategoryID
			  And CGDIV.CategoryGroup = PCGA.GroupName
		End
	Return  
End
