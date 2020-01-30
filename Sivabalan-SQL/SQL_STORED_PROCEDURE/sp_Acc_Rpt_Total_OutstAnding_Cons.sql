CREATE Procedure sp_Acc_Rpt_Total_OutstAnding_Cons  
(  
 @BranchName NVarChar(4000),   
 @FromDateBh DateTime,  
 @TodateBh DateTime  
)    
As  
  
Declare @FromDate DateTime  
Declare @ToDate DateTime  
  
Set @FromDate = dbo.StripDateFromTime(@FromDateBh)        
Set @ToDate = dbo.StripDateFromTime(@ToDateBh)        
  
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)    
  
CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)          
If @BranchName = N'%'              
 Insert InTo #TmpBranch Select DIstinct CompanyId From Reports    
Else              
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))    
     
Declare @Invoice Float    
Declare @Credit Float    
Declare @Debit Float    
Declare @Total Float    
Declare @Advance Decimal(18, 6)    
Declare @OnetoSeven Decimal(18, 6)    
Declare @EighttoTen Decimal(18, 6)    
Declare @EleventoFourteen Decimal(18, 6)    
Declare @FifteentoTwentyOne Decimal(18, 6)    
Declare @TwentyTwotoThirty Decimal(18, 6)    
Declare @LessthanThirty Decimal(18, 6)    
Declare @ThirtyOnetoSixty Decimal(18, 6)    
Declare @SixtyOnetoNinety Decimal(18, 6)    
Declare @MorethanNinety Decimal(18, 6)    
    
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
    
Set @One = Cast(Datepart(dd, GetDate()) As NVarChar) + N'/' + Cast(Datepart(mm, GetDate()) As NVarChar) + N'/' +  Cast(Datepart(yyyy, GetDate()) As NVarChar)    
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
  
Declare @CIDSetUp As NVarChar(15)  
Select @CIDSetUp=RegisteredOwner From Setup   
  
Select   
 @Invoice = Sum(  
 Case InvoiceAbstract.InvoiceType     
  When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
  When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
  When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
  Else IsNull(InvoiceAbstract.Balance, 0)   
 End)    
From   
 InvoiceAbstract    
Where     
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @FromDate And   
 dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @ToDate And  
 InvoiceAbstract.Balance > 0 And     
 InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
 InvoiceAbstract.Status & 128 = 0    
  
Select   
 @Credit = IsNull(Sum(CreditNote.Balance),0)   
From   
 CreditNote     
Where   
 CreditNote.CustomerID Is Not Null And    
 dbo.StripDateFromTime(CreditNote.DocumentDate) = @FromDate And   
 dbo.StripDateFromTime(CreditNote.DocumentDate) = @ToDate    
   
Select   
 @Debit = IsNull(Sum(DebitNote.Balance),0)   
From   
 DebitNote    
Where   
 DebitNote.CustomerID Is Not Null And    
 dbo.StripDateFromTime(DebitNote.DocumentDate) = @FromDate And   
 dbo.StripDateFromTime(DebitNote.DocumentDate) = @ToDate     
  
Select   
 @Advance = IsNull(Sum(Balance), 0)   
From   
 Collections     
Where   
 IsNull(Balance, 0) > 0   
 And (IsNull(Status, 0) & 64) = 0   
 And CustomerID Is Not Null   
 And dbo.StripDateFromTime(DocumentDate) = @FromDate   
 And dbo.StripDateFromTime(DocumentDate) = @ToDate     
    
Select @Total = IsNull(@Invoice, 0) + IsNull(@Debit, 0) - IsNull(@Credit, 0) - IsNull(@Advance, 0)    
  
Select   
 @OnetoSeven =   
  IsNull(  
  (Select Sum(  
    Case InvoiceAbstract.InvoiceType     
     When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     Else IsNull(InvoiceAbstract.Balance, 0)   
     End)    
   From   
    InvoiceAbstract    
   Where    
    InvoiceAbstract.InvoiceDate Between @Seven And @One And    
    InvoiceAbstract.Balance > 0 And     
    InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
    InvoiceAbstract.Status & 128 = 0)  
  , 0)   
  +     
  IsNull(  
  (Select   
    IsNull(Sum(DebitNote.Balance),0)   
   From   
    DebitNote    
   Where   
    DebitNote.CustomerID Is Not Null And    
    DebitNote.DocumentDate Between @Seven And @One And    
    DebitNote.customerid <> N''), 0)   
  -    
  IsNull(  
  (Select   
    IsNull(Sum(CreditNote.Balance),0)   
   From   
    CreditNote     
   Where   
    CreditNote.CustomerID Is Not Null And    
    CreditNote.DocumentDate Between @Seven And @One And    
    CreditNote.CustomerID <> N''), 0)   
  -     
  IsNull(  
  (Select   
    IsNull(Sum(Balance), 0)   
  From   
    Collections     
  Where   
    IsNull(Balance, 0) > 0 And   
    (IsNull(Status, 0) & 64) = 0 And   
    CustomerID Is Not Null And    
    DocumentDate Between @Seven And @One), 0)    
    
