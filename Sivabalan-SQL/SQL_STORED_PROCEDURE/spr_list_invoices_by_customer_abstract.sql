CREATE PROCEDURE spr_list_invoices_by_customer_abstract(@CUSTOMER nvarchar(2550),  
              @FROMDATE datetime,  
              @TODATE datetime)  
AS  
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Create table #tmpCustomer(Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @CUSTOMER='%'   
	Insert into #tmpCustomer select Company_Name from Customer  
Else  
	Insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@CUSTOMER,@Delimeter)  

SELECT  InvoiceAbstract.CustomerID, Customer.Company_Name,  
 "Net Value" = Sum(NetValue), "Balance" =  Sum(Balance)  
FROM InvoiceAbstract, Customer  
WHERE   (InvoiceType = 1 OR InvoiceType = 3)   
 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE   
 AND InvoiceAbstract.CustomerID = Customer.CustomerID   
 AND Customer.Company_Name IN (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer)
 AND InvoiceAbstract.Status & 128 = 0  
GROUP BY InvoiceAbstract.CustomerID, Customer.Company_Name  

Drop Table #tmpCustomer

SET QUOTED_IDENTIFIER OFF   



