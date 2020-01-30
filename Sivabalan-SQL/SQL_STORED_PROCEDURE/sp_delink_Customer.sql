
CREATE procedure sp_delink_Customer (@CUSTOMERID NVARCHAR(25))
as
Declare @RowCount int
Declare @BeatID int

Select @BeatID = BeatID From Beat_Salesman Where CustomerID = @CUSTOMERID
Select @RowCount = Count(*) From Beat_Salesman Where BeatID = @BeatID
If @RowCount = 1 
Begin
	Update Beat_Salesman Set CustomerID = N'' Where CustomerID = @CUSTOMERID And
	BeatID = @BeatID
End
Else
	Delete From Beat_Salesman Where CustomerID = @CUSTOMERID And BeatID = @BeatID

