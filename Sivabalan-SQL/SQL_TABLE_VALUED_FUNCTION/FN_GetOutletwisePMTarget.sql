CREATE Function FN_GetOutletwisePMTarget (@PMID int,@DSTypeID int,@ParamID int)
Returns @Result Table(DSID int,Target decimal(18,6))
AS
BEGIN
	Declare @DSTYPE nvarchar(50)
	Select @DSTYPE=PMDS.DSType from tbl_mERP_PMDSType PMDS where DSTypeID=@DSTypeID and PMID=@PMID
	/* To store salesman of given DSTYPE*/
	Declare @salesman Table(salesmanId int)
	Insert into @salesman(salesmanId)
	Select salesmanId from dbo.mERP_fn_Get_DSTypeDS(@DSTYPE)

	/* To get Customer And Salesman Details*/
	Declare @OutletDetails Table(DSID int,OutletID Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Insert into @OutletDetails(DSID,OutletID)
	Select BS.SalesmanID,BS.CustomerID From Beat_salesman BS,Salesman S
	Where S.Salesmanid=BS.SalesmanID And
	isnull(S.Active,0)=1
	And S.salesmanID in (select salesmanid from @salesman)
	And BS.CustomerID in (select Distinct OutletID from PMOutlet where PMID=@PMID And DSTYPEID = @DSTypeID and ParamID = @ParamID)
	
	/* To get Outletwise Customer Details*/	
	Declare @PMDetails Table(OutletID Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Target decimal(18,6))
	Insert into @PMDetails(OutletID,Target)
	Select Distinct OutletID,Target From PMOutlet where PMID=@PMID And DSTYPEID = @DSTypeID and ParamID = @ParamID

	/* To get the final result*/
	Insert into @Result
	Select O.DSID,sum(P.Target) as Target From @OutletDetails O,@PMDetails P
	Where O.OutletID=P.OutletID
	Group by O.DSID
	Delete from @salesman
	Delete from @PMDetails	
	Delete from @OutletDetails
	Return
END
