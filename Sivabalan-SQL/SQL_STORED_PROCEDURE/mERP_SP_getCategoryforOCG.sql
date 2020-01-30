Create Procedure mERP_SP_getCategoryforOCG @GroupId nvarchar(3500)='',@DSTypeID nvarchar(3500)='',@CategoryLevel int
AS
BEGIN
	If @CategoryLevel between 2 and 4
	Begin
		Declare @GID int
		Create Table #TempGIDs(GroupID int)
		Insert into #TempGIDs(GroupID)
		Select * from dbo.sp_SplitIn2Rows(@GroupId, ',')
		Create Table #TempDSTIDs(DStypeID int)
		Insert into #TempDSTIDs(DStypeID)
		Select * from dbo.sp_SplitIn2Rows(@DSTypeID, ',')
		create Table #result(CategoryID int,Category_Name nvarchar(255))
		/* If GroupID is passed */
		If isnull(@GroupID,'') <> ''
		Begin
			Declare AllGroup Cursor For select Distinct GroupID from #TempGIDs
			Open AllGroup
			Fetch from AllGroup into @GID
			While @@fetch_status=0
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
				from items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2,dbo.Fn_GetOCGSKU(@GID) FN where
				IC4.categoryid = i.categoryid 
				And IC4.Parentid = IC3.categoryid 
				And IC3.Parentid = IC2.categoryid 
				And FN.Product_code=I.Product_code
				And FN.CategoryID=IC4.CategoryID
				Fetch Next from AllGroup into @GID
			End
			Close AllGroup
			Deallocate AllGroup
		END
		/* If DSTypeID is passed */
		Else IF isnull(@DSTypeID,'') <> ''
		BEGIN
			Declare AllDS Cursor For select Distinct GroupID from tbl_mERP_DSTypeCGMapping Where DstypeID in (Select Distinct DSTypeID from #TempDSTIDs)
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
				Fetch Next from AllDS into @GID
			End
			Close AllDS
			Deallocate AllDS
		END
		Select Distinct * from #result order by Category_Name
		Drop Table #TempGIDs
		Drop Table #TempDSTIDs
		Drop Table #result
	End
END
