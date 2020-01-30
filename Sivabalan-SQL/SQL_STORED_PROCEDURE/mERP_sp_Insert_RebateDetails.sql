Create Procedure mERP_sp_Insert_RebateDetails(@InvoiceID Int,@RowNo as Int)
As
Begin
	
	Declare @ProductCode as nVarchar(255)
	Declare @MultiRebateDet as nVarchar(2000)
	Declare @RebateDet as nVarchar(2000)
	Declare @Delimeter as  Char(1)
	Declare @RebateID as Int
	Declare @RebatePerc as Decimal(18,6)

	Select  @ProductCode = Product_Code ,
			@MultiRebateDet  = isNull(MultipleRebateDet,'')
	From 
		InvoiceDetail ID 
	Where 
		ID.InvoiceID = @InvoiceID And
		ID.Serial = @RowNo 


	
	Set @Delimeter = char(15)	

	Create Table #tmpRebate(RebateDetail nVarchar(250)) 
	Insert Into #tmpRebate
	Select * from dbo.sp_SplitIn2Rows(@MultiRebateDet,@Delimeter)

	
	Declare CurRebate Cursor For 
	Select RebateDetail From #tmpRebate
	Open CurRebate
	Fetch Next From CurRebate Into @RebateDet
	While @@Fetch_Status = 0 
	Begin
		Set @RebateID = 0
		Set @RebatePerc = 0
		Set @RebateID = Substring(@RebateDet,1,Charindex('|',@RebateDet) - 1)
		Set @RebatePerc = Substring(@RebateDet,Charindex('|',@RebateDet)+1,len(@RebateDet))

		Insert Into tbl_mERP_RebateRate
		Select @InvoiceID,@RowNo,@ProductCode,@RebateID , @RebatePerc
	
		Fetch Next From CurRebate Into @RebateDet
	End
	Close CurRebate
	Deallocate CurRebate
End
