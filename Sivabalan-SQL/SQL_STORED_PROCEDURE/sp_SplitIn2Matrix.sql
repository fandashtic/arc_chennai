Create Procedure sp_SplitIn2Matrix(@StrSource nvarchar(max) = NULL, @RowSeparator char(1) = '|', @ColSeparator char(1) = ';')  
As
Begin
--Declare @StrSource nvarchar(max)
--Set @StrSource = '4;12;1;1;0;1;0;100;507.144;0;0;0;507.144|5;12;2;1;0;1;0;100;507.144;0;0;0;507.144|8;5;6;1;1;1;0;100;25.3572;0;0;0;25.3572|9;5;7;1;2;1;0;100;25.3572;0;0;0;25.3572|10;0.5;9;1;6;1;0;100;0.126786;0;0;0;0.126786|11;0.5;10;1;7;1;0;100;0.126786;0;0;0;0.126786'
--Declare @RowSeparator char(1) 
--Set @RowSeparator= '|'
--Declare @ColSeparator char(1) 
--Set @ColSeparator= ';'

If(IsNull(@StrSource,'') = '' ) GoTo NoData

Declare @CrSQLQry nVarChar(Max)
Declare @StrCols nVarChar(Max)

Create Table #tmpRows ([ID] Int Identity(1,1), ItemInfo nVarchar(Max))
Create Table #tmpCols ([ID] Int Identity(1,1), ItemInfo nVarchar(Max)) 

Insert Into #tmpRows
Select * from dbo.sp_splitin2Rows(@StrSource,@RowSeparator)

IF Not Exists(Select 'x' From #tmpRows) GoTo NoData1

Select Top 1 @StrCols=ItemInfo From #tmpRows

If(IsNull(@StrCols,'') = '' ) GoTo NoData1

Insert Into #tmpCols
Select * from dbo.sp_splitin2Rows(@StrCols,@ColSeparator)

IF Not Exists(Select 'x' From #tmpCols) GoTo NoData1

Set @CrSQLQry = 'Create Table #tmpMatrix(RowID Int Identity(1,1)'
Declare @ID Int
Declare nCols Cursor For Select ID from #tmpCols
Open nCols
Fetch From nCols Into @ID
While @@Fetch_status = 0
Begin
	Set @CrSQLQry = @CrSQLQry + ','  + 'Column' + Cast(@ID As nVarChar) + ' Decimal(18,6)' 
	Fetch Next From nCols Into @ID
End
Close nCols
DeAllocate nCols

Set @CrSQLQry = @CrSQLQry + ')' + Char(10)

Declare nRows Cursor For Select ItemInfo from #tmpRows
Open nRows
Fetch From nRows Into @StrCols
While @@Fetch_status = 0
Begin
	Set @CrSQLQry = @CrSQLQry+  'Insert Into #tmpMatrix Select ' + Replace(@StrCols,@ColSeparator,',')  + Char(10)
	Fetch Next From nRows Into @StrCols
End
Close nRows
DeAllocate nRows

Set @CrSQLQry = @CrSQLQry+  'Select * from #tmpMatrix' + Char(10)
Set @CrSQLQry = @CrSQLQry+  'Drop Table #tmpMatrix' + Char(10)

--Print @CrSQLQry
Exec sp_ExecuteSQL @CrSQLQry 

NoData1:

Drop Table #tmpRows
Drop Table #tmpCols

NoData:

End
