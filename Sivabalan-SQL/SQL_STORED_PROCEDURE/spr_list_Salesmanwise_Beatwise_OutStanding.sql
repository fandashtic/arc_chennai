CREATE procedure [dbo].[spr_list_Salesmanwise_Beatwise_OutStanding](@Beat nvarchar(255),      
           @Salesman nvarchar(255),      
           @FromDate datetime,      
           @ToDate datetime)      
as      
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)

create table #temp      
(      
 SalesmanID int not null,      
 BeatID int not null,      
 Balance Decimal(18,6) not null,      
 CustomerID nvarchar(15) not null      
)     
     
IF (@SALESMAN = '%') And (@Beat = '%')       
Begin    
 insert into #temp      
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),       
 ISNULL(Sum(Balance), 0), CustomerID      
 from InvoiceAbstract, Beat, Salesman      
 where InvoiceAbstract.Status & 128 = 0 and      
 InvoiceAbstract.Balance > 0 and      
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.InvoiceDate between @FromDate AND @ToDate And      
 InvoiceAbstract.BeatID *= Beat.BeatID And       
 Beat.Description like @SALESMAN And      
 IsNull(InvoiceAbstract.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Beat    
 group by IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
 InvoiceAbstract.CustomerID      
    
 insert into #temp      
 select  IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
  0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID      
 FROM InvoiceAbstract, Beat, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND      
 (Status & 128) = 0 AND      
 InvoiceDate Between @FromDate AND @ToDate And      
 InvoiceAbstract.BeatID *= Beat.BeatID And      
 Beat.Description like @Beat And      
 IsNull(InvoiceAbstract.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 insert into #temp      
 SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Beat, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 Collections.BeatID *= Beat.BeatID And      
 Beat.Description like @Beat And      
 IsNull(Collections.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman

 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
  IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = CreditNote.CustomerID), 0),       
  0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote, Salesman      
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman, Beat Where Beat_Salesman.BeatID *= Beat.BeatID And CustomerID = CreditNote.CustomerID), '%') like @Beat And      
 IsNull(CreditNote.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman, Beat Where Beat_Salesman.BeatID *= Beat.BeatID And CustomerID = DebitNote.CustomerID), '%') like @Beat And      
 IsNull(DebitNote.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 select  cast(#temp.SalesmanID as nvarchar) + ';' + cast(#temp.BeatID as nvarchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS),       
  "Beat" = IsNull(Beat.Description, @OTHERS),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp, Salesman, Beat      
 WHERE #temp.SalesmanID *= Salesman.SalesmanID And #temp.BeatID *= Beat.BeatID      
 Group By #temp.SalesmanID, #temp.BeatID, Salesman.Salesman_Name, Beat.Description      
End    
ELSE IF (@SALESMAN = '%') And (@Beat <> '%')        
Begin    
 insert into #temp      
 select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),       
 ISNULL(Sum(Balance), 0), CustomerID      
 from InvoiceAbstract, Beat, Salesman      
 where InvoiceAbstract.Status & 128 = 0 and      
 InvoiceAbstract.Balance > 0 and      
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.InvoiceDate between @FromDate AND @Todate And      
 InvoiceAbstract.BeatID = Beat.BeatID And       
 Beat.Description like @Beat And      
 IsNull(InvoiceAbstract.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @SALESMAN    
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
 Beat.Description like @Beat And      
 IsNull(InvoiceAbstract.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 insert into #temp      
 SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Beat, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 Collections.BeatID = Beat.BeatID And      
 Beat.Description like @Beat And      
 IsNull(Collections.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman
       
 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
  IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = CreditNote.CustomerID), 0),       
  0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote, Salesman      
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman, Beat Where Beat_Salesman.BeatID = Beat.BeatID And CustomerID = CreditNote.CustomerID), '%') like @Beat And      
 IsNull(CreditNote.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman, Beat Where Beat_Salesman.BeatID = Beat.BeatID And CustomerID = DebitNote.CustomerID), '%') like @Beat And      
 IsNull(DebitNote.SalesmanID, 0) *= Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 select  cast(#temp.SalesmanID as nvarchar) + ';' + cast(#temp.BeatID as nvarchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS),       
  "Beat" = IsNull(Beat.Description, @OTHERS),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp, Salesman, Beat      
 WHERE #temp.SalesmanID *= Salesman.SalesmanID And #temp.BeatID = Beat.BeatID      
 Group By #temp.SalesmanID, #temp.BeatID, Salesman.Salesman_Name, Beat.Description      
End    
ELSE IF (@SALESMAN <> '%') And (@Beat = '%')  
Begin    
insert into #temp    
select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),       
 ISNULL(Sum(Balance), 0), CustomerID      
 from InvoiceAbstract, Beat, Salesman      
 where InvoiceAbstract.Status & 128 = 0 and      
 InvoiceAbstract.Balance > 0 and    
 InvoiceAbstract.InvoiceType in (1, 3) and      
 InvoiceAbstract.InvoiceDate between @FromDate AND @ToDate And      
 InvoiceAbstract.BeatID *= Beat.BeatID And       
 Beat.Description like @Beat And      
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @SALESMAN    
 group by IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
 InvoiceAbstract.CustomerID      
  
insert into #temp      
 select  IsNull(InvoiceAbstract.SalesmanID,0), IsNull(InvoiceAbstract.BeatID, 0),       
  0 - ISNULL(InvoiceAbstract.Balance, 0), CustomerID      
 FROM InvoiceAbstract, Beat, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 and InvoiceType = 4 AND      
 (Status & 128) = 0 AND      
 InvoiceDate Between @FromDate AND @Todate And      
 InvoiceAbstract.BeatID *= Beat.BeatID And      
 Beat.Description like @Beat And      
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @SALESMAN      
       
 insert into #temp      
 SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Beat, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 Collections.BeatID *= Beat.BeatID And      
 Beat.Description like @Beat And      
 IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman
       
 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
  IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = CreditNote.CustomerID), 0),       
  0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote, Salesman      
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman, Beat Where Beat_Salesman.BeatID *= Beat.BeatID And CustomerID = CreditNote.CustomerID), '%') like @Beat And      
 IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman, Beat Where Beat_Salesman.BeatID *= Beat.BeatID And CustomerID = DebitNote.CustomerID), '%') like @Beat And      
 IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 select  cast(#temp.SalesmanID as nvarchar) + ';' + cast(#temp.BeatID as nvarchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS),       
  "Beat" = IsNull(Beat.Description, @OTHERS),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp, Salesman, Beat      
 WHERE #temp.SalesmanID = Salesman.SalesmanID And #temp.BeatID *= Beat.BeatID      
 Group By #temp.SalesmanID, #temp.BeatID, Salesman.Salesman_Name, Beat.Description      
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
  Beat.Description like @Beat And      
  IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And      
  Salesman.Salesman_Name like @SALESMAN    
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
 Beat.Description like @Beat And      
 IsNull(InvoiceAbstract.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 insert into #temp      
 SELECT  IsNull(Collections.SalesmanID,0), IsNull(Collections.BeatID, 0),       
  0 - ISNULL(Balance, 0), CustomerID FROM Collections, Beat, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate And      
 Collections.BeatID = Beat.BeatID And      
 Beat.Description like @Beat And      
 IsNull(Collections.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman
       
 insert into #temp       
 SELECT  IsNull(CreditNote.SalesmanID,0),       
  IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = CreditNote.CustomerID), 0),       
  0 - ISNULL(Balance, 0), CreditNote.CustomerID       
 FROM CreditNote, Salesman      
 WHERE   ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 CreditNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman, Beat Where Beat_Salesman.BeatID = Beat.BeatID And CustomerID = CreditNote.CustomerID), '%') like @Beat And      
 IsNull(CreditNote.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 insert into #temp       
 SELECT  IsNull(DebitNote.SalesmanID,0), IsNull((select Beat_Salesman.BeatID From Beat_Salesman Where CustomerID = DebitNote.CustomerID), 0),       
  ISNULL(Balance, 0), DebitNote.CustomerID       
 FROM DebitNote, Salesman      
 WHERE  ISNULL(Balance, 0) > 0 AND       
 DocumentDate Between @FromDate AND @ToDate AND      
 DebitNote.CustomerID IS NOT NULL And       
 IsNull((Select Beat.Description From Beat_Salesman, Beat Where Beat_Salesman.BeatID = Beat.BeatID And CustomerID = DebitNote.CustomerID), '%') like @Beat And      
 IsNull(DebitNote.SalesmanID, 0) = Salesman.SalesmanID And      
 Salesman.Salesman_Name like @Salesman      
       
 select  cast(#temp.SalesmanID as nvarchar) + ';' + cast(#temp.BeatID as nvarchar),       
  "Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS),       
  "Beat" = IsNull(Beat.Description, @OTHERS),       
  "Net Outstanding (%c)" = SUM(Balance)        
 from #temp, Salesman, Beat      
 WHERE #temp.SalesmanID = Salesman.SalesmanID And #temp.BeatID = Beat.BeatID      
 Group By #temp.SalesmanID, #temp.BeatID, Salesman.Salesman_Name, Beat.Description      
 End    
    
drop table #temp
