Create Procedure mERP_sp_Get_IsOLClassMapped(@CUSTID nVarchar(255), @CHANNEL nVarchar(255),@OUTLET nVarchar(255))  
As  
Begin  
  
	Declare @MapChannel nVarchar(255)
	Declare @MapOutlet nVarchar(255)
	Declare @MapLoyalty nVarchar (255)
	Declare @IsMapped int

	Select distinct @MapChannel=OCMas.Channel_Type_Desc,@MapOutlet=OCMas.Outlet_Type_Desc ,@MapLoyalty=OCMas.SubOutlet_Type_Desc
	From tbl_mERP_OLClassMapping OCMap, tbl_mERP_OLClass OCMas, Beat
	Where OCMap.Active = 1 And
	OCMas.ID = OCMap.OLClassID  And
--	OCMas.Channel_Type_Desc Not in(select Distinct [Value] From tbl_mERP_RestrictedOLClass Where TypeName = 'Channel_Type' and Status = 1) And
	OCMap.CustomerID=@CustId
	--If it is already mapped earlier then it returns 1 else 0
	if @MapChannel = '' or @MapOutlet=''
		set @IsMapped = 0
	else if  (@MapChannel<>@CHANNEL) or (@MapOutlet<>@OUTLET ) 
		set @IsMapped = 1
	else if (@MapChannel=@CHANNEL AND @MapOutlet=@OUTLET ) 
		set @IsMapped = 2	
	Select @IsMapped 	
End  
