IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'CustomerLedger')
BEGIN
	DROP TABLE CustomerLedger
END
GO
Create Table CustomerLedger
(
	CustomerId Nvarchar(255),
	TransactionDate DateTime,
	TransactionType Nvarchar(255),
	TransactionId Nvarchar(255),
	SalesmanID INT,
	BeatID INT,
	Debit Decimal(18,6) Default 0,
	Credit Decimal(18,6) Default 0,
	InvoiceReference Nvarchar(255),
	DueDays INT,
	DueDate DATETIME,
	TotalSalesReturn DEcimal(18,6),
	TotalCreditNote DEcimal(18,6),
	TotalDebitNote DEcimal(18,6),
	TotalCollection DEcimal(18,6),
	CurrentOutstanding DEcimal(18,6),
	Remarks Nvarchar(4000)
)
GO

