CREATE procedure [dbo].[Spr_Salesman_Productivity_Products_Per_Call] 
                                                       (@Salesman nvarchar(2550),
							@UOM nvarchar(50),
							@ProHier nvarchar(255),
                                                        @FromDate DateTime,
							@ToDate DateTime)
As

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Declare @UOMDescription nvarchar(255)
Declare @MLOthers NVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)

Create table #tmpSal(Salesman nvarchar(255))  

If @Salesman = N'%'   
   Insert into #tmpSal select Salesman_Name from Salesman  
Else  
   Insert into #tmpSal select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter)  

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories @ProHier, N'%'
Select Distinct CategoryID InTo #temp From #tempCategory

If IsNull((Select Case @UOM When N'Sales UOM' Then Count(Distinct it.UOM) 
                            When N'UOM1'      Then Count(Distinct it.UOM1)
                            When N'UOM2'      Then Count(Distinct it.UOM2) End From Items it, 
           InvoiceAbstract ia, InvoiceDetail ids, #temp Where ia.InvoiceID = ids.InvoiceID And
           ids.Product_Code = it.Product_Code And it.CategoryID = #temp.CategoryID And
	   ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0)
           , 0) = 1
Begin
  Select @UOMDescription = IsNull(u.[Description], N'') From UOM u, Items it, 
  InvoiceAbstract ia, InvoiceDetail ids, #temp Where 
  u.UOM = (Case @UOM When N'Sales UOM' Then IsNull(it.UOM, 0) 
                     When N'UOM1'      Then IsNull(it.UOM1, 0)
                     When N'UOM2'      Then IsNull(it.UOM2, 0) End) And 
  ia.InvoiceID = ids.InvoiceID And ids.Product_Code = it.Product_Code And 
  it.CategoryID = #temp.CategoryID And
  ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0 
End
Else
Begin
  Set @UOMDescription = N''
End

-- Create Table #TempResult(SalesmanID Int, Salesman nvarchar(255), 
-- SalesValue Decimal(18, 6), SalesVolume Decimal(18, 6),
-- UOMDescription nvarchar(255), TotalProducts nvarchar(255), NoOfInv Int, ppc Decimal(18, 6))
-- 
-- Create Table #TempResult1(SalesmanID Int, Salesman nvarchar(255), 
-- SalesValue Decimal(18, 6), SalesVolume Decimal(18, 6),
-- UOMDescription nvarchar(255), TotalProducts nvarchar(255), NoOfInv Int, ppc Decimal(18, 6))

If @Salesman = N'%'
Begin
--Insert InTo #TempResult  
Select "Salesman ID" = [SalesmanID], "Salesman Name" = [SalesmanName], 
"Sales Value In (%c)" = Sum([SalesValue]),
"Sales Volume In UOM" = Sum([SalesVolume]),
"UOM Description" = [UOMDescription],
"Total Products" = Count(Distinct [ProductCode]),
"No Of Invoices" = Count(Distinct [InvoiceCount]),
"Products / Call" = Sum([SalesValue]) / Case IsNull(Sum([InvoiceCount]), 0) When 0 Then 1 Else Sum([InvoiceCount]) End
From ( 
Select 
"SalesmanID" =   Case ia.InvoiceType When 2 Then 0 Else IsNull(ia.SalesmanID, 0) End, 
"SalesmanName"  = Case ia.InvoiceType When 2 Then @MLOthers Else IsNull(s.Salesman_Name, @MLOthers) End, 
"SalesValue" =   Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
  * IsNull(ids.Amount, 0)) As Decimal(18, 6)),
"SalesVolume" =   Case @UOM When N'Sales UOM' Then 
    Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0)) 
            When N'UOM1' Then
    Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0) / 
    Case When IsNull(it.UOM1_Conversion, 0) = 0 Then 1 Else it.UOM1_Conversion End)
            When N'UOM2' Then
	Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0) / 
    Case When IsNull(it.UOM2_Conversion, 0) = 0 Then 1 Else it.UOM2_Conversion End) End,

"UOMDescription" =   @UOMDescription,
"ProductCode" =   IsNull(ids.Product_Code, N''), 
"InvoiceCount" =  ia.InvoiceID
--   (Case @UOM When 'Sales UOM' Then 
--     Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0)) 
--             When 'UOM1' Then
--     Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0) / 
--     Case When IsNull(it.UOM1_Conversion, 0) = 0 Then 1 Else it.UOM1_Conversion End)
--             When 'UOM2' Then
-- 	Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0) / 
--     Case When IsNull(it.UOM2_Conversion, 0) = 0 Then 1 Else it.UOM2_Conversion End) End)
   From Salesman s, 
  InvoiceAbstract ia, InvoiceDetail ids, Items it, #temp Where ia.InvoiceID = ids.InvoiceID 
  And ids.Product_Code = it.Product_Code And it.CategoryID = #temp.CategoryID And 
  ia.SalesmanID *= s.SalesmanID  And s.Salesman_Name In (Select * From #tmpSal) And 
  ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0 
  Group By ia.SalesmanID, s.Salesman_Name, ia.InvoiceType, ids.Product_Code, ia.InvoiceID
) ab 
  Group By [SalesmanID], [SalesmanName], [UOMDescription]


