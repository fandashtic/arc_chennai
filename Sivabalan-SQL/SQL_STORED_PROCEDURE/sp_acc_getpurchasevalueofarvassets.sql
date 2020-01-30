CREATE Procedure sp_acc_getpurchasevalueofarvassets(@Text nText,@Value Decimal(18,6) Output)
As
Declare @ROWSEP nVarchar(15),@COLSEP nVarchar(15), @RowDetail nVarchar(250),@TempValue Decimal(18,6)
Set @ROWSEP=Char(2)
Set @COLSEP=Char(1)

Create Table #RowTemp(Row nVarchar(250))


Insert #RowTemp
Exec sp_acc_SqlSplit @Text,@ROWSEP
--Select * from #RowTemp
Declare scanrow Cursor Keyset For
Select Row from #RowTemp
Open scanrow
Fetch From scanrow Into @RowDetail
While @@FETCH_STATUS=0
Begin
	Create Table #ColTemp(Col nVarchar(250))
	Insert #ColTemp
	Exec sp_acc_SqlSplit @RowDetail,@COLSEP
	--Select * from #ColTemp
	--Select Top 1 Cast(Col as Int) from #ColTemp
	Select @TempValue=Sum(IsNull(OPWDV,0)) from Batch_Assets where BatchCode in (Select Top 1 Cast(Col as Int) from #ColTemp)
	--Select @TempValue
	Set @Value = IsNull(@Value,0) + IsNull(@TempValue,0)
	Drop Table #ColTemp
	Fetch Next From scanrow Into @RowDetail
End
Close scanrow
DeAllocate scanrow
Drop Table #RowTemp





