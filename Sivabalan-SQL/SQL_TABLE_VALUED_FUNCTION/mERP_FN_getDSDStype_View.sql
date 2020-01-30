Create Function mERP_FN_getDSDStype_View()
Returns @DSDSType Table (DSID int,DSType nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
BEGIN
Declare @SalesmanID int
Declare AllDS Cursor For 
Select SalesmanID from Salesman Where SalesmanId in (Select S.salesmanID From DSType_Details dd, DSType_Master dm,Salesman S 
Where dd.DSTypeID = dm.DSTypeID And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes' 
And DD.SalesmanID=S.SalesmanID
And isnull(S.Active,0)=1
And isnull(Dm.Active,0)=1)
Open ALLDS
Fetch from ALLDs into @SalesmanID
While @@fetch_status=0
BEGIN
	insert into @DSDSType
	Select @SalesmanID,DSTypeValue From DSType_Master Where DsTypeID   
	In ( Select DSTypeID From DSType_Details Where SalesmanID = @SalesmanID) and 
        ( Case when DSTypeName = 'DSType' then 
            (Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
          Else IsNull(OCGtype, 0) 
          End ) = IsNull(OCGtype, 0)
	and Active = 1 And DSTypeName='DSType' 
	Fetch next from ALLDs into @SalesmanID
END
Close ALLDs
Deallocate ALLDS
Return
END
