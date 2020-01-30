CREATE procedure [dbo].[Spr_Salesman_Productivity_Litres_Per_Call]
                (@Salesman nvarchar(2550), 
		 @FromDate DateTime, 
                 @ToDate DateTime)
As

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Declare @salid Int
Declare @Others nVarchar(20)
set @Others = dbo.LookupDictionaryItem('Others',default)
If @Salesman != '%'
Select @salid = salesmanid from salesman Where salesman_name like @salesman

Create table #tmpSal(Salesman nvarchar(255))  

If @Salesman = '%'   
   Insert into #tmpSal select Salesman_Name from Salesman  
Else  
   Insert into #tmpSal select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter)  

Create Table #TempResult([SalesmanID] Int, [Salesman Name] nvarchar(255), 
[Total Sales Value] Decimal(18, 6), [Total Sales Volume] Decimal(18, 6),
[No of Invoices] Int, [Volume Per call] Decimal(18, 6))

Create Table #TempResult1([SalesmanID] Int, [Salesman Name] nvarchar(255), 
[Total Sales Value] Decimal(18, 6), [Total Sales Volume] Decimal(18, 6),
[No of Invoices] Int, [Volume Per call] Decimal(18, 6))

If @Salesman = '%'   
Begin
Insert InTo #TempResult Select "SalesmanID" = Case ia.InvoiceType When 2 Then 0 Else IsNull(s.SalesmanID, 0) End, 
"Salesman Name" = Case ia.InvoiceType When 2 Then @Others Else IsNull(s.Salesman_Name, @Others) End, 
"Total Sales Value" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
 * IsNull(ids.Amount, 0)) As Decimal(18, 6)),
"Total Sales Volume" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
 * IsNull(ids.Quantity, 0)) As Decimal(18, 6)),
"No of Invoices" = Count(Distinct ia.InvoiceID),
"Volume Per call" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
 * IsNull(ids.Quantity, 0)) / (Case Count(Distinct ia.InvoiceID) When 0 Then 1
Else Count(Distinct ia.InvoiceID) End) As Decimal(18, 6)) From Salesman s, InvoiceAbstract ia, InvoiceDetail ids Where 
ia.InvoiceID = ids.InvoiceID And  ia.SalesmanID *= s.SalesmanID  And 
s.Salesman_Name In (Select * From #tmpSal) And ia.InvoiceDate Between @FromDate And @ToDate And
IsNull(ia.Status, 0) & 192 = 0 Group By s.SalesmanID, s.Salesman_Name, ia.InvoiceType

Select [SalesmanID], [Salesman Name] , 
"Total Sales Value" = SUM([Total Sales Value]), "Total Sales Volume" = Sum([Total Sales Volume]),
"No of Invoices" = Sum([No of Invoices]), "Volume Per call" = Sum([Volume Per call]) 
From #TempResult Group By [SalesmanID], [Salesman Name]

End
Else
Begin
Insert InTo #TempResult1 Select "SalesmanID" = Case ia.InvoiceType When 2 Then 0 Else IsNull(s.SalesmanID, 0) End, 
"Salesman Name" = Case ia.InvoiceType When 2 Then @Others Else IsNull(s.Salesman_Name, @Others) End, 
"Total Sales Value" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
 * IsNull(ids.Amount, 0)) As Decimal(18, 6)),
"Total Sales Volume" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
 * IsNull(ids.Quantity, 0)) As Decimal(18, 6)),
"No of Invoices" = Count(Distinct ia.InvoiceID),
"Volume Per call" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
 * IsNull(ids.Quantity, 0)) / (Case Count(Distinct ia.InvoiceID) When 0 Then 1
Else Count(Distinct ia.InvoiceID) End) As Decimal(18, 6)) From Salesman s, InvoiceAbstract ia, InvoiceDetail ids Where 
ia.InvoiceID = ids.InvoiceID And  ia.SalesmanID = s.SalesmanID  And 
s.Salesman_Name In (Select * From #tmpSal) And ia.InvoiceDate Between @FromDate And @ToDate And
IsNull(ia.Status, 0) & 192 = 0 Group By s.SalesmanID, s.Salesman_Name, ia.InvoiceType

Select [SalesmanID], [Salesman Name] , 
"Total Sales Value" = SUM([Total Sales Value]), "Total Sales Volume" = Sum([Total Sales Volume]),
"No of Invoices" = Sum([No of Invoices]), "Volume Per call" = Sum([Volume Per call]) 
From #TempResult1 Group By [SalesmanID], [Salesman Name]

End

--Select * From #TempResult
Drop Table #tmpSal
Drop Table #TempResult
Drop Table #TempResult1
