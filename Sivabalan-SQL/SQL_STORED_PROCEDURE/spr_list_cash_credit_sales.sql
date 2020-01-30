CREATE PROCEDURE spr_list_cash_credit_sales(@FROMDATE datetime,  
         @TODATE datetime)  
AS  

Declare @CASHSALES nVarchar(50)
SElect @CASHSALES = dbo.LookupDictionaryItem(N'Cash Sales',Default)

SELECT  InvoiceAbstract.CreditTerm, "Credit Term" = Isnull(CreditTerm.Description,@CASHSALES),   
 "Gross Sales (%c)" = SUM(NetValue)  
FROM    InvoiceAbstract left outer join creditTerm on   
        InvoiceAbstract.CreditTerm = CreditTerm.CreditID  
WHERE   InvoiceAbstract.InvoiceType in (1, 3) and   
 (InvoiceAbstract.Status & 128) = 0 and  
 --(InvoiceAbstract.CreditTerm = CreditTerm.CreditID or   
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY InvoiceAbstract.CreditTerm, CreditTerm.Description 

