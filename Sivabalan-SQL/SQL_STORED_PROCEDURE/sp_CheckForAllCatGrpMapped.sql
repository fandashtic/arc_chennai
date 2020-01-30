Create Procedure sp_CheckForAllCatGrpMapped(@SalesmanId Integer)  
As  
Begin  
	Declare @cnt as integer  
	Declare @AllCatMapped as integer  
	Set @cnt = 0  
	if @SalesmanID = 0 
		Set @AllCatMapped = 0  
	Else
	Begin
		Declare @tmpGGID Table(GroupID Int,GroupName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
		
		
		/*Inserts All Category Group Mapped for the salesman */
		Insert Into @tmpGGID
		Select * From mERP_fn_Get_CGMappedForSalesMan(@SalesmanID)

		Select @cnt = Count(*) From @tmpGGID

		Set @cnt = isNull(@cnt,0)

		

		If @cnt  = 0   
			--All categorygroup mapped   
			Set @AllCatMapped =  1  
		Else if  @cnt =1   
			--only one group mapped  
			Set @AllCatMapped =  2  
		Else  
			Set @AllCatMapped = 0
	End
	Select @AllCatMapped    
End
