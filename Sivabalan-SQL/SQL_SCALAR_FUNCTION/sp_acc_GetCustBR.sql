CREATE function sp_acc_GetCustBR(@DocumentID int)
Returns nVarchar(4000)
As
Begin
	Declare @Cust_BR nvarchar(4000)
	Declare @Return_Cust_BR nvarchar(4000)
	set @Return_Cust_BR = N''

	if (Select PriceListFor from SENDPRICELIST Where DocumentID = @DocumentID) = 0
	Begin
		Declare Concatenate Cursor for
		Select C.Company_Name from 
		SendPriceListBranch SPLB,Customer C
		Where SPLB.BranchID = C.CustomerID
		and SPLB.DocumentID = @DocumentID
	End
	Else
	Begin
		Declare Concatenate Cursor for
		Select W.Warehouse_Name as Branch_Name from 
		SendPriceListBranch SPLB,Warehouse W
		Where SPLB.BranchID = W.WarehouseID
		and SPLB.DocumentID = @DocumentID
	End


	Open Concatenate
	Fetch from Concatenate into @Cust_BR
	While @@Fetch_status = 0
	Begin
		Set @Return_Cust_BR =@Return_Cust_BR + ',' + Ltrim(rtrim(@Cust_BR))
		Fetch Next from Concatenate into @Cust_BR
	End
	Close Concatenate
	Deallocate Concatenate
	Return Substring(@Return_Cust_BR,2,Len(@Return_Cust_BR))
End




