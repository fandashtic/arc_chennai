
Create Procedure sp_CheckAdjustOnClose(@ParentTranID nvarchar(50), @CustID nvarchar(15), @netaddr nVarchar(100))
As
Begin
	Declare @Str as nVarchar(1000)
	
	Set @Str = 'Declare @Adj as Decimal(18,6)' + char(13)
	
	Set @Str = @Str + 'Select @Adj = IsNull(sum(Adjusted),0) from ##' + @netaddr + ' where ParentTranID = ''' + @ParentTranID + ''' And CustID = ''' + @CustID + ''''
	
	Set @Str = @Str + Char(13)
	
	Set @Str = @Str + 'If IsNull(@Adj,0)=0	Select 0 Else Select 1 '
	
	Exec sp_executesql @Str
End
