CREATE procedure [dbo].[spr_list_invoices_by_salesman_abstract2](@SALESMAN_NAME nvarchar(2550),
							@FROMDATE DATETIME,  
						        @TODATE DATETIME)  
AS  

Declare @Delimeter as Char(1)    
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

Set @Delimeter=Char(15)    
Create table #tmpSalesMan(SalesmanName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @SALESMAN_NAME='%'     
   Insert into #tmpSalesMan select Salesman_Name from Salesman    
Else    
   Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@SALESMAN_NAME,@Delimeter)    

-- DECLARE @SalesmanID int
-- Select @SalesmanID = IsNull(SalesmanID,0) From Salesman Where Salesman_Name = @SALESMAN_NAME
IF @SALESMAN_NAME = '%'
BEGIN
SELECT  isnull(InvoiceAbstract.SalesmanID, 0 ), 
 "Salesman" = case isnull(InvoiceAbstract.SalesmanID, 0 ) when 0 then @OTHERS else Salesman.Salesman_Name end,   
 "Goods Value (%c)" = Sum(SalePrice * Quantity - (SalePrice * Quantity * InvoiceDetail.DiscountPercentage / 100)),
 "Discount (%c)" = Sum(SalePrice * Quantity * (AdditionalDiscount+InvoiceAbstract.DiscountPercentage) / 100), 
 "Net Value (%c)" = Sum(Amount),
 "Pending Bills" = dbo.GetPendingBillsForSalesman(IsNull(InvoiceAbstract.SalesmanID, 0), @FROMDATE, @TODATE),
 "Cash Invoices (%c)" = Sum(Case When IsNull(PaymentMode,0) > 0 And IsNull(PaymentMode,0) < 4 Then Amount Else 0 End), 
 "Credit Invoices (%c)" = Sum(Case IsNull(PaymentMode,0) When 0 Then Amount Else 0 End)
FROM InvoiceAbstract, Salesman, InvoiceDetail
WHERE   InvoiceType in (1, 3) AND  
 (InvoiceAbstract.Status & 128) = 0 AND  
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID AND  
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
 Salesman.Salesman_Name In (select SalesmanName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
GROUP BY InvoiceAbstract.SalesmanID, Salesman.Salesman_Name  
END
ELSE
BEGIN
SELECT  isnull(InvoiceAbstract.SalesmanID, 0 ), "Salesman" = case isnull(InvoiceAbstract.SalesmanID, 0 ) when 0 then @OTHERS else Salesman.Salesman_Name end,   
 "Goods Value (%c)" = Sum(SalePrice * Quantity - (SalePrice * Quantity * InvoiceDetail.DiscountPercentage / 100)),
 "Discount (%c)" = Sum(SalePrice * Quantity * (AdditionalDiscount+InvoiceAbstract.DiscountPercentage) / 100), 
 "Net Value (%c)" = Sum(Amount),
 "Pending Bills" = dbo.GetPendingBillsForSalesman(IsNull(InvoiceAbstract.SalesmanID,0), @FROMDATE, @TODATE),
 "Cash Invoices (%c)" = Sum(Case When IsNull(PaymentMode,0) > 0 And IsNull(PaymentMode,0) < 4 Then Amount Else 0 End), 
 "Credit Invoices (%c)" = Sum(Case IsNull(PaymentMode,0) When 0 Then Amount Else 0 End)
FROM InvoiceAbstract, Salesman, InvoiceDetail
WHERE   InvoiceType in (1, 3) AND  
 (InvoiceAbstract.Status & 128) = 0 AND  
 InvoiceAbstract.SalesmanID = Salesman.SalesmanID AND  
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And
 Salesman.Salesman_Name In (select SalesmanName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
GROUP BY InvoiceAbstract.SalesmanID, Salesman.Salesman_Name  
END
Drop table #tmpSalesMan
