CREATE PROCEDURE spr_get_beatwise_balance    
--(@fromDate datetime,@toDate datetime)        
as        
Declare @One As Datetime    
Declare @Seven As Datetime    
Declare @Eight As Datetime    
Declare @Ten As Datetime    
Declare @Eleven As Datetime    
Declare @Fourteen As Datetime    
Declare @Fifteen As Datetime    
Declare @TwentyOne As Datetime    
Declare @TwentyTwo As Datetime    
Declare @Thirty As Datetime    
Declare @ThirtyOne As Datetime    
Declare @Sixty As Datetime    
Declare @SixtyOne As Datetime    
Declare @Ninety As Datetime    
Declare @OpeningDate as datetime    
Declare @OTHERS as NVarchar(50)

Set dateformat dmy    
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
    
Set @One = Cast(Datepart(dd, GetDate()) As nvarchar) + N'/' +    
Cast(Datepart(mm, GetDate()) As nvarchar) + N'/' +    
Cast(Datepart(yyyy, GetDate()) As nvarchar)    
Set @Seven = DateAdd(d, -7, @One)    
Set @Eight = DateAdd(d, -1, @Seven)    
Set @Ten = DateAdd(d, -2, @Eight)    
Set @Eleven = DateAdd(d, -1, @Ten)    
Set @Fourteen = DateAdd(d, -3, @Eleven)    
Set @Fifteen = DateAdd(d, -1, @Fourteen)    
Set @TwentyOne = DateAdd(d, -6, @Fifteen)    
Set @TwentyTwo = DateAdd(d, -1, @TwentyOne)    
Set @Thirty = DateAdd(d, -8, @TwentyTwo)    
Set @ThirtyOne = DateAdd(d, -1, @Thirty)    
Set @Sixty = DateAdd(d, -29, @ThirtyOne)    
Set @SixtyOne = DateAdd(d, -1, @Sixty)    
Set @Ninety = DateAdd(d, -29, @SixtyOne)    
Select @OpeningDate = OpeningDate From Setup    
    
Set @One = dbo.MakeDayEnd(@One)    
Set @Eight = dbo.MakeDayEnd(@Eight)    
Set @Eleven = dbo.MakeDayEnd(@Eleven)    
Set @Fifteen = dbo.MakeDayEnd(@Fifteen)    
Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)    
Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)    
Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)    
    
create table #tempbeat(BeatID int, Description nvarchar(128))    
insert into #tempbeat values(0, @OTHERS)    
    
insert into #tempbeat     
select BeatID, Description From beat    
    
