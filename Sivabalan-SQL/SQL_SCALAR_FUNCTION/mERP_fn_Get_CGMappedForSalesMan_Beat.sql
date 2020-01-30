Create Function mERP_fn_Get_CGMappedForSalesMan_Beat (@BeatID nvarchar(4000))  
Returns nvarchar(400)
As  
Begin  
	Declare @DSTypeID as Int      
	Declare @DSTypeValue as nVarchar(50)  
	Declare @CGID nvarchar(200)
	Declare @CG int
	Set @CGID=''
	Declare @BeatIDs Table (ItemValue int)
	Declare @SalesmanIDs Table (SalesmanID int)
	Declare @TmpGroup Table(GroupID int)

	Insert InTo @BeatIDs
	Select ItemValue From fn_SplitIn2Rows_Int(@BeatID, ',')

	Insert InTo @SalesmanIDs
	Select isnull(SalesmanID,0) from Beat_salesman where beatId in (Select isnull(Itemvalue,0) from @BeatIDs) 

	/*To get the DSTypeID for the Salesman */  
	Select  
	@DSTypeID = isNull(DD.DSTypeId,0) ,@DSTypeValue = isNull(DM.DSTypeValue,'')  
	From  
	DSType_Master DM,DSType_Details DD  
	Where  
	DD.SalesmanID in(Select SalesmanID from @SalesmanIDS) And  
	DD.DSTypeId = DM.DSTypeId And  
	DM.DSTypeCtlPos = 1 And  
	DM.Active = 1  
	If (Select isnull(OCGType,0) from DStype_Master where DStypeID=@DSTypeID)=0
	Begin
		insert into @TmpGroup (GroupID)
		Select  PCA.GroupID 
		From ProductCategoryGroupAbstract PCA,tbl_mERP_DSTypeCGMapping DSCGMap  
		Where  
		DSCGMap.DSTypeID  = isNull(@DSTypeID,0) And   
		PCA.GroupID = DSCGMap.GroupID And   
		PCA.Active = 1 And   
		DSCGMap.Active = 1 And 
		isnull(PCA.OCGType,0)=0
	End
	ELSE
	BEGIN
		insert into @TmpGroup (GroupID)
		Select  PCA.GroupID
		From  ProductCategoryGroupAbstract PCA,tbl_mERP_DSTypeCGMapping DSCGMap  
		Where  
		DSCGMap.DSTypeID  = isNull(@DSTypeID,0) And   
		PCA.GroupID = DSCGMap.GroupID And   
		PCA.Active = 1 And   
		DSCGMap.Active = 1 And
		isnull(PCA.OCGType,0)=1
	END
	/* Insert GroupID And GroupName mapped for the DSType of the Salesamn */  
	Declare allCG cursor For
	Select GroupID from @TmpGroup
	open  allCG
	fetch from allCG into @CG
	While @@fetch_status =0
	BEGIN
		set @CGID=cast(@CGID as varchar)+ cast(@CG as varchar) +','
	fetch next from allCG into @CG	
	END 
	close allCG
	Deallocate allCG
	
	if len(@CGID) > 0
	Set @CGID=left(@CGID,len(@CGID)-1)
	Return  @CGID
End  