Select   
 @EighttoTen =   
  IsNull(  
  (Select Sum(  
    Case InvoiceAbstract.InvoiceType     
     When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     Else IsNull(InvoiceAbstract.Balance, 0)   
    End)    
   From   
    InvoiceAbstract    
   Where    
    InvoiceAbstract.InvoiceDate Between @Ten And @Eight And    
    InvoiceAbstract.Balance > 0 And     
    InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
    InvoiceAbstract.Status & 128 = 0), 0)   
  +     
  IsNull(  
  (Select   
    IsNull(Sum(DebitNote.Balance),0)   
   From   
    DebitNote    
   Where   
    DebitNote.CustomerID Is Not Null And    
    DebitNote.DocumentDate Between @Ten And @Eight And    
    DebitNote.customerid <> N''), 0)   
  -    
  IsNull(  
  (Select   
    IsNull(Sum(CreditNote.Balance),0)   
   From   
    CreditNote     
  Where   
    CreditNote.CustomerID Is Not Null And    
    CreditNote.DocumentDate Between @Ten And @Eight And    
    CreditNote.CustomerID <> N''), 0)   
  -     
  IsNull(  
  (Select   
    IsNull(Sum(Balance), 0)   
   From   
    Collections     
   Where   
    IsNull(Balance, 0) > 0 And   
    (IsNull(Status, 0) & 64) = 0 And   
    CustomerID Is Not Null And    
    DocumentDate Between @Ten And @Eight), 0)    
     
Select   
 @EleventoFourteen =   
  IsNull(  
  (Select Sum(  
    Case InvoiceAbstract.InvoiceType     
     When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     Else IsNull(InvoiceAbstract.Balance, 0)   
    End)    
   From   
    InvoiceAbstract    
   Where    
    InvoiceAbstract.InvoiceDate Between @Fourteen And @Eleven And    
    InvoiceAbstract.Balance > 0 And     
InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
    InvoiceAbstract.Status & 128 = 0), 0)   
  +     
  IsNull(  
  (Select   
    IsNull(Sum(DebitNote.Balance),0)   
   From   
    DebitNote    
   Where   
    DebitNote.CustomerID Is Not Null And    
    DebitNote.DocumentDate Between @Fourteen And @Eleven And    
    DebitNote.customerid <> N''), 0)   
  -    
  IsNull(  
  (Select   
    IsNull(Sum(CreditNote.Balance),0)   
   From   
    CreditNote     
   Where   
    CreditNote.CustomerID Is Not Null And    
    CreditNote.DocumentDate Between @Fourteen And @Eleven And    
    CreditNote.CustomerID <> N''), 0)   
  -     
  IsNull(  
  (Select   
    IsNull(Sum(Balance), 0)   
   From   
    Collections     
   Where   
    IsNull(Balance, 0) > 0 And   
    (IsNull(Status, 0) & 64) = 0 And   
    CustomerID Is Not Null And    
    DocumentDate Between @Fourteen And @Eleven), 0)    
    
Select   
 @FifteentoTwentyOne =   
  IsNull(  
  (Select Sum(  
    Case InvoiceAbstract.InvoiceType     
     When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     Else IsNull(InvoiceAbstract.Balance, 0)   
    End)    
   From   
    InvoiceAbstract    
   Where    
    InvoiceAbstract.InvoiceDate Between @TwentyOne And @Fifteen And    
    InvoiceAbstract.Balance > 0 And     
    InvoiceAbstract.InvoiceType In (1, 2, 3, 4, 5, 6) And    
    InvoiceAbstract.Status & 128 = 0), 0)   
  +     
  IsNull(  
  (Select   
    IsNull(Sum(DebitNote.Balance),0)   
   From   
    DebitNote    
   Where   
    DebitNote.CustomerID Is Not Null And    
    DebitNote.DocumentDate Between @TwentyOne And @Fifteen And    
    DebitNote.customerid <> N''), 0)   
  -    
  IsNull(  
  (Select   
    IsNull(Sum(CreditNote.Balance),0)   
   From   
    CreditNote     
   Where   
    CreditNote.CustomerID Is Not Null And    
    CreditNote.DocumentDate Between @TwentyOne And @Fifteen And    
    CreditNote.CustomerID <> N''), 0)   
  -     
  IsNull(  
  (Select   
    IsNull(Sum(Balance), 0)   
   From   
    Collections     
   Where   
    IsNull(Balance, 0) > 0 And   
    (IsNull(Status, 0) & 64) = 0 And   
    CustomerID Is Not Null And    
    DocumentDate Between @TwentyOne And @Fifteen), 0)    
    