select #tempbeat.BeatID, "Beat" = #tempbeat.Description,         
"Total Outstanding (%c)" = ( ISNULL((Select sum(Balance)From InvoiceAbstract Where        
         IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
         --InvoiceAbstract.InvoiceDate between @FROMDATE AND @TODATE and    
         InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
--InvoiceAbstract.InvoiceDate between @FROMDATE AND @TODATE and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
    
    
- Isnull(    
  (select sum(Balance) From Creditnote,Customer where      
   IsNull((Select Beatid From Beat_Salesman Where CustomerID = CreditNote.CustomerID) ,0) = #tempBeat.Beatid and    
   CreditNote.CustomerID Is Not Null  And CreditNote.CustomerID <> N''    
   And CreditNote.CustomerId =Customer.Customerid    
   And Customer.CustomerCategory in (1,2,3)  
  
  
) , 0)    
    
    
    
+  IsNull((select sum(Balance) From Debitnote ,Customer where      
  IsNull((Select Beatid From Beat_Salesman     
   where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
--Debitnote.Documentdate between @FROMDATE AND @TODATE And     
  DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''    
  And debitNote.CustomerId =Customer.Customerid    
  And Customer.CustomerCategory in (1,2,3) ), 0)    
    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
--Collections.DocumentDate Between @FromDate And @ToDate And    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0    
And Collections.Customerid=Customer.Customerid    
And Customer.CustomerCategory in (1,2,3) ), 0)    
    
,    
"1-7 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Seven AND @One and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Seven AND @One and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where     IsNull((Select Beatid From Beat_Salesman     
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate between @Seven AND @One and     
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate between @Seven AND @One and     
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And debitNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
  
), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate between @Seven AND @One and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0),    
"8-10 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Ten AND @Eight and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Ten AND @Eight and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where       
IsNull((Select Beatid From Beat_Salesman     
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate between @Ten AND @Eight and     
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)   
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate between @Ten AND @Eight and     
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And DebitNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate between @Ten AND @Eight and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0),    
"11-14 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Fourteen AND @Eleven and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Fourteen AND @Eleven and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where       
IsNull((Select Beatid From Beat_Salesman  
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate between @Fourteen AND @Eleven and     
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate between @Fourteen AND @Eleven and     
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And debitNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate between @Fourteen AND @Eleven and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0),    
"15-21 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate between @TwentyOne AND @Fifteen and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate between @TwentyOne AND @Fifteen and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where       
IsNull((Select Beatid From Beat_Salesman     
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate between @TwentyOne AND @Fifteen and     
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate between @TwentyOne AND @Fifteen and     
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And debitNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate between @TwentyOne AND @Fifteen and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
  
), 0),    
"22-30 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Thirty AND @TwentyTwo and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Thirty AND @TwentyTwo and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where       
IsNull((Select Beatid From Beat_Salesman     
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate between @Thirty AND @TwentyTwo and     
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate between @Thirty AND @TwentyTwo and     
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And debitNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate between @Thirty AND @TwentyTwo and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)   
), 0),    
"<30 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate > @Thirty and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate > @Thirty and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where       
IsNull((Select Beatid From Beat_Salesman     
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate > @Thirty and     
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate > @Thirty and     
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And Debitnote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate > @Thirty and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0),    
"31-60 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Sixty And @ThirtyOne and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Sixty And @ThirtyOne and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where       
IsNull((Select Beatid From Beat_Salesman     
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate between @Sixty And @ThirtyOne and     
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate between @Sixty And @ThirtyOne and     
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And debitNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate between @Sixty And @ThirtyOne and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0),    
"61-90 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Ninety And @SixtyOne and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate between @Ninety And @SixtyOne and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where       
IsNull((Select Beatid From Beat_Salesman     
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate between @Ninety And @SixtyOne and    
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate between @Ninety And @SixtyOne and    
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And Debitnote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate between @Ninety And @SixtyOne and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0),    
"<90 Days" = (ISNULL((Select sum(Balance)From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempbeat.BeatID And        
InvoiceAbstract.InvoiceDate between @OpeningDate And @Ninety and    
InvoiceType in (1, 3) And  (Status & 128) = 0) ,0)       
- ISNULL((Select Sum(Balance) From InvoiceAbstract Where        
IsNull(InvoiceAbstract.BeatID,0) = #tempBeat.BeatID And        
InvoiceAbstract.InvoiceDate between @OpeningDate And @Ninety and    
InvoiceType = 4 And  (Status & 128) = 0), 0))         
- Isnull((select sum(Balance) From Creditnote,Customer where       
IsNull((Select Beatid From Beat_Salesman     
Where CustomerID = CreditNote.CustomerID),0) = #tempBeat.Beatid and    
Creditnote.Documentdate between @OpeningDate And @Ninety and    
CreditNote.CustomerID Is Not Null And CreditNote.CustomerID <> N''  
And CreditNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)      
+  IsNull((select sum(Balance) From Debitnote,Customer where      
IsNull((Select Beatid From Beat_Salesman     
where CustomerID = DebitNote.CustomerID),0) = #tempBeat.Beatid and    
Debitnote.Documentdate between @OpeningDate And @Ninety and    
DebitNote.CustomerID Is Not Null And DebitNote.CustomerID <> N''  
And DebitNote.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)    
- IsNull((Select Sum(Balance) From Collections,Customer Where    
IsNull(Collections.BeatID,0) = #tempBeat.BeatID And    
Collections.DocumentDate between @OpeningDate And @Ninety and    
IsNull(Collections.Status, 0) & 128 = 0 And    
Collections.Balance > 0  
And Collections.Customerid=Customer.customerid  
and Customer.customercategory in (1,2,3)  
), 0)    
From #tempBeat        
Order By #tempbeat.beatid,#tempbeat.description     
drop table #tempbeat    
    
    
  


