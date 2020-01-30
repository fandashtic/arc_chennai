Create procedure Sp_Save_ITCBeatCustomer_HH (
@BeatID  INT,
@CUSTOMERID  NVARCHAR (30),
@DefaulBeat NVARCHAR(10)=null,
@vald [int] = 0,
@SalesManName nvarchar(50) )
AS
DECLARE @OLD_SALESMANID INT
DECLARE @OLDBEATID INT
DECLARE @ModifyDate as Int
DECLARE @RecCnt as Int
Declare @SalesManID Int


Set	@ModifyDate = 0

if Not Exists(Select * From Beat_Salesman Where  BeatID = @BeatID AND CustomerID = @CustomerID)
set	@ModifyDate =1

If @vald = 2
Begin
Update Beat_Salesman Set CustomerID = N'' Where  CustomerID = @CUSTOMERID
End

Select @SalesManID = SalesmanID from Salesman where Salesman_Name = @SalesManName
SET @OLD_SALESMANID = ISNULL(@SalesManID, 0)

IF EXISTS (Select BeatID From Beat_Salesman WHERE BeatID = @BeatID AND CustomerID = @CustomerID)
Begin
Update Beat_Salesman SET Salesmanid = @OLD_SALESMANID WHERE BeatID = @BeatID AND CustomerID = @CustomerID
IF EXISTS (Select BeatID From Beat_Salesman WHERE BeatID = @BeatID AND CustomerID = N'')
Begin
Update Beat_Salesman SET CustomerID = @CustomerID,salesmanid = @OLD_SALESMANID  WHERE BeatID = @BeatID AND CustomerID = N''
end
GOTO Done
end
IF EXISTS (Select BeatID From Beat_Salesman WHERE BeatID = @BeatID AND CustomerID = N'')
begin
Update Beat_Salesman SET CustomerID = @CustomerID,salesmanid = @OLD_SALESMANID  WHERE BeatID = @BeatID AND CustomerID = N''
end
ELSE
Begin
Insert Into Beat_Salesman (BeatID, SalesmanID, CustomerID) Values(@BeatID, @OLD_SALESMANID, @CustomerID)
End

Done:
--To Remove DupliCate Records in Beat_Salesman Table
Select @RecCnt = Count(*) From Beat_Salesman WHERE BeatID = @BeatID AND CustomerID = @CustomerID AND SalesmanID = @OLD_SALESMANID
If @RecCnt > 1
Begin
Delete From Beat_Salesman  WHERE BeatID = @BeatID AND CustomerID = @CustomerID AND SalesmanID = @OLD_SALESMANID
Insert Into Beat_Salesman (BeatID, SalesmanID, CustomerID) Values(@BeatID, @OLD_SALESMANID, @CustomerID)
End

If @DefaulBeat = 'YES'
Update Customer Set DefaultBeatID = @BeatID Where CustomerID = @CUSTOMERID

