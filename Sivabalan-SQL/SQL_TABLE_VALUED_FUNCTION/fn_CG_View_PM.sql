Create Function fn_CG_View_PM()    
Returns @ProdCatGrp Table (SalesmanID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, GroupName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)    
As    
Begin    
	Declare @cnt as int

	Declare @AllSM Table(SalesmanID int)
	Insert into @AllSM

	Select SalesmanID from Salesman Where SalesmanId in (Select S.salesmanID From DSType_Details dd, DSType_Master dm,Salesman S 
	Where dd.DSTypeID = dm.DSTypeID --And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'NO' 
	And DD.SalesmanID=S.SalesmanID
	And isnull(S.Active,0)=1
	And isnull(Dm.Active,0)=1 and isnull(dd.DSTypeCtlPos,0) = 1)

	Declare @SalesmanID AS nVarchar(50)
	/*Inserts All Category Group Mapped for the salesman */
	Declare AllSM cursor For select SalesmanID from @AllSM
	Open ALLSM
	Fetch from ALLSM into  @SalesmanID
	While @@fetch_status=0
	BEGIN
		Insert Into @ProdCatGrp
		Select @SalesmanID,CGName From mERP_fn_Get_CGMappedForSalesMan(@SalesmanID)
		Fetch next from ALLSM into  @SalesmanID
	END
	Close ALLSM
	Deallocate ALLSM

	Return   
End  

