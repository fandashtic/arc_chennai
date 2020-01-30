Create Procedure sp_GetQPSValidation(@SchemeId Int, @PayoutID Int,@CustomerId Nvarchar(255))  
As    
Begin
	Declare @TmpInvoiceItems as Table (
		Product_Code Nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,
		Quantity Decimal(18,6),
		Salesvalue Decimal(18,6))

	Insert Into @TmpInvoiceItems
	Select Product_Code,Quantity,Salesvalue from tbl_mERP_QPSDtlData Where SchemeID = @SchemeId And PayoutID = @PayoutID And CustomerId = @CustomerId

	Declare @Product_Code as Nvarchar(255)
	Declare @Quantity as Nvarchar(255)
	Declare @Amount as Nvarchar(255)
	Declare @tmpStr as Nvarchar(Max)

	Set @tmpStr = ''
	Declare Cur_Merge Cursor for 
	Select Product_Code,Isnull(Quantity,0),Isnull(Salesvalue,0)	from @TmpInvoiceItems
	Open Cur_Merge
	Fetch from Cur_Merge into @Product_Code,@Quantity,@Amount
	While @@fetch_status =0
		Begin				
			If Isnull(@tmpStr ,'') <> ''
			Begin
				Set @tmpStr = @tmpStr + '|' + Cast(@Product_Code as Nvarchar) + ',' + Cast(@Quantity as Nvarchar) + ',' + Cast(@Amount as Nvarchar) 
			End
			Else
			Begin
				Set @tmpStr = Cast(@Product_Code as Nvarchar) + ',' + Cast(@Quantity as Nvarchar) + ',' + Cast(@Amount as Nvarchar) 
			End		
			Fetch Next from Cur_Merge into @Product_Code,@Quantity,@Amount
		End
	Close Cur_Merge
	Deallocate Cur_Merge
	Exec mERP_SP_isAllItemsexistsMinQty @SchemeId,@tmpStr
End  
