Create procedure MERP_sp_get_ItemAccList (@MasterType Int,@IsCount Int = 0)
As
Declare @ProdCnt Int
Declare @AccCnt Int

If @IsCount = 0 --Return Recordset
Begin
	If @MasterType = 1 --Items non FMCG
		Select Distinct Product_Code from Batch_Products_Copy
	Else If @MasterType = 3 --Accounts
	Begin
		If exists(Select * From SysObjects Where xType = 'U' And Name = 'AccountsMaster')  
			Select distinct AccountID,AccountName from AccountsMaster where AccountID <> 500  -- AccountName - User Account Start
	End
End
Else If @IsCount = 1 --Return Count
Begin
	Set @ProdCnt = 0
	Set @AccCnt = 0
	Select @ProdCnt = count(Distinct Product_Code) from Batch_Products_Copy     
	If exists(Select * From SysObjects Where xtype = 'U' And Name = 'AccountsMaster')
		Select @AccCnt = count(distinct AccountID) from AccountsMaster where AccountID <> 500  -- AccountName - User Account Start
	Select @ProdCnt , @AccCnt
    End
