Create Function mERP_FN_getDSDStype_GGRRReport(@OCGDS Int)
Returns @DSDSType Table (DSID int,DSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryGroup nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
BEGIN
Declare @SalesmanID int
Declare AllDS Cursor For 
Select SalesmanID from Salesman 
Open ALLDS
Fetch from ALLDs into @SalesmanID
While @@fetch_status=0
BEGIN
	insert into @DSDSType
	select Distinct @SalesmanID,DM.DSTypeValue,G.GroupName from tbl_mERP_DSTypeCGMapping DMS,DStype_master DM,ProductCategoryGroupAbstract G,DSType_Details Dt
	Where DMS.Active = 1
	And DM.Active = 1
	And G.Active = 1
	And Dm.DSTypeID = DMS.DStypeID
	And G.GroupID = DMS.GroupId
	And DM.OCGType = @OCGDS 
	And isnull(DM.DSTypeCtlPos,0) = 1 
	And Dt.SalesmanID = @SalesmanID
	And Dt.DSTypeID = DM.DSTypeID

	Fetch next from ALLDs into @SalesmanID
END
Close ALLDs
Deallocate ALLDS
Return
END
