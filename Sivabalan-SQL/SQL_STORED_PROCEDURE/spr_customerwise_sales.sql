CREATE PROCEDURE spr_customerwise_sales(@FROMDATE datetime,  
     @TODATE datetime,  
     @CusType nvarchar(50))  
AS  

Declare @OTHERS NVarchar(20)
Select @OTHERS = dbo.LookupdictionaryItem(N'Others',Default)

Declare @CurFromDate As Datetime  
Declare @CurToDate As Datetime  
Declare @YearFromDate As Datetime  
Declare @YearToDate As Datetime  
Declare @FiscalYear Int  
Declare @TransDate  as Datetime

Set @CurFromDate =  N'01/' +   
Cast(DatePart(mm, GetDate()) As nvarchar) + N'/' +  
Cast(DatePart(yyyy, GetDate()) As nvarchar)  
  
Set @CurToDate = Cast(DatePart(dd, GetDate()) As nvarchar) + N'/' +  
Cast(DatePart(mm, GetDate()) As nvarchar) + N'/' +  
Cast(DatePart(yyyy, GetDate()) As nvarchar)  
Set @CurToDate = DateAdd(d, 1, @CurToDate)  

Select @FiscalYear = FiscalYear,@TransDate = OpeningDate From Setup  

Set @YearFromDate = N'01/0' + Cast(@FiscalYear As nvarchar) + N'/' +   
Cast(DatePart(yyyy, @TransDate) As nvarchar)  

Set @YearToDate = @CurToDate  
  
If @CusType = N'Trade'  
Begin  
Select InvoiceAbstract.CustomerID,  
"CustomerID" = InvoiceAbstract.CustomerID,  
"Customer" = Customer.Company_Name,  
"Goods Value - Sales (%c)" = Case Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else InvoiceAbstract.GoodsValue End)  
When 0 Then  
N''  
Else  
Cast(Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else InvoiceAbstract.GoodsValue End) As nvarchar)  
End,  
"Goods Value - Sales Return Saleable (%c)" = Case Sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
Case InvoiceAbstract.Status & 32 When 0 then InvoiceAbstract.GoodsValue Else 0 End  
Else  
0  
End)  
When 0 Then  
N''  
Else  
Cast(Sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
Case InvoiceAbstract.Status & 32 When 0 then InvoiceAbstract.GoodsValue Else 0 End  
Else  
0  
End) As nvarchar)  
End,  
"Goods Value - Sales Return Damages (%c)" = Case Sum(Case InvoiceAbstract.InvoiceType  
When 4 Then  
Case InvoiceAbstract.Status & 32 When 0 Then 0 Else InvoiceAbstract.GoodsValue End  
Else  
0  
End)  
When 0 Then  
N''  
Else  
Cast(Sum(Case InvoiceAbstract.InvoiceType  
When 4 Then  
Case InvoiceAbstract.Status & 32 When 0 Then 0 Else InvoiceAbstract.GoodsValue End  
Else  
0  
End) As nvarchar)  
End,  
"Total Tax Suffered (%c)" = Sum(Case InvoiceAbstract.InvoiceType  
When 4 Then  
0 - TotalTaxSuffered  
Else  
TotalTaxSuffered  
End),  
"Total Discount (%c)" = Sum(Case InvoiceType  
When 4 Then  
0 - (DiscountValue + AddlDiscountValue + ProductDiscount)  
Else  
(DiscountValue + AddlDiscountValue + ProductDiscount)  
End),  
"Total Tax Applicable (%c)" = Sum(Case InvoiceType  
When 4 Then  
0 - TotalTaxApplicable  
Else  
TotalTaxApplicable  
End),  
"Net Sales" = Sum(Case InvoiceAbstract.InvoiceType  
When 4 Then  
0 - InvoiceAbstract.NetValue - IsNull(InvoiceAbstract.Freight, 0)  
Else  
InvoiceAbstract.NetValue - IsNull(InvoiceAbstract.Freight, 0)  
End),  
"Current Month No. Of Sales" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (1, 3)),  
  
"Current Month Sales (%c)" = (Select Sum(Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (1, 3)),  
  
"Current Month No. Of Sales Return" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType = 4),  
  
"Current Month Sales Return (%c)" = (Select Sum(0 - Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType = 4), 
  
"Year to Date No. Of Sales" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (1, 3)),  
  
"Year to Date Sales (%c)" = (Select Sum(Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (1, 3)),  
  
"Year to Date No. Of Sales Return" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType = 4),  
  
"Year to date Sales Return (%c)" = (Select Sum(0 - Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType = 4)  
  
From InvoiceAbstract, Customer  
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.CustomerID = Customer.CustomerID And  
InvoiceAbstract.InvoiceType in (1, 3, 4)  

Group By InvoiceAbstract.CustomerID, Customer.Company_Name  
Order By InvoiceAbstract.CustomerID, "Net Sales" Desc  
End  
Else  
Begin  
  
Select Case Isnull(InvoiceAbstract.CustomerID, N'') When N'' Then @OTHERS Else InvoiceAbstract.CustomerID End,  
"CustomerID" = Case Isnull(InvoiceAbstract.CustomerID, N'') When N'' Then @OTHERS Else InvoiceAbstract.CustomerID End,  
"Customer" = Case isnull(Customer.Company_Name, N'') When N'' Then @OTHERS Else Customer.Company_Name End,  
"Goods Value - Sales (%c)" = Cast(Sum(InvoiceAbstract.GoodsValue) As nvarchar),  
"Goods Value - Sales Return Saleable (%c)" = Sum(Case InvoiceAbstract.InvoiceType When 5 Then
InvoiceAbstract.GoodsValue Else 0 end),
"Goods Value - Sales Return Damages (%c)" = Sum(Case InvoiceAbstract.InvoiceType When 6 Then
InvoiceAbstract.GoodsValue Else 0 end),  
"Total Tax Suffered (%c)" = Sum(TotalTaxSuffered),  
"Total Discount (%c)" = Sum((DiscountValue + AddlDiscountValue + ProductDiscount)),  
"Total Tax Applicable (%c)" = Sum(TotalTaxApplicable),  
"Net Sales" = Sum(InvoiceAbstract.NetValue - IsNull(InvoiceAbstract.Freight, 0)),  
  
"Current Month No. Of Sales" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (2,5,6)),
  
"Current Month Sales (%c)" = (Select Sum(Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (2)),  
  
"Current Month No. Of Sales Return" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in(5,6)),  
  
"Current Month Sales Return (%c)" = (Select Sum(0 - Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @CurFromDate And @CurToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in(5,6)),  
  
"Year to Date No. Of Sales" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (2)),  
  
"Year to Date Sales (%c)" = (Select Sum(Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in (2)),  
  
"Year to Date No. Of Sales Return" = (Select Count(*)   
From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in(5,6)),  
  
"Year to date Sales Return (%c)" = (Select Sum(0 - Inv.NetValue -   
IsNull(Inv.Freight, 0)) From InvoiceAbstract As Inv Where  
Inv.InvoiceDate Between @YearFromDate And @YearToDate And  
Inv.Status & 128 = 0 And  
Inv.CustomerID = InvoiceAbstract.CustomerID And  
Inv.InvoiceType in(5,6))    

From InvoiceAbstract left outer join Customer  on InvoiceAbstract.CustomerID = Customer.CustomerID   
Where InvoiceAbstract.InvoiceDate Between @FromDate And @ToDate And  
InvoiceAbstract.Status & 128 = 0 And  
InvoiceAbstract.InvoiceType in (2,5,6)  

Group By InvoiceAbstract.CustomerID, Customer.Company_Name
Order By InvoiceAbstract.CustomerID, "Net Sales" Desc  
  
End
