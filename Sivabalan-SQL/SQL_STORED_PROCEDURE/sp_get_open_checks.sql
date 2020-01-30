CREATE PROCEDURE sp_get_open_checks(@CUSTOMER nvarchar(15),
				    @FROMDATE datetime,
				    @TODATE datetime)
AS
Select Customer.Company_Name, ChequeNumber, ChequeDate, Value, FullDocID, DocumentID,
BankMaster.BankName, BranchMaster.BranchName, Collections.PaymentMode
FROM Collections, Customer, BankMaster, BranchMaster
WHERE	Collections.CustomerID like @CUSTOMER AND
	ChequeDate BETWEEN @FROMDATE AND @TODATE and
	Collections.CustomerID = Customer.CustomerID and
	PaymentMode in (1, 2) and
	ISNULL(Status, 0) <> 1 and
	Collections.BankCode = BankMaster.BankCode and
	Collections.BranchCode = BranchMaster.BranchCode and
	BankMaster.BankCode = BranchMaster.BankCode And
	(IsNull(Collections.Status, 0) & 192) = 0
Order By Collections.CustomerID
