CREATE PROCEDURE spr_top_customers_Perfetti(@FROMDATE datetime,      
       @TODATE datetime, @CusType nvarchar(50), @Beat nvarchar(2550))      
AS      
      
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Declare @MLOtherCustomer NVarchar(50)
Declare @MLOtherBeat NVarchar(50)
Set @MLOtherCustomer = dbo.LookupDictionaryItem(N'Other Customer', Default)
Set @MLOtherBeat = dbo.LookupDictionaryItem(N'Other Beat', Default)
Set @CusType = dbo.LookupDictionaryItem2(@CusType, Default)

Create table #tmpBeat([Description] nvarchar(255))  

if @Beat ='%'   
   Insert into #tmpBeat select [Description] from Beat
Else  
   Insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@Beat, @Delimeter)  

IF @CusType = 'Trade'      
BEGIN      
SELECT  TOP 25 Customer.CustomerID, Customer.Company_Name,       
 "Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail      
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   CustomerID = Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND       
   InvoiceType in (1, 3) AND (Status & 128) = 0), 0) -       
   ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail       
   WHERE  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   CustomerID = Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND       
   InvoiceType = 4 AND (Status & 128) = 0), 0),  
 "Beat" = IsNull([Description], @MLOtherBeat)  
FROM Customer, Beat_Salesman, Beat Where   
Customer.CustomerID = Beat_Salesman.CustomerID And Beat.BeatID = Beat_Salesman.BeatID  
And Beat.[Description] In (Select [Description] From #tmpBeat)
  
ORDER BY "Total Sales" DESC      
END      
ELSE      
BEGIN      
    
SELECT  TOP 25 "Customer ID" =Cast(Cash_Customer.CustomerID As nvarchar),   
 "Customer Name" = IsNull(Cash_Customer.CustomerName, @MLOtherCustomer),       
 "Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail      
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = Cash_Customer.CustomerID AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND       
   InvoiceType = 2 AND (Status & 128) = 0), 0), "Beat" = @MLOtherBeat      
INTO #TopCustomers FROM Cash_Customer      
ORDER BY "Total Sales" DESC      
      
INSERT INTO #TopCustomers SELECT @MLOtherCustomer, @MLOtherCustomer,       
 "Total Sales" = ISNULL((select SUM(Amount) from InvoiceAbstract, InvoiceDetail      
   WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and      
   InvoiceAbstract.CustomerID = 0 AND       
   InvoiceDate BETWEEN @FROMDATE AND @TODATE AND       
   InvoiceType = 2 AND (Status & 128) = 0), 0), "Beat" = @MLOtherBeat      
      
SELECT Top 25 * FROM #TopCustomers ORDER BY [Total Sales] DESC      
END      

Drop Table #tmpBeat



