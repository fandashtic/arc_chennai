Create Function  [dbo].[Fn_UpdateLevelWiseCount](@CategoryName Nvarchar(1000),@Level Int)
Returns Int
As
Begin
	Declare @Count as Int

	Declare @Customer as Table (Customerid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Salesmanid int,
	categoryid [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	Category_Name [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	GroupName [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ParentID Int,
	ParentName [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)

	IF @level = 2
	Begin
		Delete from @Customer
		Insert Into @Customer(Customerid,Salesmanid,categoryid,category_name,GroupName)
		select BS.Customerid,BS.salesmanid,CPC.categoryid,IC.category_name ,T2.CategoryGroup
		from CustomerProductCategory CPC ,ItemCategories IC,beat_salesman BS,Customer C,
		(select Distinct IC3.Category_Name Sub_Category,IC2.Category_Name Division,G.GroupName CategoryGroup
		from Fn_GetOCGSKU('%')F, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract G
		where IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
		And G.GroupID = F.GroupID) T2
		where BS.Customerid = CPC.Customerid
		And C.Active = 1 and C.CustomerCategory <> 5 
		and IC.categoryid = CPC.categoryid
		And CPC.Customerid= C.Customerid
		And IC.Category_Name = T2.Sub_Category

		Insert Into @Customer(Customerid,Salesmanid,categoryid,category_name,GroupName)
		select BS.Customerid,BS.salesmanid,CPC.categoryid,IC.category_name ,T2.CategoryGroup
		from CustomerProductCategory CPC ,ItemCategories IC,beat_salesman BS,Customer C,
		(select Distinct IC3.Category_Name Sub_Category,IC2.Category_Name Division,G.GroupName CategoryGroup
		from Fn_GetOCGSKU('%')F, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract G
		where IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
		And G.GroupID = F.GroupID)  T2
		where BS.Customerid = CPC.Customerid
		And C.Active = 1 and C.CustomerCategory <> 5 
		and IC.categoryid = CPC.categoryid
		And CPC.Customerid= C.Customerid
		And IC.Category_Name = T2.Division
	End
	Else IF @level = 3
	Begin
		Delete from @Customer
		Insert Into @Customer(Customerid,Salesmanid,categoryid,category_name,GroupName)
		select BS.Customerid,BS.salesmanid,CPC.categoryid,IC.category_name ,T2.CategoryGroup
		from CustomerProductCategory CPC ,ItemCategories IC,beat_salesman BS,Customer C,
		(select Distinct IC3.Category_Name Sub_Category,IC2.Category_Name Division,G.GroupName CategoryGroup
		from Fn_GetOCGSKU('%')F, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2, ProductCategoryGroupAbstract G
		where IC4.categoryid = F.Categoryid and IC4.ParentId = IC3.categoryid and IC3.ParentId = IC2.categoryid 
		And G.GroupID = F.GroupID) T2
		where BS.Customerid = CPC.Customerid
		And C.Active = 1 and C.CustomerCategory <> 5 
		and IC.categoryid = CPC.categoryid
		And CPC.Customerid= C.Customerid
		And IC.Category_Name = T2.Sub_Category
	End

	Update T  Set T.Parentid = IC.Parentid from ItemCategories IC, @Customer T Where IC.CateGoryid = T.CateGoryid
	Update T  Set T.ParentName = IC.category_name from ItemCategories IC, @Customer T Where IC.CateGoryid = T.Parentid
	Update @Customer set ParentName = category_name Where ParentName = 'ITD'
	Delete from @Customer where GroupName is null 

	IF @level = 2
	Begin
		Set @Count = (select Count(Distinct Customerid) from @Customer Where ParentName = @CategoryName)
	End
	Else IF @level = 3
	Begin
		Set @Count = (select Count(Distinct Customerid) from @Customer Where Category_Name = @CategoryName)
	End

	Return @Count
End
