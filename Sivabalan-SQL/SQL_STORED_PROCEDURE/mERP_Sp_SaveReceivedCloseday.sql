Create Procedure mERP_Sp_SaveReceivedCloseday(@ScreenName nvarchar(100),@ClosedayEnabled int,@GracePeriod int,@InventoryLock int,@FinanceLock int,
@ResetClosedDatevalue int)  
As  
Begin  
Declare @nidentity int   
Insert into tbl_mERP_RecConfigAbstract(Menuname,flag, Status,ResetOption) values(@ScreenName,@ClosedayEnabled,0,@ResetClosedDatevalue)               
Select @nidentity= @@IDENTITY   


Insert into tbl_mERP_RecConfigDetail(ID,FieldName,Flag,Status,Value) Values(@nidentity,'GracePeriod',1,0,@GracePeriod)
Insert into tbl_mERP_RecConfigDetail(ID,FieldName,Flag,Status) Values(@nidentity,'InventoryLock',@InventoryLock,0)
Insert into tbl_mERP_RecConfigDetail(ID,FieldName,Flag,Status) Values(@nidentity,'FinancialLock',@FinanceLock,0)
End
