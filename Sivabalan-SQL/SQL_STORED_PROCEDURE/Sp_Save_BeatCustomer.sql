
CREATE proc Sp_Save_BeatCustomer
        (@BeatID 	INT,
	 @CUSTOMERID 	NVARCHAR (30))
AS
DECLARE @OLD_SALESMANID INT
DECLARE @OLDBEATID INT

IF EXISTS (Select BeatID From Beat_Salesman WHERE BeatID = @BeatID AND CustomerID = @CustomerID) GOTO Done
IF EXISTS (Select BeatID From Beat_Salesman WHERE CustomerID = @CUSTOMERID)
BEGIN
	Select @OLDBEATID = BeatID From Beat_Salesman WHERE CustomerID = @CUSTOMERID
	IF (Select Count(*) From Beat_Salesman WHERE BeatID = @OLDBEATID) > 1
		Delete Beat_Salesman WHERE BeatID = @OLDBEATID AND CustomerID = @CustomerID
	ELSE
		Update Beat_Salesman SET CustomerID = N'' WHERE BeatID = @OLDBEATID
END
SELECT TOP 1 @OLD_SALESMANID = SalesmanID FROM Beat_Salesman WHERE BeatID = @BeatID
SET @OLD_SALESMANID = ISNULL(@OLD_SALESMANID, 0)
IF EXISTS (Select BeatID From Beat_Salesman WHERE BeatID = @BeatID AND CustomerID = N'')
Update Beat_Salesman SET CustomerID = @CustomerID WHERE BeatID = @BeatID
ELSE
Insert Into Beat_Salesman(BeatId,SalesmanId, CustomerID) Values(@BeatID, @OLD_SALESMANID, @CustomerID)
Done:

