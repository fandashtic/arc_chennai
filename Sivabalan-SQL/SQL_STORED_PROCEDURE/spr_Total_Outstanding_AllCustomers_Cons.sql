CREATE procedure spr_Total_Outstanding_AllCustomers_Cons    
(    
 @Dummy NVarChar(50),    
 @FromDateBh DateTime,    
 @ToDateBh DateTime    
)      
As      
 Declare @FromDate DateTime    
 Declare @ToDate DateTime    
 Set @FromDate = dbo.StripDateFromTime(@FromDateBh)          
 Set @ToDate = dbo.StripDateFromTime(@ToDateBh)        
    
 Declare  @CIDRpt As NVarChar(50)    
 Declare  @CIDSetUp As NVarChar(50)    
    
 Select @CIDSetUp=RegisteredOwner From Setup     
 Select @CIDRpt=Right(@Dummy,Len(@CIDSetUp))    
    
 If @CIDRpt <> @CIDSetUp    
  Begin    
   Select    
    Field1, "CustomerId" = Field1, "Customer" =  Field2,"No. Of Documents" = Field3,    
    "OutStanding Value (%c)" = Field4,"1-7 Days" = Field5, "8-10 Days" = Field6,    
    "11-14 Days" =Field7, "15-21 Days" = Field8,"22-30 Days" = Field9,     
    "<30 Days" = Field10,"31-60 Days" = Field11,"61-90 Days" = Field12,">90 Days" = Field13      
   From    
    ReportDetailReceived RDR,Reports    
   Where    
    Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Outstanding - Total'     
    And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Outstanding - Total') Where dbo.StripDateFromTime(FromDate) = @FromDate And dbo.StripDateFromTime(ToDate) = @ToDate))    
