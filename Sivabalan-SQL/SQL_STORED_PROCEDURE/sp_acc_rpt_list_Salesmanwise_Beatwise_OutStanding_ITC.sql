CREATE procedure sp_acc_rpt_list_Salesmanwise_Beatwise_OutStanding_ITC(@Beat nVarchar(2550),      
           @Salesman nVarchar(2550),      
           @FromDate datetime,      
           @ToDate datetime)      
as      

Declare @Delimeter as nChar(1)    
Set @Delimeter=Char(15)    
Create table #tmpBeat(BeatName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create table #tmpSalesMan(SalesManName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

if @Beat=N'%'    
   Insert into #tmpBeat select Description from Beat    
Else    
   Insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter)    
if @Salesman=N'%'     
   Insert into #tmpSalesMan select salesman_name from SalesMan    
Else    
   Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter)    


create table #temp      
(      
 SalesmanID int not null,      
 BeatID int not null,      
 Balance Decimal(18,6) not null,      
 CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS not null      
)     
     
IF (@SALESMAN = N'%') And (@Beat = N'%')       
Begin    
 insert into #temp      
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),       
 ISNULL(Sum(Balance), 0), CustomerID      
 from InvoiceAbstract
 Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
 Left Outer Join Salesman On IsNull(InvoiceAbstract.SalesmanID, 0)= Salesman.SalesmanID
 where InvoiceAbstract.Status & 128 = 0 and      
 InvoiceAbstract.Balance > 0 and      
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.InvoiceDate between @FromDate AND @ToDate And      
 Beat.Description In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And      
 Salesman.Salesman_Name In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)    
 group by IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
 InvoiceAbstract.CustomerID      
    
 insert into #temp      
 select  IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
  0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID      
 FROM InvoiceAbstract
 Left Outer Join  Beat On InvoiceAbstract.BeatID = Beat.BeatID
 Left Outer Join  Salesman On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID          
 WHERE  ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND      
 (Status & 128) = 0 AND      
 InvoiceDate Between @FromDate AND @ToDate And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 insert into #temp      
SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
 0 - ISNULL(Balance, 0), CustomerID 
FROM Collections
Left Outer Join Beat On Collections.BeatID = Beat.BeatID
Left Outer Join  Salesman On IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID 
WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
 and CustomerID is not null


 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
 IsNull((select DefaultBeatID From Customer Where CustomerID = CreditNote.CustomerID), 0), 0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote
 Left Outer Join  Salesman  On IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID 
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description
 From Customer
 Left Outer Join Beat On Customer.DefaultBeatID = Beat.BeatID Where CustomerID = CreditNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select DefaultBeatID From Customer Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote
 Left Outer Join  Salesman  On IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And IsNull(DebitNote.Status, 0) & 192 = 0 And  
 IsNull((Select Beat.Description From Customer Left Outer Join Beat On Customer.DefaultBeatID = Beat.BeatID Where  CustomerID = DebitNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 select  cast(#temp.SalesmanID as nvarchar) + N';' + cast(#temp.BeatID as nvarchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, dbo.LookupDictionaryItem('Others',Default)),       
  "Beat" = IsNull(Beat.Description, dbo.LookupDictionaryItem('Others',Default)),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp 
 Left Outer Join Salesman On #temp.SalesmanID = Salesman.SalesmanID
 Left Outer Join  Beat On #temp.BeatID = Beat.BeatID           
 Group By  #temp.SalesmanID,#temp.BeatID,Beat.Description,Salesman.Salesman_Name 
 Order By Beat    
End    
ELSE IF (@SALESMAN = N'%') And (@Beat <> N'%')        
Begin    
 insert into #temp      
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),       
 ISNULL(Sum(Balance), 0), CustomerID      
 from InvoiceAbstract
 Inner Join  Beat On InvoiceAbstract.BeatID = Beat.BeatID
 Left Outer Join Salesman  On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID 
 where InvoiceAbstract.Status & 128 = 0 and      
 InvoiceAbstract.Balance > 0 and      
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.InvoiceDate between @FromDate AND @Todate And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)    
 group by IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0), InvoiceAbstract.CustomerID      
    