Select   
 @TwentyTwotoThirty =   
 IsNull(  
 (Select Sum(  
   Case InvoiceAbstract.InvoiceType     
    When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    Else IsNull(InvoiceAbstract.Balance, 0)   
   End)    
  From   
   InvoiceAbstract    
  Where    
   InvoiceAbstract.InvoiceDate Between @Thirty And @TwentyTwo And    
   InvoiceAbstract.Balance > 0 And     
   InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
   InvoiceAbstract.Status & 128 = 0), 0)   
 +     
 IsNull(  
 (Select   
   IsNull(Sum(DebitNote.Balance),0)   
  From   
   DebitNote    
  Where   
   DebitNote.CustomerID Is Not Null And    
   DebitNote.DocumentDate Between @Thirty And @TwentyTwo And    
   DebitNote.customerid <> N''), 0)   
 -    
 IsNull(  
 (Select   
   IsNull(Sum(CreditNote.Balance),0)   
  From   
   CreditNote     
  Where   
   CreditNote.CustomerID Is Not Null And    
   CreditNote.DocumentDate Between @Thirty And @TwentyTwo And    
   CreditNote.CustomerID <> N''), 0)  
 -     
 IsNull(  
 (Select   
   IsNull(Sum(Balance), 0)   
  From   
   Collections     
  Where   
   IsNull(Balance, 0) > 0 And   
   (IsNull(Status, 0) & 64) = 0 And   
   CustomerID Is Not Null And    
   DocumentDate Between @Thirty And @TwentyTwo), 0)    
    
Select   
 @LessthanThirty =   
 IsNull(  
 (Select Sum(  
   Case InvoiceAbstract.InvoiceType     
    When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    Else IsNull(InvoiceAbstract.Balance, 0)  
   End)    
  From   
   InvoiceAbstract    
  Where   
   InvoiceAbstract.InvoiceDate > @Thirty And    
   InvoiceAbstract.Balance > 0 And     
   InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
   InvoiceAbstract.Status & 128 = 0), 0)   
 +     
 IsNull(  
 (Select   
   IsNull(Sum(DebitNote.Balance),0)   
  From   
   DebitNote    
  Where   
   DebitNote.CustomerID Is Not Null And    
   DebitNote.DocumentDate > @Thirty And    
   DebitNote.customerid <> N''), 0)   
 -    
 IsNull(  
 (Select   
   IsNull(Sum(CreditNote.Balance),0)   
  From   
   CreditNote     
  Where   
   CreditNote.CustomerID Is Not Null And    
  CreditNote.DocumentDate > @Thirty And    
  CreditNote.CustomerID <> N''), 0)   
 -     
 IsNull(  
 (Select   
   IsNull(Sum(Balance), 0)   
  From   
   Collections     
  Where   
   IsNull(Balance, 0) > 0 And   
   (IsNull(Status, 0) & 64) = 0 And   
   CustomerID Is Not Null And    
   DocumentDate < @Thirty), 0)    
    
Select  
 @ThirtyOnetoSixty =   
 IsNull(  
 (Select Sum(  
   Case InvoiceAbstract.InvoiceType     
    When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    Else IsNull(InvoiceAbstract.Balance, 0)   
   End)    
  From   
   InvoiceAbstract    
  Where    
   InvoiceAbstract.InvoiceDate Between @Sixty And @ThirtyOne And    
   InvoiceAbstract.Balance > 0 And     
   InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
   InvoiceAbstract.Status & 128 = 0), 0)  
 +     
 IsNull(  
 (Select   
   IsNull(Sum(DebitNote.Balance),0)   
  From   
   DebitNote    
  Where   
   DebitNote.CustomerID Is Not Null And    
   DebitNote.DocumentDate Between @Sixty And @ThirtyOne And    
   DebitNote.customerid <> N''), 0)   
 -    
 IsNull(  
 (Select   
   IsNull(Sum(CreditNote.Balance),0)   
  From   
   CreditNote     
  Where   
   CreditNote.CustomerID Is Not Null And    
   CreditNote.DocumentDate Between @Sixty And @ThirtyOne And    
   CreditNote.CustomerID <> N''), 0)   
 -     
 IsNull(  
 (Select   
   IsNull(Sum(Balance), 0)  
  From   
   Collections     
  Where   
   IsNull(Balance, 0) > 0 And   
   (IsNull(Status, 0) & 64) = 0 And   
   CustomerID Is Not Null And    
   DocumentDate Between @Sixty And @ThirtyOne), 0)    
    
