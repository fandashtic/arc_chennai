CREATE FUNCTION fn_Get_CustomerName(@QuotationID INT)
RETURNS nVarchar(4000) AS 
BEGIN

DECLARE @CustomerList nVarchar(4000)
DECLARE @CustomerName nVarchar(255)

SET @CustomerList = ''

DECLARE CustomerList CURSOR FOR SELECT Company_Name FROM Customer, QuotationCustomers, QuotationAbstract
WHERE QuotationCustomers.QuotationID  = QuotationAbstract.QuotationID
And QuotationCustomers.CustomerID = Customer.CustomerID 
And QuotationAbstract.QuotationID = @QuotationID

OPEN CustomerList

FETCH NEXT FROM CustomerList INTO @CustomerName
WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @CustomerList = @CustomerList + @CustomerName + ','
FETCH NEXT FROM CustomerList INTO @CustomerName
END

CLOSE CustomerList
DEALLOCATE CustomerList

RETURN(LEFT(@CustomerList,LEN(@CustomerList) - 1))

END



