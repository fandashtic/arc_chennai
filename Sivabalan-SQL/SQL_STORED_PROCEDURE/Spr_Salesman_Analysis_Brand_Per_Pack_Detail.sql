CREATE Procedure Spr_Salesman_Analysis_Brand_Per_Pack_Detail
						(@Salesman nvarchar(2550),
						 @UOM nvarchar(50),
						 @ProHier nvarchar(255),
                                                 @FromDate DateTime,
						 @ToDate DateTime)
As

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Declare @UOMDescription nvarchar(255)

Create table #tmpSal(Salesman nvarchar(255))  

If @Salesman = N'%'   
   Insert into #tmpSal select Salesman_Name from Salesman  
Else  
   Insert into #tmpSal select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter)  

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories @ProHier, N'%'
Select Distinct CategoryID InTo #temp From #tempCategory

-- Select @UOM
-- Select IsNull((Select Case @UOM When 'Sales UOM' Then Count(Distinct it.UOM) 
--                             When 'UOM1'      Then Count(Distinct it.UOM1)
--                             When 'UOM2'      Then Count(Distinct it.UOM2) End From Items it, 
--            InvoiceAbstract ia, InvoiceDetail ids, #temp Where ia.InvoiceID = ids.InvoiceID And
--            ids.Product_Code = it.Product_Code And it.CategoryID = #temp.CategoryID And
-- 	   ia.InvoiceDate Between @FromDate And 
--    	   @ToDate And 
--        (Case ia.InvoiceType When 2 Then 0 Else IsNull(ia.SalesmanID, 0) End) = @Salesman And
--        IsNull(ia.Status, 0) & 192 = 0)
--            , 0)



If IsNull((Select Case @UOM When N'Sales UOM' Then Count(Distinct it.UOM) 
                            When N'UOM1'      Then Count(Distinct it.UOM1)
                            When N'UOM2'      Then Count(Distinct it.UOM2) End From Items it, 
           InvoiceAbstract ia, InvoiceDetail ids, #temp Where ia.InvoiceID = ids.InvoiceID And
           ids.Product_Code = it.Product_Code And it.CategoryID = #temp.CategoryID And
	   ia.InvoiceDate Between @FromDate And 
   	   @ToDate And 
       (Case ia.InvoiceType When 2 Then 0 Else IsNull(ia.SalesmanID, 0) End) = @Salesman And
       IsNull(ia.Status, 0) & 192 = 0)
           , 0) = 1
Begin
  Select @UOMDescription = IsNull(u.[Description], N'') From UOM u, Items it, 
  InvoiceAbstract ia, InvoiceDetail ids, #temp Where 
  u.UOM = (Case @UOM When N'Sales UOM' Then IsNull(it.UOM, 0) 
                     When N'UOM1'      Then IsNull(it.UOM1, 0)
                     When N'UOM2'      Then IsNull(it.UOM2, 0) End) And 
  ia.InvoiceID = ids.InvoiceID And ids.Product_Code = it.Product_Code And
  it.CategoryID = #temp.CategoryID And  
  ia.InvoiceDate Between @FromDate And @ToDate And 
  (Case ia.InvoiceType When 2 Then 0 Else IsNull(ia.SalesmanID, 0) End) = @Salesman And
  IsNull(ia.Status, 0) & 192 = 0 
End
Else
Begin
  Set @UOMDescription = N''
End

Select IsNull(ic.Category_Name, N''), "Category" = IsNull(ic.Category_Name, N''),
"Product Code" = IsNull(ids.Product_Code, N''),
"Product Name" = IsNull(it.ProductName, N''), 
"Sales in Value (%c)" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
  * IsNull(ids.Amount, 0)) As Decimal(18, 6)),
"Sales in Volume UOM" = Cast((Case @UOM When N'Sales UOM' Then 
                Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0)) 
               When N'UOM1' Then 
                Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0)) / Case When IsNull(it.UOM1_Conversion, 0) = 0 Then 1 Else it.UOM1_Conversion End
               When N'UOM2' Then 
                Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End * IsNull(ids.Quantity, 0)) / Case When IsNull(it.UOM2_Conversion, 0) = 0 Then 1 Else it.UOM2_Conversion End End) As Decimal(18, 6)),
"Unit of Measurement" = @UOMDescription 
From ItemCategories ic, InvoiceAbstract ia, InvoiceDetail ids, Items it, #temp
Where ic.CategoryID = #temp.CategoryID And ic.CategoryID = it.CategoryID And
it.Product_Code = ids.Product_Code And ids.InvoiceID = ia.InvoiceID And 
ia.InvoiceDate Between @FromDate And @ToDate And 
(Case ia.InvoiceType When 2 Then 0 Else IsNull(ia.SalesmanID, 0) End) = @Salesman And
IsNull(ia.Status, 0) & 192 = 0 
Group By ic.Category_Name, ids.Product_Code, it.ProductName, it.UOM1_Conversion,
  it.UOM2_Conversion

Drop Table #tmpSal
Drop Table #tempCategory
Drop Table #temp




