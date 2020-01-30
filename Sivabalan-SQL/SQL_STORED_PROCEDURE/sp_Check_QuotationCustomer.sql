CREATE PROCEDURE sp_Check_QuotationCustomer(@CustomerID nVarchar(50), @QuotationID INT, @Flag int=0, @ValidFromDate DateTime, @ValidToDate DateTime)    
As        
Set DateFormat DMY
DECLARE @Count INT        
-- SELECT @ValidFromDate = dbo.StripDateFromTime(@ValidFromDate), @ValidToDate = dbo.StripDateFromTime(@ValidToDate)
SELECT @Count = Count(*) FROM QuotationCustomers, QuotationAbstract WHERE         
QuotationAbstract.QuotationID = QuotationCustomers.QuotationID         
And CustomerID = @CustomerID And Active = 1 
And QuotationAbstract.QuotationID <> (CASE @Flag WHEN 1  THEN @QuotationID ELSE @Flag END)    
And ((ValidFromDate BETWEEN @ValidFromDate AND @ValidToDate) or (ValidToDate BETWEEN @ValidFromDate AND @ValidToDate))
IF @Count > 0         
SELECT 1        
ELSE        
SELECT 0 

