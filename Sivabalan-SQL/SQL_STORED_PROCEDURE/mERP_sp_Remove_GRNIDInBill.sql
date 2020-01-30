CREATE PROCEDURE mERP_sp_Remove_GRNIDInBill(@BillID INT,@GRNID INT)
AS
Declare @GRNIDLIst nVarChar(255)
Declare @NewGRNIDLIst nVarChar(255)
Declare @GID Int
Create Table #TempGRNIDs (IDs Int)

Select @GRNIDLIst = GRNID from BillAbstract where BillID = @BillID

Insert Into #TempGRNIDs Select * from dbo.sp_SplitIn2Rows(@GRNIDLIst,',')

Declare IDList cursor for Select IDs From #TempGRNIDs
Open IDList
Fetch From  IDList Into @GID
Set @NewGRNIDLIst = ''
While @@Fetch_Status = 0
Begin
if IsNull(@GID,0) > 0
begin
	if IsNull(@GID,0) <> IsNull(@GRNID,0)
	begin
		If @NewGRNIDLIst = ''
			Set @NewGRNIDLIst = Cast(@GID As nVarChar)
		Else
			Set @NewGRNIDLIst = @NewGRNIDLIst + ',' + Cast(@GID As nVarChar)
	End
End
	Fetch Next From  IDList Into @GID
End	
Update BillAbstract Set GRNID = @NewGRNIDLIst where BillID = @BillID

Select @NewGRNIDLIst

Drop Table #TempGRNIDs