insert into #temp      
 select  IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
  0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID      
 FROM InvoiceAbstract
 Inner Join  Beat On InvoiceAbstract.BeatID = Beat.BeatID
 Left Outer Join Salesman  On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID 
 WHERE  ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND      
 (Status & 128) = 0 AND      
 InvoiceDate Between @FromDate AND @ToDate And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
 
 insert into #temp      
 SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
  0 - ISNULL(Balance, 0), CustomerID FROM Collections
  Inner Join Beat On Collections.BeatID = Beat.BeatID
 Left Outer Join  Salesman On IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
 and CustomerID is not null
       
 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
 IsNull((select DefaultBeatId From Customer Where CustomerID = CreditNote.CustomerID), 0),       
 0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote
 Left Outer Join Salesman On IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Customer, Beat Where Customer.DefaultBeatID = Beat.BeatID And CustomerID = CreditNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
 
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select DefaultBeatID From Customer Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote
 Left Outer Join Salesman On IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And IsNull(DebitNote.Status, 0) & 192 = 0 And 
 IsNull((Select Beat.Description From Customer, Beat Where Customer.DefaultBeatID = Beat.BeatID And CustomerID = DebitNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 select  cast(#temp.SalesmanID as nvarchar) + N';' + cast(#temp.BeatID as nvarchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, dbo.LookupDictionaryItem('Others',Default)),       
  "Beat" = IsNull(Beat.Description, dbo.LookupDictionaryItem('Others',Default)),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp
 Left Outer Join Salesman On #temp.SalesmanID = Salesman.SalesmanID
 Inner Join Beat On #temp.BeatID = Beat.BeatID          
 Group By #temp.SalesmanID, #temp.BeatID, Salesman.Salesman_Name, Beat.Description
 Order By Beat      
End    
ELSE IF (@SALESMAN <> N'%') And (@Beat = N'%')  
Begin    
insert into #temp    
select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),       
 ISNULL(Sum(Balance), 0), CustomerID      
 from InvoiceAbstract
 Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
 Inner Join Salesman On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID 
 where InvoiceAbstract.Status & 128 = 0 and      
 InvoiceAbstract.Balance > 0 and    
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.InvoiceDate between @FromDate AND @ToDate And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)    
 group by IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
 InvoiceAbstract.CustomerID      
  
insert into #temp      
 select  IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
  0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID      
 FROM InvoiceAbstract
 Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
 Inner Join Salesman On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID
 WHERE  ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND      
 (Status & 128) = 0 AND      
 InvoiceDate Between @FromDate AND @Todate And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 insert into #temp      
 SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
 0 - ISNULL(Balance, 0), CustomerID FROM Collections
  Left Outer Join Beat On Collections.BeatID = Beat.BeatID
 Inner Join Salesman  On IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
 and CustomerID is not null
       
 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
  IsNull((select DefaultBeatID From Customer Where CustomerID = CreditNote.CustomerID), 0),       
  0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote, Salesman      
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Customer Left Outer Join Beat On Customer.DefaultBeatID = Beat.BeatID Where CustomerID = CreditNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select DefaultBeatID From Customer Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And IsNull(DebitNote.Status, 0) & 192 = 0 And 
 IsNull((Select Beat.Description From Customer Left Outer Join  Beat On Customer.DefaultBeatID = Beat.BeatID Where CustomerID = DebitNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 select  cast(#temp.SalesmanID as nvarchar) + N';' + cast(#temp.BeatID as nvarchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, dbo.LookupDictionaryItem('Others',Default)),       
  "Beat" = IsNull(Beat.Description, dbo.LookupDictionaryItem('Others',Default)),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp
 Inner Join Salesman On #temp.SalesmanID = Salesman.SalesmanID
 Left Outer Join Beat On #temp.BeatID = Beat.BeatID           
 Group By #temp.SalesmanID, #temp.BeatID, Salesman.Salesman_Name, Beat.Description
 Order By Beat      
End    
Else     
Begin    
 insert into #temp    
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),       
  ISNULL(Sum(Balance), 0), CustomerID      
  from InvoiceAbstract, Beat, Salesman      
  where InvoiceAbstract.Status & 128 = 0 and      
InvoiceAbstract.Balance > 0 and      
  InvoiceAbstract.InvoiceType in (1, 3) and      
  InvoiceAbstract.InvoiceDate between @FromDate AND @ToDate And      
  InvoiceAbstract.BeatID = Beat.BeatID And       
  Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
  IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And      
  Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)    
  group by IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
  InvoiceAbstract.CustomerID      
    
insert into #temp      
 select  IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
  0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID      
 FROM InvoiceAbstract, Beat, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND      
 (Status & 128) = 0 AND      
 InvoiceDate Between @FromDate AND @ToDate And      
 InvoiceAbstract.BeatID = Beat.BeatID And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 insert into #temp      
 SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Beat, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 Collections.BeatID = Beat.BeatID And      
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
 and CustomerID is not null	 
      
 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
  IsNull((select DefaultBeatID From Customer Where CustomerID = CreditNote.CustomerID), 0),       
  0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote, Salesman      
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Customer, Beat Where Customer.DefaultBeatID = Beat.BeatID And CustomerID = CreditNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select DefaultBeatID From Customer Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And  IsNull(DebitNote.Status, 0) & 192 = 0  And 
 IsNull((Select Beat.Description From Customer, Beat Where Customer.DefaultBeatID = Beat.BeatID And CustomerID = DebitNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And      
 IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)      
       
 select  cast(#temp.SalesmanID as nvarchar) + N';' + cast(#temp.BeatID as nvarchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, dbo.LookupDictionaryItem('Others',Default)),       
  "Beat" = IsNull(Beat.Description, dbo.LookupDictionaryItem('Others',Default)),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp, Salesman, Beat      
 WHERE #temp.SalesmanID = Salesman.SalesmanID And #temp.BeatID = Beat.BeatID      
 Group By #temp.SalesmanID, #temp.BeatID, Salesman.Salesman_Name, Beat.Description
 Order By Beat      
 End    
    
drop table #temp    
DROP TABLE #tmpBeat  
DROP TABLE #tmpSalesMan  
