Create Function mERP_fn_Get_GroupNames(@CGID nVarchar(500))
Returns nVarchar(1000)
As
Begin
	
	Declare @CGName as nVarchar(255)
	Declare @CatGrpName as nVarchar(4000)
	
	Declare @tmpCGID as Table(CGID Int)
	Insert Into @tmpCGID
	Select * from dbo.sp_SplitIn2Rows(@CGID,',')

	Declare  Cur_CGName Cursor For
	Select 
		PCGA.GroupName 
	From 
		ProductCategoryGroupAbstract PCGA
	Where 
		PCGA.GroupID In(Select CGID From @tmpCGID)


	Set @CatGrpName =''
	Set @CGName = ''
	Open Cur_CGName
	Fetch From Cur_CGName Into @CGName
	While @@Fetch_Status = 0
	Begin
		If @CatGrpName = '' 
			Set @CatGrpName = @CGName
		Else
			Set @CatGrpName = Cast(@CatGrpName as nVarchar(4000)) + ',' + Cast(@CGName as nVarchar(255))

		Fetch Next From Cur_CGName Into @CGName
	End
	Close Cur_CGName
	Deallocate  Cur_CGName

	Return  @CatGrpName
	


End