--   Select * from #TempResult
-- 
--   Select SalesmanID, "Salesman Name" = Salesman, 
--   "Sales Value In (%c)" = Sum(SalesValue), 
--   "Sales Volume In UOM" = Sum(SalesVolume),
--   "UOM Description" = UOMDescription, 
--   "Total Products" = Sum(TotalProducts), 
--   "No Of Invoices" = sum(NoOfInv), 
--   "Products/Call" = Sum(SalesVolume) / 
--     Case IsNull(Sum(NoOfInv), 0) When 0 Then 1 Else Sum(NoOfInv) End From #TempResult
--   Group By SalesmanID, Salesman, UOMDescription

End
Else
Begin
-- Insert InTo #TempResult1 
Select "Salesman ID" = [SalesmanID], "Salesman Name" = [SalesmanName], 
"Sales Value In (%c)" = Sum([SalesValue]),
"Sales Volume In UOM" = Sum([SalesVolume]),
"UOM Description" = [UOMDescription],
"Total Products" = Count(Distinct [ProductCode]),
"No Of Invoices" = Count(Distinct [InvoiceCount]),
"Products / Call" = Sum([SalesValue]) / Case IsNull(Sum([InvoiceCount]), 0) When 0 Then 1 Else Sum([InvoiceCount]) End
From (
Select 
"SalesmanID" =  Case ia.InvoiceType When 2 Then 0 Else IsNull(ia.SalesmanID, 0) End, 
"SalesmanName"  =   Case ia.InvoiceType When 2 Then @MLOthers Else IsNull(s.Salesman_Name, @MLOthers) End, 
"SalesValue" =     Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
  * IsNull(ids.Amount, 0)) As Decimal(18, 6)),
"SalesVolume" =       Case @UOM When N'Sales UOM' Then 
    Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0)) 
            When N'UOM1' Then
    Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0) / 
    Case When IsNull(it.UOM1_Conversion, 0) = 0 Then 1 Else it.UOM1_Conversion End)
            When N'UOM2' Then
	Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0) / 
    Case When IsNull(it.UOM2_Conversion, 0) = 0 Then 1 Else it.UOM2_Conversion End) End,

"UOMDescription" =   @UOMDescription,
"ProductCode" =    IsNull(ids.Product_Code, N'') ,
"InvoiceCount" =    ia.InvoiceID
--   (Case @UOM When 'Sales UOM' Then 
--     Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0)) 
--             When 'UOM1' Then
--     Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0) / 
--     Case When IsNull(it.UOM1_Conversion, 0) = 0 Then 1 Else it.UOM1_Conversion End)
--             When 'UOM2' Then
-- 	Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0) / 
--     Case When IsNull(it.UOM2_Conversion, 0) = 0 Then 1 Else it.UOM2_Conversion End) End) / 
--    (Case Count(Distinct ia.InvoiceID) When 0 Then 1
--   Else Count(Distinct ia.InvoiceID) End)
  From Salesman s, 
  InvoiceAbstract ia, InvoiceDetail ids, Items it, #temp Where ia.InvoiceID = ids.InvoiceID
  And ids.Product_Code = it.Product_Code And it.CategoryID = #temp.CategoryID
  And (Case IsNull(ia.InvoiceType, 0) When 2 Then 0 Else ia.SalesmanID End)= s.SalesmanID  And s.Salesman_Name In (Select * From #tmpSal)
  And ia.InvoiceDate Between @FromDate And @ToDate And IsNull(ia.Status, 0) & 192 = 0 
  Group By ia.SalesmanID, s.Salesman_Name, ia.InvoiceType, ids.Product_Code, ia.InvoiceID
) ab
  Group By [SalesmanID], [SalesmanName], [UOMDescription]

--   Select * from #TempResult1
-- 
--   Select SalesmanID, "Salesman Name" = Salesman, 
--   "Sales Value In (%c)" = Sum(SalesValue), 
--   "Sales Volume In UOM" = Sum(SalesVolume),
--   "UOM Description" = UOMDescription, 
--   "Total Products" = Sum(TotalProducts), 
--   "No Of Invoices" = sum(NoOfInv), 
--   "Products/Call" = Sum(SalesVolume) / 
--     Case IsNull(Sum(NoOfInv), 0) When 0 Then 1 Else Sum(NoOfInv) End From #TempResult1
--   Group By SalesmanID, Salesman, UOMDescription
--Select * From #tmpSal
End

Drop Table #tmpSal
Drop Table #tempCategory
Drop Table #temp
-- Drop Table #TempResult
-- Drop Table #TempResult1
