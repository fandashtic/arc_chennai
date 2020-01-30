
create procedure sp_acc_rpt_list_SMCustomer_OutStanding_ITC1(  @Beat nVarchar(2550),   
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
BEGIN  
   
 insert into #temp  
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 from InvoiceAbstract
 Left Outer Join Beat On IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID
 Left Outer Join Salesman  On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID
 where InvoiceAbstract.Status & 128 = 0 and  
 InvoiceAbstract.Balance > 0 and  
 InvoiceAbstract.InvoiceType in (1, 2, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)  
 group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 FROM InvoiceAbstract
 Left Outer Join Salesman On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID
 Left Outer Join Beat  On IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType In (4, 5, 6) AND (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)  
 Group By InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),   
  0 - ISNULL(Balance, 0), CustomerID FROM Collections
  Left Outer Join Salesman On IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID
  Left Outer Join Beat On  IsNull(Collections.BeatID, 0) = Beat.BeatID
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)and CustomerID is not null
   
 insert into #temp   
 SELECT  ISNULL(CreditNote.SalesmanID, 0),    
 IsNull((select DefaultBeatID From Customer
 Where CustomerID = CreditNote.CustomerID), 0),   
 0 - ISNULL(Balance, 0), CustomerID   
 FROM CreditNote
 Left Outer Join Salesman On IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID
 WHERE   ISNULL(Balance, 0) > 0 AND   
 DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
 IsNull((Select Beat.Description From Customer Left Outer Join    Beat  On Customer.DefaultBeatID = Beat.BeatID 
 Where  CustomerID = CreditNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)  
   
 insert into #temp   
 SELECT ISNULL(DebitNote.SalesmanID, 0),   
 IsNull((select DefaultBeatID From Customer Where   
 CustomerID = DebitNote.CustomerID), 0),   
 ISNULL(Balance, 0), CustomerID FROM DebitNote
  Left Outer Join Salesman  On IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  IsNull(DebitNote.Status, 0) & 192 = 0  And
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
 IsNull((Select Beat.Description From Customer Left Outer Join Beat   On Customer.DefaultBeatID = Beat.BeatID
 Where CustomerID = DebitNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)   
   
 select Cast(#temp.SalesmanID as nVarchar) + N';' + Cast(#temp.BeatID as nVarchar),  
  "Beat" = IsNull(Beat.Description, N'Others'),   
  "Salesman" = IsNull(Salesman.Salesman_Name, N'Others'),   
  "Net Outstanding (%c)" = SUM(Balance)  from #temp Left Outer Join Salesman On #temp.SalesmanID = Salesman.SalesmanID Left Outer Join Beat On #temp.BeatID = Beat.BeatID   
 Group By #temp.SalesmanID, Salesman.Salesman_Name, #temp.BeatID, Beat.Description  
END  
ELSE IF (@SALESMAN = N'%') And (@Beat <> N'%')      
BEGIN  
 insert into #temp  
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 from InvoiceAbstract
 Left Outer Join  Salesman On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID
 Inner Join Beat On IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID
 where InvoiceAbstract.Status & 128 = 0 and  
 InvoiceAbstract.Balance > 0 and  
 InvoiceAbstract.InvoiceType in (1, 2, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)  
 group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 FROM InvoiceAbstract
 Left Outer Join Salesman On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID
 Inner Join Beat  On IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType In (4, 5, 6) AND  
 (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)  
 Group By InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),   
  0 - ISNULL(Balance, 0), CustomerID FROM Collections
  Left Outer Join Salesman On  IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID
  Inner Join  Beat  On IsNull(Collections.BeatID, 0) = Beat.BeatID
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
and CustomerID is not null
   
 insert into #temp   
 SELECT  ISNULL(CreditNote.SalesmanID, 0),    
 IsNull((select DefaultBeatID From Customer
 Where CustomerID = CreditNote.CustomerID), 0),   
 0 - ISNULL(Balance, 0), CustomerID   
 FROM CreditNote Left Outer Join Salesman  On IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID
 WHERE   ISNULL(Balance, 0) > 0 AND   
 DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
 IsNull((Select Beat.Description From Customer, Beat   
 Where Customer.DefaultBeatID = Beat.BeatID And   
 CustomerID = CreditNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)  
   
 insert into #temp   
 SELECT ISNULL(DebitNote.SalesmanID, 0),   
 IsNull((select DefaultBeatID From Customer Where   
 CustomerID = DebitNote.CustomerID), 0),   
 ISNULL(Balance, 0), CustomerID FROM DebitNote Left Outer Join Salesman On  IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID 
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  IsNull(DebitNote.Status, 0) & 192 = 0  And
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
 IsNull((Select Beat.Description From Customer, Beat   
 Where Customer.DefaultBeatID = Beat.BeatID And   
 CustomerID = DebitNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)   
   
 select Cast(#temp.SalesmanID as nVarchar) + N';' + Cast(#temp.BeatID as nVarchar),  
  "Beat" = IsNull(Beat.Description, N'Others'),   
  "Salesman" = IsNull(Salesman.Salesman_Name,N'Others'),   
  "Net Outstanding (%c)" = SUM(Balance)  from #temp 
  Left Outer Join Salesman On  #temp.SalesmanID = Salesman.SalesmanID
  Inner Join  Beat On #temp.BeatID = Beat.BeatID    
 Group By #temp.SalesmanID, Salesman.Salesman_Name, #temp.BeatID, Beat.Description  
END  
ELSE IF (@SALESMAN <> N'%') And (@Beat = N'%')  
BEGIN  
 insert into #temp  
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 from InvoiceAbstract
 Left Outer Join Beat On  IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID
 Inner Join Salesman On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID
 where InvoiceAbstract.Status & 128 = 0 and  
 InvoiceAbstract.Balance > 0 and  
 InvoiceAbstract.InvoiceType in (1, 2, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) 
 group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 FROM InvoiceAbstract
 Inner Join Salesman On IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID
 Left Outer Join Beat  On IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType In (4, 5, 6) AND  
 (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) 
 Group By InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),   
  0 - ISNULL(Balance, 0), CustomerID FROM Collections
  Inner Join Salesman On IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID
  Left Outer Join Beat On  IsNull(Collections.BeatID, 0) = Beat.BeatID
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
and CustomerID is not null
   
 insert into #temp   
 SELECT  ISNULL(CreditNote.SalesmanID, 0),    
 IsNull((select DefaultBeatID From Customer
 Where CustomerID = CreditNote.CustomerID), 0),   
 0 - ISNULL(Balance, 0), CustomerID   
 FROM CreditNote, Salesman  
 WHERE   ISNULL(Balance, 0) > 0 AND   
 DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
 IsNull((Select Beat.Description From Customer Left Outer Join Beat On  Customer.DefaultBeatID = Beat.BeatID
 Where CustomerID = CreditNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)  
   
 insert into #temp   
 SELECT ISNULL(DebitNote.SalesmanID, 0),   
 IsNull((select DefaultBeatID From Customer Where   
 CustomerID = DebitNote.CustomerID), 0),   
 ISNULL(Balance, 0), CustomerID FROM DebitNote, Salesman  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  IsNull(DebitNote.Status, 0) & 192 = 0  And
 IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
 IsNull((Select Beat.Description From Customer Left Outer Join Beat On Customer.DefaultBeatID = Beat.BeatID 
 Where CustomerID = DebitNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)   
   
 select Cast(#temp.SalesmanID as nVarchar) + N';' + Cast(#temp.BeatID as nVarchar),  
  "Beat" = IsNull(Beat.Description, N'Others'),   
  "Salesman" = IsNull(Salesman.Salesman_Name,N'Others'),   
  "Net Outstanding (%c)" = SUM(Balance)  from #temp
 Inner Join  Salesman On  #temp.SalesmanID = Salesman.SalesmanID
 Left Outer Join Beat  On #temp.BeatID = Beat.BeatID  
 Group By #temp.SalesmanID, Salesman.Salesman_Name, #temp.BeatID, Beat.Description  
     
 END  
   ELSE  
BEGIN  
 insert into #temp  
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 from InvoiceAbstract, Beat, Salesman  
 where InvoiceAbstract.Status & 128 = 0 and  
 InvoiceAbstract.Balance > 0 and  
 InvoiceAbstract.InvoiceType in (1, 2, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)  
 group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 FROM InvoiceAbstract, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType In (4, 5, 6) AND  
 (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)  
 Group By InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),   
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate And  
 IsNull(Collections.BeatID, 0) = Beat.BeatID And  
 Beat.Description In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) And  
 IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan)
 and CustomerID is not null
   
 insert into #temp   
 SELECT  ISNULL(CreditNote.SalesmanID, 0),    
 IsNull((select DefaultBeatID From Customer
 Where CustomerID = CreditNote.CustomerID), 0),   
 0 - ISNULL(Balance, 0), CustomerID   
 FROM CreditNote, Salesman  
 WHERE   ISNULL(Balance, 0) > 0 AND   
 DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
 IsNull((Select Beat.Description From Customer, Beat   
 Where Customer.DefaultBeatID = Beat.BeatID And   
 CustomerID = CreditNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)  
   
 insert into #temp   
 SELECT ISNULL(DebitNote.SalesmanID, 0),   
 IsNull((select DefaultBeatID From Customer Where   
 CustomerID = DebitNote.CustomerID), 0),   
 ISNULL(Balance, 0), CustomerID FROM DebitNote, Salesman  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  IsNull(DebitNote.Status, 0) & 192 = 0  And 
 IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And  
 IsNull((Select Beat.Description From Customer, Beat   
 Where Customer.DefaultBeatID = Beat.BeatID And   
 CustomerID = DebitNote.CustomerID), N'%') In (Select BeatName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat)   
   
 select Cast(#temp.SalesmanID as nVarchar) + N';' + Cast(#temp.BeatID as nVarchar),  
  "Beat" = IsNull(Beat.Description, N'Others'),   
  "Salesman" = IsNull(Salesman.Salesman_Name,N'Others'), 
  "DsType" = dbo.fn_Get_DSTypeBySalesManId(Salesman.SalesmanID)  ,
  "Net Outstanding (%c)" = SUM(Balance)  from #temp, Salesman, Beat  
 WHERE #temp.SalesmanID = Salesman.SalesmanID And  
 #temp.BeatID = Beat.BeatID  
 Group By #temp.SalesmanID, Salesman.Salesman_Name, #temp.BeatID, Beat.Description  
END    
DROP TABLE #temp 
DROP TABLE #tmpBeat  
DROP TABLE #tmpSalesMan






