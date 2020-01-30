Create Procedure mERP_SP_getSubcategory_OCG (@Division nvarchar(300),@DSTypeID int)
AS
BEGIN
	If (select isnull(OCGType,0) from dstype_master where DSTypeID=@DSTypeID)=0
	BEGIN
		SELECT CategoryID,Category_Name FROM ItemCategories WHERE 1 = 1  AND ACTIVE = 1 And Level = 3 And 
		ParentID In (Select * from dbo.sp_SplitIn2Rows(@Division, ',')) Order By Category_Name
	END
	ELSE
	BEGIN
		Declare @GID int
		Declare @CategoryLevel int
		Set @CategoryLevel=3
		create Table #result(CategoryID int,Category_Name nvarchar(255))
		Declare AllDS Cursor For select Distinct GroupID from tbl_mERP_DSTypeCGMapping Where DstypeID in (@DSTypeID)
		Open AllDS
		Fetch from AllDS into @GID
		While @@Fetch_status =0
		Begin
			insert into #result(CategoryID,Category_Name)
			select Distinct 
			Case @CategoryLevel 
			When 2 then IC2.CategoryID
			When 3 Then IC3.CategoryID
			When 4 Then IC4.CategoryID
			End,
			Case @CategoryLevel 
			When 2 then IC2.Category_Name
			When 3 Then IC3.Category_Name
			When 4 Then IC4.Category_Name
			End
			from items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2,dbo.Fn_GetOCGSKU(@GId) FN where
			IC4.categoryid = i.categoryid 
			And IC4.Parentid = IC3.categoryid 
			And IC3.Parentid = IC2.categoryid 
			And FN.Product_code=I.Product_code
			And FN.CategoryID=IC4.CategoryID	
			And IC2.categoryid in (Select * from dbo.sp_SplitIn2Rows(@Division, ','))
			Fetch Next from AllDS into @GID
		End
		Close AllDS
		Deallocate AllDS
		Select Distinct * from #result order by Category_Name
		Drop Table #result
	END
END
