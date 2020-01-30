CREATE procedure [dbo].[spr_list_SMCustomer_OutStanding](  @Beat nvarchar(255),   
         @Salesman nvarchar(255),  
         @FromDate datetime,  
         @ToDate datetime)  
as

Declare @OTHERS As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
  
create table #temp  
 (  
  SalesmanID int not null,  
  BeatID int not null,  
  Balance Decimal(18,6) not null,  
  CustomerID nvarchar(15) not null  
 )  
  
IF (@SALESMAN = '%') And (@Beat = '%')     
BEGIN  
   
 insert into #temp  
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 from InvoiceAbstract, Beat, Salesman  
 where InvoiceAbstract.Status & 128 = 0 and  
 InvoiceAbstract.Balance > 0 and  
 InvoiceAbstract.InvoiceType in (1, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) *= Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(InvoiceAbstract.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman  
 group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 FROM InvoiceAbstract, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND  
 (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) *= Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(InvoiceAbstract.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman  
 Group By InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),   
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate And  
 IsNull(Collections.BeatID, 0) *= Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(Collections.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman
   
 insert into #temp   
 SELECT  ISNULL(CreditNote.SalesmanID, 0),    
 IsNull((select Beat_Salesman.BeatID From Beat_Salesman   
 Where CustomerID = CreditNote.CustomerID), 0),   
 0 - ISNULL(Balance, 0), CustomerID   
 FROM CreditNote, Salesman  
 WHERE   ISNULL(Balance, 0) > 0 AND   
 DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(CreditNote.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman And  
 IsNull((Select Beat.Description From Beat_Salesman, Beat   
 Where Beat_Salesman.BeatID *= Beat.BeatID And   
 CustomerID = CreditNote.CustomerID), '%') like @Beat  
   
 insert into #temp   
 SELECT ISNULL(DebitNote.SalesmanID, 0),   
 IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where   
 CustomerID = DebitNote.CustomerID), 0),   
 ISNULL(Balance, 0), CustomerID FROM DebitNote, Salesman  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(DebitNote.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman And  
 IsNull((Select Beat.Description From Beat_Salesman, Beat   
 Where Beat_Salesman.BeatID *= Beat.BeatID And   
 CustomerID = DebitNote.CustomerID), '%') like @Beat   
   
 select Cast(#temp.SalesmanID as nvarchar) + ';' + Cast(#temp.BeatID as nvarchar),  
  "Beat" = IsNull(Beat.Description, @OTHERS),   
  "Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS),   
  "Net Outstanding (%c)" = SUM(Balance)  from #temp, Salesman, Beat  
 WHERE #temp.SalesmanID *= Salesman.SalesmanID And  
 #temp.BeatID *= Beat.BeatID  
 Group By #temp.SalesmanID, Salesman.Salesman_Name, #temp.BeatID, Beat.Description  
END  
ELSE IF (@SALESMAN = '%') And (@Beat <> '%')     
BEGIN  
 insert into #temp  
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 from InvoiceAbstract, Beat, Salesman  
 where InvoiceAbstract.Status & 128 = 0 and  
 InvoiceAbstract.Balance > 0 and  
 InvoiceAbstract.InvoiceType in (1, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(InvoiceAbstract.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman  
 group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 FROM InvoiceAbstract, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND  
 (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(InvoiceAbstract.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman  
 Group By InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),   
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate And  
 IsNull(Collections.BeatID, 0) = Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(Collections.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman
   
 insert into #temp   
 SELECT  ISNULL(CreditNote.SalesmanID, 0),    
 IsNull((select Beat_Salesman.BeatID From Beat_Salesman   
 Where CustomerID = CreditNote.CustomerID), 0),   
 0 - ISNULL(Balance, 0), CustomerID   
 FROM CreditNote, Salesman  
 WHERE   ISNULL(Balance, 0) > 0 AND   
 DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(CreditNote.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman And  
 IsNull((Select Beat.Description From Beat_Salesman, Beat   
 Where Beat_Salesman.BeatID = Beat.BeatID And   
 CustomerID = CreditNote.CustomerID), '%') like @Beat  
   
 insert into #temp   
 SELECT ISNULL(DebitNote.SalesmanID, 0),   
 IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where   
 CustomerID = DebitNote.CustomerID), 0),   
 ISNULL(Balance, 0), CustomerID FROM DebitNote, Salesman  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(DebitNote.SalesmanID, 0) *= Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman And  
 IsNull((Select Beat.Description From Beat_Salesman, Beat   
 Where Beat_Salesman.BeatID = Beat.BeatID And   
 CustomerID = DebitNote.CustomerID), '%') like @Beat   
   
 select Cast(#temp.SalesmanID as nvarchar) + ';' + Cast(#temp.BeatID as nvarchar),  
  "Beat" = IsNull(Beat.Description, @OTHERS),   
  "Salesman" = IsNull(Salesman.Salesman_Name,@OTHERS),   
  "Net Outstanding (%c)" = SUM(Balance)  from #temp, Salesman, Beat  
 WHERE #temp.SalesmanID *= Salesman.SalesmanID And  
 #temp.BeatID = Beat.BeatID  
 Group By #temp.SalesmanID, Salesman.Salesman_Name, #temp.BeatID, Beat.Description  
END  
ELSE IF (@SALESMAN <> '%') And (@Beat = '%')  
BEGIN  
 insert into #temp  
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 from InvoiceAbstract, Beat, Salesman  
 where InvoiceAbstract.Status & 128 = 0 and  
 InvoiceAbstract.Balance > 0 and  
 InvoiceAbstract.InvoiceType in (1, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) *= Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman  
 group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 FROM InvoiceAbstract, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND  
 (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) *= Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman  
 Group By InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),   
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate And  
 IsNull(Collections.BeatID, 0) *= Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman
   
 insert into #temp   
 SELECT  ISNULL(CreditNote.SalesmanID, 0),    
 IsNull((select Beat_Salesman.BeatID From Beat_Salesman   
 Where CustomerID = CreditNote.CustomerID), 0),   
 0 - ISNULL(Balance, 0), CustomerID   
 FROM CreditNote, Salesman  
 WHERE   ISNULL(Balance, 0) > 0 AND   
 DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman And  
 IsNull((Select Beat.Description From Beat_Salesman, Beat   
 Where Beat_Salesman.BeatID *= Beat.BeatID And   
 CustomerID = CreditNote.CustomerID), '%') like @Beat  
   
 insert into #temp   
 SELECT ISNULL(DebitNote.SalesmanID, 0),   
 IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where   
 CustomerID = DebitNote.CustomerID), 0),   
 ISNULL(Balance, 0), CustomerID FROM DebitNote, Salesman  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman And  
 IsNull((Select Beat.Description From Beat_Salesman, Beat   
 Where Beat_Salesman.BeatID *= Beat.BeatID And   
 CustomerID = DebitNote.CustomerID), '%') like @Beat   
   
 select Cast(#temp.SalesmanID as nvarchar) + ';' + Cast(#temp.BeatID as nvarchar),  
  "Beat" = IsNull(Beat.Description, @OTHERS),   
  "Salesman" = IsNull(Salesman.Salesman_Name,@OTHERS),   
  "Net Outstanding (%c)" = SUM(Balance)  from #temp, Salesman, Beat  
 WHERE #temp.SalesmanID = Salesman.SalesmanID And  
 #temp.BeatID *= Beat.BeatID  
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
 InvoiceAbstract.InvoiceType in (1, 3) and  
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman  
 group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),   
  0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID  
 FROM InvoiceAbstract, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND  
 (Status & 128) = 0 AND  
 InvoiceDate Between @FromDate AND @ToDate And  
 IsNull(InvoiceAbstract.BeatID, 0) = Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman  
 Group By InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID, InvoiceAbstract.CustomerID  
   
 insert into #temp  
 SELECT ISNULL(Collections.SalesmanID, 0), IsNull(Collections.BeatID, 0),   
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Salesman, Beat  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate And  
 IsNull(Collections.BeatID, 0) = Beat.BeatID And  
 Beat.Description like @Beat And  
 IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman
   
 insert into #temp   
 SELECT  ISNULL(CreditNote.SalesmanID, 0),    
 IsNull((select Beat_Salesman.BeatID From Beat_Salesman   
 Where CustomerID = CreditNote.CustomerID), 0),   
 0 - ISNULL(Balance, 0), CustomerID   
 FROM CreditNote, Salesman  
 WHERE   ISNULL(Balance, 0) > 0 AND   
 DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman And  
 IsNull((Select Beat.Description From Beat_Salesman, Beat   
 Where Beat_Salesman.BeatID = Beat.BeatID And   
 CustomerID = CreditNote.CustomerID), '%') like @Beat  
   
 insert into #temp   
 SELECT ISNULL(DebitNote.SalesmanID, 0),   
 IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where   
 CustomerID = DebitNote.CustomerID), 0),   
 ISNULL(Balance, 0), CustomerID FROM DebitNote, Salesman  
 WHERE ISNULL(Balance, 0) > 0 AND DocumentDate Between @FromDate AND @ToDate AND  
 CustomerID IS NOT NULL And  
 IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID And  
 Salesman.Salesman_Name like @Salesman And  
 IsNull((Select Beat.Description From Beat_Salesman, Beat   
 Where Beat_Salesman.BeatID = Beat.BeatID And   
 CustomerID = DebitNote.CustomerID), '%') like @Beat   
   
 select Cast(#temp.SalesmanID as nvarchar) + ';' + Cast(#temp.BeatID as nvarchar),  
  "Beat" = IsNull(Beat.Description, @OTHERS),   
  "Salesman" = IsNull(Salesman.Salesman_Name,@OTHERS),   
  "Net Outstanding (%c)" = SUM(Balance)  from #temp, Salesman, Beat  
 WHERE #temp.SalesmanID = Salesman.SalesmanID And  
 #temp.BeatID = Beat.BeatID  
 Group By #temp.SalesmanID, Salesman.Salesman_Name, #temp.BeatID, Beat.Description  
END    
DROP TABLE #temp
