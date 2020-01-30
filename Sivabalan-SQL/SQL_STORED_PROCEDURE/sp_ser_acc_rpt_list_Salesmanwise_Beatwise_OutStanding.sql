CREATE procedure [dbo].[sp_ser_acc_rpt_list_Salesmanwise_Beatwise_OutStanding](@Beat Varchar(2550),      
           @Salesman Varchar(2550),      
           @FromDate datetime,      
           @ToDate datetime)      
as      

Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Create table #tmpBeat(BeatName varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create table #tmpSalesMan(SalesManName varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

if @Beat='%'    
begin
   Insert into #tmpBeat select Description from Beat
   Insert into #tmpBeat values ('Others')
end
Else    
   Insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter)    
if @Salesman='%'     
begin
   Insert into #tmpSalesMan select salesman_name from SalesMan    
   Insert into #tmpSalesMan values ('Others')
end
Else    
   Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter)    


create table #temp      
(      
 SalesmanID int not null,      
 BeatID int not null,      
 Balance Decimal(18,6) not null,      
 CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS not null      
)     

insert into #temp      
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),       
 Sum(ISNULL(Balance,0)), CustomerID      
 from InvoiceAbstract
Left Outer Join Beat on isNull(InvoiceAbstract.BeatID,0) = isNull(Beat.BeatID,0)
Left Outer Join Salesman on isNull(InvoiceAbstract.SalesmanID,0) = isNull(Salesman.SalesmanID,0) 
 where IsNull(InvoiceAbstract.Status,0) & 128 = 0 and      
 InvoiceAbstract.Balance > 0 and      
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.InvoiceDate between @FromDate AND @ToDate And      
 isNull(Beat.Description,'Others') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 isNull(Salesman.Salesman_Name,'Others') In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)    
 group by IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
 InvoiceAbstract.CustomerID      
    
 insert into #temp      
 select  IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
  0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID      
 from InvoiceAbstract
Left Outer Join Beat on isNull(InvoiceAbstract.BeatID,0) = isNull(Beat.BeatID,0)
Left Outer Join Salesman on isNull(InvoiceAbstract.SalesmanID,0) = isNull(Salesman.SalesmanID,0) 
 WHERE  ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND      
 (Isnull(Status,0) & 128) = 0 AND      
 InvoiceDate Between @FromDate AND @ToDate And      
 isNull(Beat.Description,'Others') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 isNull(Salesman.Salesman_Name,'Others') In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)    

--Begin: Service Invoice Impact
insert into #temp
 select 0,0,isNull(balance,0),CustomerID 
 from ServiceInvoiceAbstract
 where 'Others' in (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)
 and 'Others' in (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
 and ServiceInvoiceType in (1) and isNull(Balance,0) > 0
 and isNull(Status,0) & 192 = 0 
 and ServiceInvoiceDate Between @FromDate AND @ToDate
--End: Service Invoice Impact      

 insert into #temp      
 SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
  0 - ISNULL(Balance, 0), CustomerID 
	FROM Collections
Left Outer Join Beat on isNull(Collections.BeatID,0) = isNull(Beat.BeatID,0)
Left Outer Join Salesman on isNull(Collections.SalesmanID,0) = isNull(Salesman.SalesmanID,0) 
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 isNull(Beat.Description,'Others') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 isNull(Salesman.Salesman_Name,'Others') In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
 and CustomerID is not null

 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
  IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = CreditNote.CustomerID), 0),       
  0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote
 Left Outer Join Salesman on isNull(CreditNote.SalesmanID,0) = isNull(Salesman.SalesmanID,0) 
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman
  Left Outer Join Beat on Beat_Salesman.BeatID = Beat.BeatID where CustomerID = CreditNote.CustomerID), 'Others') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 isNUll(Salesman.Salesman_Name,'Others') In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote 
 Left Outer Join Salesman on isNull(DebitNote.SalesmanID,0) = isNull(Salesman.SalesmanID,0) 
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman
Left Outer Join Beat on Beat_Salesman.BeatID = Beat.BeatID where CustomerID = DebitNote.CustomerID), 'Others') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 isNull(Salesman.Salesman_Name,'Others') In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 select  cast(#temp.SalesmanID as varchar) + ';' + cast(#temp.BeatID as varchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, 'Others'),       
  "Beat" = IsNull(Beat.Description, 'Others'),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp, Salesman, Beat      
 WHERE #temp.SalesmanID *= Salesman.SalesmanID And #temp.BeatID *= Beat.BeatID      
 Group By #temp.SalesmanID, #temp.BeatID, Salesman.Salesman_Name, Beat.Description      

drop table #temp    
DROP TABLE #tmpBeat  
DROP TABLE #tmpSalesMan
