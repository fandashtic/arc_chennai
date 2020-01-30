CREATE Procedure mERP_sp_getItemList_ITC(@InvID Integer, @Serials nVarChar(255), @ItemCodes nVarChar(1500) OUTPUT)
As
Declare @SNo Integer
Declare @ICode nVarChar(30)
Create Table #SerialList (Sno nVarChar(10))
Insert InTo #SerialList Select * From dbo.sp_SplitIn2Rows(@Serials, ',')

Set @ItemCodes = ''

Declare SList cursor For Select Sno from #SerialList
Open SList
Fetch from SList into @Sno
	While @@Fetch_status = 0 
	Begin
	Select @ICode = IsNull(Product_Code,'') from InvoiceDetail 
		where InvoiceID = @InvID and Serial = Cast(@Sno as Integer)
	if @ICode <> ''
	Set @ItemCodes = @ItemCodes + @ICode + ','
	Fetch Next from SList into @Sno
	End
Close SList
DeAllocate SList

If Len(@ItemCodes) > 0
Set @ItemCodes = Left(@ItemCodes,Len(@ItemCodes)-1)