Select   
 @SixtyOnetoNinety =   
 IsNull(  
 (Select Sum(  
   Case InvoiceAbstract.InvoiceType     
    When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
    Else IsNull(InvoiceAbstract.Balance, 0)   
   End)    
  From   
   InvoiceAbstract    
  Where  
   InvoiceAbstract.InvoiceDate Between @Ninety And @SixtyOne And    
   InvoiceAbstract.Balance > 0 And     
   InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
   InvoiceAbstract.Status & 128 = 0), 0)   
 +     
 IsNull(  
 (Select   
   IsNull(Sum(DebitNote.Balance),0) From DebitNote    
  Where   
   DebitNote.CustomerID Is Not Null And    
   DebitNote.DocumentDate Between @Ninety And @SixtyOne And    
   DebitNote.customerid <> N''), 0)   
 -    
 IsNull(  
  (Select   
    IsNull(Sum(CreditNote.Balance),0)   
   From   
    CreditNote     
   Where   
    CreditNote.CustomerID Is Not Null And    
    CreditNote.DocumentDate Between @Ninety And @SixtyOne And    
    CreditNote.CustomerID <> ''), 0)  
 -     
  IsNull(  
  (Select   
    IsNull(Sum(Balance), 0)   
   From   
    Collections     
   Where   
    IsNull(Balance, 0) > 0 And   
    (IsNull(Status, 0) & 64) = 0 And  
    CustomerID Is Not Null And    
    DocumentDate Between @Ninety And @SixtyOne), 0)    
    
Select   
 @MorethanNinety =   
  IsNull(  
  (Select Sum(  
    Case InvoiceAbstract.InvoiceType     
     When 4 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 5 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     When 6 Then (0 - IsNull(InvoiceAbstract.Balance, 0))     
     Else IsNull(InvoiceAbstract.Balance, 0)   
    End)    
   From   
    InvoiceAbstract    
   Where   
    InvoiceAbstract.InvoiceDate < @Ninety And    
    InvoiceAbstract.Balance > 0 And     
    InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) And    
    InvoiceAbstract.Status & 128 = 0), 0)   
  +     
  IsNull(  
  (Select   
    IsNull(Sum(DebitNote.Balance),0)   
   From   
    DebitNote    
   Where   
    DebitNote.CustomerID Is Not Null And    
    DebitNote.DocumentDate < @Ninety And    
    DebitNote.customerid <> N''), 0)   
  -    
  IsNull(  
  (Select   
    IsNull(Sum(CreditNote.Balance),0)   
   From   
    CreditNote     
   Where   
    CreditNote.CustomerID Is Not Null And    
    CreditNote.DocumentDate < @Ninety And    
    CreditNote.CustomerID <> N''), 0)   
  -     
  IsNull(  
  (Select   
    IsNull(Sum(Balance), 0)   
   From   
    Collections     
   Where   
    IsNull(Balance, 0) > 0 And   
    (IsNull(Status, 0) & 64) = 0 And   
    CustomerID Is Not Null And    
    DocumentDate < @Ninety), 0)    
    
Select   
 Cast(0 As NVarChar)+ @CIDSetUp,"Distributor Code"=@CIDSetUp,  
 "Total OutStanding (%c)" = Cast(@Total As NVarChar),"1-7 Days" = Cast(@OnetoSeven As NVarChar), "8-10 Days" = Cast(@EighttoTen As NVarChar),  
 "11-14 Days" = Cast(@EleventoFourteen As NVarChar),"15-21 Days" = Cast(@FifteentoTwentyOne As NVarChar),  
 "22-30 Days" = Cast(@TwentyTwotoThirty As NVarChar),"<30 Days" = Cast(@LessthanThirty As NVarChar),  
 "31-60 Days" = Cast(@ThirtyOnetoSixty As NVarChar),"61-90 Days" = Cast(@SixtyOnetoNinety As NVarChar),  
 ">90 Days" = Cast(@MorethanNinety As NVarChar)   
    
Union All  
  
Select   
 Cast(RecordID As NVarChar),"Distributor Code" = CompanyId,  
 "Total OutStanding (%c)" = Field1,"1-7 Days" = Field2,"8-10 Days" = Field3,  
 "11-14 Days" =Field4,"15-21 Days" = Field5,"22-30 Days" = Field6,"<30 Days" = Field7,  
 "31-60 Days" = Field8,"61-90 Days" = Field9,">90 Days" = Field10  
From    
 Reports,ReportAbstractReceived     
Where    
Reports.ReportID In (Select MAX(ReportID) From Reports Where ReportName = N'Outstanding - Total'    
And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Outstanding - Total') Where dbo.StripDateFromTime(FromDate) = @FromDate And dbo.StripDateFromTime(ToDate) = @ToDate) Group by CompanyId)  
And ReportAbstractReceived.ReportID = Reports.ReportID    
And Field1 Not Like N'Total OutStanding%' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:'   
And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)    

