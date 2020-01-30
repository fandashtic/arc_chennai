CREATE PROCEDURE spr_linespercall(@DSType nVarchar(2550), @FROMDATE DATETIME,  
      @TODATE DATETIME)  
AS  
  
Declare @OTHERS NVarchar(50)  
Declare @Delimeter Nvarchar(1)

Set @Delimeter = Char(15)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default) 

Create table #tmpDSType
(SalesmanID Int,
Salesman_Name nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
DSTypeName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS) 

if @DSType = N'%' or @DSType = N''       
   Insert into #tmpDSType 
   select Salesman.SalesmanID,Salesman_Name, DSTypeValue 
   from DSType_Master,DSType_Details,Salesman
   Where Salesman.SalesmanID = DSType_Details.SalesmanID
   and DSType_Details.DSTypeID = DSType_Master.DSTypeID 
   and DSType_Master.DSTypeCtlPos = 1 
   Union
   Select SalesmanID,Salesman_Name,'' from Salesman 
   where SalesmanID not in (select SalesmanID from DSType_Details where DSTypeCtlPos = 1 )
   Union
   Select 0, @Others, ''
Else        
   Insert into #tmpDSType 
   select Salesman.SalesmanID,Salesman_Name,DSTypeValue from DSType_Master,DSType_Details,Salesman
   Where DSType_Master.DSTypeID = DSType_Details.DSTypeID  
   and DSType_Details.SalesmanID = Salesman.SalesmanID
   and DSType_Master.DSTypeCtlPos = 1 
   and DSType_Master.DSTypeValue in (select * from dbo.sp_SplitIn2Rows(@DSType,@Delimeter))  

  
create table #temptable (manid int, ItemCount Decimal(18,6), ItemAmount Decimal(18,6))  
insert into #temptable(manid,ItemCount, ItemAmount)   
SELECT IsNull(InvoiceAbstract.salesmanid, 0),   
"ItemCount"=count(Distinct Product_Code),   
Sum(Amount)  
FROM InvoiceAbstract,InvoiceDetail, Customer, #tmpDSType  
WHERE   InvoiceType in (1, 3) AND InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID AND  
 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
 Isnull(InvoiceAbstract.SalesmanID,0) = #tmpDSType.SalesmanID AND  
 InvoiceAbstract.InvoiceDate BETWEEN @FromDate and @ToDate AND  
 (InvoiceAbstract.Status & 128) = 0  
GROUP BY invoicedate,InvoiceAbstract.InvoiceID, IsNull(InvoiceAbstract.salesmanid, 0)  
  
SELECT  #temptable.manID, "DS Name" =  #tmpDSType.Salesman_Name,"DS Type" = #tmpDSType.DSTypeName,      
 "Net Value (Rs)" = SUM(ItemAmount), "Avg Lines Per Call" = cast(round(avg(ItemCount),1) as Decimal(18,6))  
FROM #tmpDSType, #temptable  
WHERE #temptable.manid = #tmpDSType.salesmanid   
GROUP BY #tmpDSType.Salesman_Name,#tmpDSType.DSTypeName, #temptable.manid  
drop table #temptable  