--    And Reports.Companyid = 'PKP015'    
    And RDR.RecordID=@Dummy    
    And RDR.Field1 <> N'CustomerID' And RDR.Field1 <> N'SubTotal:' And RDR.Field1 <> N'GrandTotal:'      
  End    
 Else    
  Begin    
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
         
   Set @One = Cast(Datepart(dd, GetDate()) As NVarChar) + N'/' +      
   Cast(Datepart(mm, GetDate()) As NVarChar) + N'/' +      
   Cast(Datepart(yyyy, GetDate()) As NVarChar)      
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
         
   Set @One = dbo.MakeDayEnd(@One)      
   Set @Eight = dbo.MakeDayEnd(@Eight)      
   Set @Eleven = dbo.MakeDayEnd(@Eleven)      
   Set @Fifteen = dbo.MakeDayEnd(@Fifteen)      
   Set @TwentyTwo = dbo.MakeDayEnd(@TwentyTwo)      
   Set @ThirtyOne = dbo.MakeDayEnd(@ThirtyOne)      
   Set @SixtyOne = dbo.MakeDayEnd(@SixtyOne)      
         
   Create Table #Temp     
   (    
    CustomerId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,       
    DocCount Int Null,       
    Value Decimal(18,6)Null,      
    OnetoSeven Decimal(18,6) Null,      
    EighttoTen Decimal(18,6) Null,      
    EleventoFourteen Decimal(18,6) Null,      
    FifteentoTwentyOne Decimal(18,6) Null,      
    TwentyTwotoThirty Decimal(18,6) Null,      
    LessthanThirty Decimal(18,6) Null,      
    ThirtyOnetoSixty Decimal(18,6) Null,      
    SixtyOnetoNinety Decimal(18,6) Null,      
    MorethanNinety Decimal(18,6) Null    
   )      
         
   Insert #Temp    
   (    
    CustomerId, DocCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,FifteentoTwentyOne,    
    TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,SixtyOnetoNinety, MorethanNinety    
   )      
       
   Select     
       
    InvoiceAbstract.CustomerId,      
        
    Count(InvoiceID),       
        
    Sum( Case InvoiceAbstract.InvoiceType       
    When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))       
    When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))       
    When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))       
    Else IsNull(InvoiceAbstract.Balance, 0) End),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then  0 - IsNull(Inv.Balance, 0)       
    When 5 Then  0 - IsNull(Inv.Balance, 0)       
    When 6 Then  0 - IsNull(Inv.Balance, 0)       
    Else IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
     dbo.StripDateFromTime(Inv.InvoiceDate) Between @Seven And @One And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
        
    Inv.Status & 128 = 0),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then 0 - IsNull(Inv.Balance, 0)       
    When 5 Then 0 - IsNull(Inv.Balance, 0)       
    When 6 Then 0 - IsNull(Inv.Balance, 0)       
    Else      
    IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
     dbo.StripDateFromTime(Inv.InvoiceDate) Between @Ten And @Eight And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
    Inv.Status & 128 = 0),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then 0 - IsNull(Inv.Balance, 0)       
    When 5 Then 0 - IsNull(Inv.Balance, 0)       
    When 6 Then 0 - IsNull(Inv.Balance, 0)       
    Else      
    IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
     dbo.StripDateFromTime(Inv.InvoiceDate) Between @Fourteen And @Eleven And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
    Inv.Status & 128 = 0),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then  0 - IsNull(Inv.Balance, 0)       
    When 5 Then  0 - IsNull(Inv.Balance, 0)       
    When 6 Then  0 - IsNull(Inv.Balance, 0)       
    Else IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
    dbo.StripDateFromTime(Inv.InvoiceDate) Between @TwentyOne And @Fifteen And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
    Inv.Status & 128 = 0),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then 0 - IsNull(Inv.Balance, 0)       
    When 5 Then 0 - IsNull(Inv.Balance, 0)       
    When 6 Then 0 - IsNull(Inv.Balance, 0)       
    Else      
    IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
    dbo.StripDateFromTime(Inv.InvoiceDate) Between @Thirty And @TwentyTwo And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
    Inv.Status & 128 = 0),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then 0 - IsNull(Inv.Balance, 0)       
    When 5 Then 0 - IsNull(Inv.Balance, 0)       
    When 6 Then 0 - IsNull(Inv.Balance, 0)       
    Else      
    IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
     dbo.StripDateFromTime(Inv.InvoiceDate) > @Thirty And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
    Inv.Status & 128 = 0),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then 0 - IsNull(Inv.Balance, 0)       
    When 5 Then 0 - IsNull(Inv.Balance, 0)       
    When 6 Then 0 - IsNull(Inv.Balance, 0)       
    Else      
    IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
    dbo.StripDateFromTime(Inv.InvoiceDate) Between @Sixty And @ThirtyOne And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
    Inv.Status & 128 = 0),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then 0 - IsNull(Inv.Balance, 0)       
    When 5 Then 0 - IsNull(Inv.Balance, 0)       
    When 6 Then 0 - IsNull(Inv.Balance, 0)       
    Else      
    IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
    dbo.StripDateFromTime(Inv.InvoiceDate) Between @Ninety And @SixtyOne And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
    Inv.Status & 128 = 0),      
        
    (Select Sum(Case Inv.InvoiceType      
    When 4 Then 0 - IsNull(Inv.Balance, 0)       
    When 5 Then 0 - IsNull(Inv.Balance, 0)       
    When 6 Then 0 - IsNull(Inv.Balance, 0)       
    Else IsNull(Inv.Balance, 0)       
    End) From InvoiceAbstract As Inv      
    Where Inv.CustomerId = InvoiceAbstract.CustomerId And      
     dbo.StripDateFromTime(Inv.InvoiceDate) < @Ninety And      
    Inv.Balance > 0 And      
    Inv.InvoiceType In (1, 2, 3, 4, 5, 6) And      
    Inv.Status & 128 = 0)      
   From     
    InvoiceAbstract      
   Where     
     dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @FromDate and    
     dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @ToDate and      
    InvoiceAbstract.Balance > 0 and       
    InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) and      
    InvoiceAbstract.Status & 128 = 0      
   Group By     
    InvoiceAbstract.CustomerId      
         
   Insert #Temp    
   (    
    CustomerId, DocCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,FifteentoTwentyOne,    
    TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,SixtyOnetoNinety, MorethanNinety    
   )      
       
   Select     
    CreditNote.CustomerId,       
       
    Count(CreditID),       
       
    0 - Sum(CreditNote.Balance),      
       
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate Between @Seven And @One And      
    Cr.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate Between @Ten And @Eight And      
    Cr.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate Between @Fourteen And @Eleven And      
    Cr.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate Between @TwentyOne And @Fifteen And      
    Cr.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate Between @Thirty And @TwentyTwo And      
    Cr.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate > @Thirty And      
    Cr.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate Between @Sixty And @ThirtyOne And      
    Cr.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate Between @Ninety And @SixtyOne And      
    Cr.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Cr.Balance), 0) From CreditNote As Cr      
    Where Cr.CustomerId = CreditNote.CustomerId And      
    Cr.DocumentDate < @Ninety And      
    Cr.Balance > 0)      
   From     
    CreditNote      
   Where     
    CreditNote.CustomerId is not Null and      
    CreditNote.Balance > 0  and      
    dbo.StripDateFromTime(CreditNote.DocumentDate) = @FromDate and    
    dbo.StripDateFromTime(CreditNote.DocumentDate) = @ToDate       
   Group By     
    CreditNote.CustomerId        
         
   Insert #Temp    
   (    
    CustomerId, DocCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,FifteentoTwentyOne,    
    TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,SixtyOnetoNinety, MorethanNinety    
   )      
   Select     
    DebitNote.CustomerId,     
         
    Count(DebitID),       
       
    Sum(DebitNote.Balance),      
       
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate Between @Seven And @One And      
    Db.balance > 0),      
        
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate Between @Ten And @Eight And      
    Db.balance > 0),      
        
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate Between @Fourteen And @Eleven And      
    Db.balance > 0),      
        
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate Between @TwentyOne And @Fifteen And      
    Db.balance > 0),      
        
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate Between @Thirty And @TwentyTwo And      
    Db.balance > 0),      
        
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate > @Thirty And      
    Db.balance > 0),      
        
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate Between @Sixty And @ThirtyOne And      
    Db.balance > 0),      
        
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate Between @Ninety And @SixtyOne And      
    Db.balance > 0),      
        
    (Select IsNull(Sum(Db.Balance), 0) From DebitNote As Db      
    Where Db.CustomerId = DebitNote.CustomerId And      
    Db.DocumentDate < @Ninety And      
    Db.balance > 0)      
   From     
    DebitNote      
   Where     
    DebitNote.CustomerId is not Null and      
    DebitNote.Balance > 0  and      
    dbo.StripDateFromTime(DebitNote.DocumentDate) = @FromDate and     
    dbo.StripDateFromTime(DebitNote.DocumentDate) = @ToDate       
   Group By     
    DebitNote.CustomerId        
         
   Insert #Temp    
   (    
    CustomerId, DocCount, Value, OnetoSeven, EighttoTen, EleventoFourteen,FifteentoTwentyOne,    
    TwentyTwotoThirty, LessthanThirty, ThirtyOnetoSixty,SixtyOnetoNinety, MorethanNinety    
   )      
       
   Select     
    Collections.CustomerId,    
       
    Count(DocumentID),    
       
    0 - IsNull(Sum(Balance), 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate Between @Seven And @One And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate Between @Ten And @Eight And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate Between @Fourteen And @Eleven And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate Between @TwentyOne And @Fifteen And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate Between @Thirty And @TwentyTwo And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate > @Thirty And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate Between @Sixty And @ThirtyOne And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate Between @Ninety And @SixtyOne And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0),      
        
    (Select 0 - IsNull(Sum(Col.Balance), 0) From Collections As Col      
    Where Col.CustomerId = Collections.CustomerId And      
    Col.DocumentDate < @Ninety And      
    IsNull(Col.Status, 0) & 128 = 0 And      
    Col.Balance > 0)      
       
   From     
    Collections      
   Where     
    IsNull(Balance, 0) > 0 And      
    IsNull(Status, 0) & 128 = 0 And      
    dbo.StripDateFromTime(DocumentDate) = @FromDate And     
    dbo.StripDateFromTime(DocumentDate) = @ToDate      
   Group By     
    Collections.CustomerId      
         
   Select     
    #Temp.CustomerId, "CustomerId" = #Temp.CustomerId, "Customer" =  Customer.Company_Name,      
    "No. Of Documents" = Sum(DocCount), "OutStanding Value (%c)" = Sum(Value),      
    "1-7 Days" = Sum(OnetoSeven), "8-10 Days" = Sum(EighttoTen),      
    "11-14 Days" = Sum(EleventoFourteen), "15-21 Days" = Sum(FifteentoTwentyOne),      
    "22-30 Days" = Sum(TwentyTwotoThirty), "<30 Days" = Sum(LessthanThirty),      
    "31-60 Days" = Sum(ThirtyOnetoSixty),  "61-90 Days" = Sum(SixtyOnetoNinety),      
    ">90 Days" = Sum(MorethanNinety)      
   From     
    #Temp, Customer      
   Where     
    #Temp.CustomerId = Customer.CustomerId      
   Group By     
    #Temp.CustomerId,Customer.Company_Name     
   Drop Table #Temp      
 End    
  


