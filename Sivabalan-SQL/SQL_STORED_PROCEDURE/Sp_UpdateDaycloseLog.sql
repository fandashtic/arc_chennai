Create Procedure Sp_UpdateDaycloseLog(@Log Nvarchar(4000),@Fromdate DateTime = Null,@Todate DateTime = Null)
As
Begin
	Insert Into tbl_DayCloseLog(Fromdate,Todate,LogDetail,CreationDate)
	Select @Fromdate,@Todate,@Log,Getdate()
End
