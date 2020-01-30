Create Procedure mERP_SP_GetExistingCustomerQuo(@CustomerID nvarchar(100))
As
Declare @Quoname as nvarchar(100)
Declare @QuotationName as nvarchar(1000)
Begin
    declare Cur_Quo Cursor for select QuotationAbstract.QuotationName from QuotationCustomers,QuotationAbstract 
	where CustomerID=@CustomerID and QuotationAbstract.Active=1
    and  QuotationAbstract.QuotationID=QuotationCustomers.QuotationID
    Set @QuotationName=N' '
    Open Cur_Quo              
	Fetch From Cur_Quo into @Quoname           
	While @@fetch_status = 0
    Begin
        if @QuotationName=N' '
          set @QuotationName=@Quoname
        Else
          Set @QuotationName=@QuotationName+'/'+@Quoname  
		Fetch From Cur_Quo into @Quoname
    End 
    CLose Cur_Quo
    Deallocate Cur_Quo
    Select @QuotationName
End
