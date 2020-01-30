Create Function mERP_fn_Get_CGMappedForSalesMan(@SManID Int)
Returns @tblCG Table(CGID Int,CGName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
As
Begin
	
	Declare @DSTypeID as Int    
	Declare @DSTypeValue as nVarchar(50)

	Declare @OCGFlag as Int
	Select Top 1 @OCGFlag= Isnull(Flag,0) from tbl_merp_Configabstract where screenCode = 'OCGDS'

	If isnull(@OCGFlag ,0) = 0
	Begin
		/*To get the DSTypeID for the Salesman */
		Select
			@DSTypeID = isNull(DD.DSTypeId,0) ,@DSTypeValue = isNull(DM.DSTypeValue,'')
		From
			DSType_Master DM,DSType_Details DD
		Where
			DD.SalesmanID = @SManID And
			DD.DSTypeId = DM.DSTypeId And
			DM.DSTypeCtlPos = 1 And
			DM.Active = 1

		
		
		/* Insert GroupID And GroupName mapped for the DSType of the Salesamn */
		Insert Into @tblCG
		Select
			PCA.GroupID,PCA.GroupName   
		From
			ProductCategoryGroupAbstract PCA,tbl_mERP_DSTypeCGMapping DSCGMap
		Where
			DSCGMap.DSTypeID  = isNull(@DSTypeID,0) And 
			PCA.GroupID = DSCGMap.GroupID And 
			PCA.Active = 1 And 
			DSCGMap.Active = 1  
			And isnull(OCGType,0)=0
		Group By     
			PCA.GroupID,PCA.GroupName  
	End
	Else
	Begin
		/*To get the DSTypeID for the Salesman */
		Select
			@DSTypeID = isNull(DD.DSTypeId,0)
		From
			DSType_Master DM,DSType_Details DD
		Where
			DD.SalesmanID = @SManID And
			DD.DSTypeId = DM.DSTypeId And
			DM.DSTypeCtlPos = 1 And
			DM.Active = 1
			And isnull(OCGType,0)=1
		/* Insert GroupID And GroupName mapped for the DSType of the Salesamn */
		Insert Into @tblCG
		Select
			PCA.GroupID,PCA.GroupName   
		From
			ProductCategoryGroupAbstract PCA,tbl_mERP_DSTypeCGMapping DSCGMap
		Where
			DSCGMap.DSTypeID  = isNull(@DSTypeID,0) And 
			PCA.GroupID = DSCGMap.GroupID And 
			PCA.Active = 1 And 
			DSCGMap.Active = 1  
			And isnull(OCGType,0)=1
		Group By     
			PCA.GroupID,PCA.GroupName  
	End
	Return
End

