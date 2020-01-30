--Exec sp_SaveCustomerCreditLimit 9, 2019
IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'sp_SaveCustomerCreditLimit')
BEGIN
	DROP PROC [sp_SaveCustomerCreditLimit]
END
GO
CREATE Procedure sp_SaveCustomerCreditLimit (@CustID NVARCHAR(30), @GroupName NVARCHAR(250), @CreditDays INT, @CreditLimit DECIMAL(18,6), @NoOfBills INT)
As
Begin 
	Declare @GroupId as int
	Select @GroupId = GroupId From ProductCategoryGroupAbstract WITH (NOLOCK) Where GroupName = @GroupName

	IF ISNULL(@CreditDays, 0) >= 0 
	BEGIN
		Exec sp_credit_ImportCreditTerm @CreditDays
		Select @CreditDays = CreditID From CreditTerm WITH (NOLOCK) Where ISNUll([Value], 0) = ISNULL(@CreditDays, 0)
	End

	IF Not Exists(select Top 1 1 from CustomerCreditLimit WITH (NOLOCK) WHERE GroupID = @GroupID AND CustomerID = @CustID)
	BEGIN
		Insert Into CustomerCreditLimit(CustomerID,GroupID,CreditTermDays,CreditLimit,NoOfBills)
		Select @CustID, @GroupID, @CreditDays, @CreditLimit, @NoOfBills
	END
	ELSE
	BEGIN
		UPDATE C 
		SET C.CreditTermDays = @CreditDays, C.CreditLimit = @CreditLimit, C.NoOfBills = @NoOfBills
		FROM  CustomerCreditLimit C WITH (NOLOCK) 
		WHERE C.CustomerID = @CustID AND C.GroupID = @GroupID
	END

	Update C SET C.CreditLimit = L.CreditLimit
	FROM Customer C WITH (NOLOCK)
	JOIN (SELECT CustomerID, SUM(CreditLimit) CreditLimit FROM CustomerCreditLimit WITH (NOLOCK) WHERE CustomerID = @CustID GROUP BY CustomerID) L ON L.CustomerID = C.CustomerID
End