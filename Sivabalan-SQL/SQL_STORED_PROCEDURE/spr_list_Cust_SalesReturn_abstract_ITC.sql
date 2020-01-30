
Create Procedure spr_list_Cust_SalesReturn_abstract_ITC(  
  @CUSTOMER nVarChar(2250),   
  @FROMDATE DATETIME,   
  @TODATE DATETIME)  
AS  
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)  
Create table #tmpCustomer(CustomerName nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create table #tmpBeat_Customer(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, BeatID Int, BeatDesc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create table #tmpSalesReturn(BeatID Int, CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, TotalSalesReturn Decimal(18,6))        
IF @CUSTOMER=N'%'         
 BEGIN  
     Insert into #tmpSalesReturn  
     Select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, Sum(IsNull(InvoiceDetail.Amount,0)) as TotAmount  
  From InvoiceAbstract, InvoiceDetail  
  Where   
   InvoiceAbstract.InvoiceType in (4,5) And   
   IsNull(InvoiceAbstract.Status,0)&192 = 0 And  
   InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And   
   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
  Group By InvoiceAbstract.CustomerID, InvoiceAbstract.BeatID
 END  
ELSE      
 BEGIN    
  Insert into #tmpCustomer Select * from dbo.sp_SplitIn2Rows(@CUSTOMER,@Delimeter)  
  Insert into #tmpSalesReturn  
  Select InvoiceAbstract.BeatID, InvoiceAbstract.CustomerID, Sum(IsNull(InvoiceDetail.Amount,0)) as TotAmount  
  From InvoiceAbstract, InvoiceDetail, Customer  
  Where   
   InvoiceAbstract.InvoiceType in (4,5) And   
   IsNull(InvoiceAbstract.Status,0)&192 = 0 And   
   InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE And   
   Customer.Company_Name in (Select CustomerName From #tmpCustomer) And   
   InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And  
   Customer.CustomerID =  InvoiceAbstract.CustomerID  
  Group By InvoiceAbstract.CustomerID, InvoiceAbstract.BeatID
 END  
--BEGIN  
--------------------------
-- select * from #tmpSalesReturn  
--------------------------
Insert into #tmpBeat_Customer   
Select Distinct InvoiceAbstract.CustomerID, Beat.BeatID, Beat.Description  
From InvoiceAbstract, Beat  
Where Beat.BeatID = InvoiceAbstract.BeatID And
   InvoiceAbstract.InvoiceType in (4,5) And   
   IsNull(InvoiceAbstract.Status,0)&192 = 0 And   
   InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE 

----------------
-- select * from #tmpBeat_Customer   
----------------

SELECT    
 Customer.Company_Name + Char(15) + Cast(#tmpBeat_Customer.BeatID as nVarchar),
 "Customer Name" = Customer.Company_Name,   
 "Beat Name" = IsNull(#tmpBeat_Customer.BeatDesc,''),   
 "Total Sales return value (%c)" = IsNull(#tmpSalesReturn.TotalSalesReturn,0)  
FROM   
 #tmpSalesReturn, Customer, #tmpBeat_Customer  
WHERE   
 Customer.CustomerID = #tmpBeat_Customer.CustomerID And   
 #tmpBeat_Customer.BeatID = #tmpSalesReturn.BeatID And
#tmpSalesReturn.CustomerID=  #tmpBeat_Customer.CustomerID
ORDER BY  
 #tmpBeat_Customer.BeatDesc, Customer.Company_Name   
--END  
Drop table #tmpSalesReturn    
Drop table #tmpCustomer  
Drop table #tmpBeat_Customer  
  
