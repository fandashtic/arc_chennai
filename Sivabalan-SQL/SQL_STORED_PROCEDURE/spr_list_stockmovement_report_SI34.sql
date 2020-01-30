CREATE PROCEDURE spr_list_stockmovement_report_SI34(@HierarchyName nvarchar(255),              
        @UOM nvarchar(50),              
        @FROMDATE datetime,              
        @TODATE datetime)              
As                            
Declare @TOTAL As NVarchar(50)
Set @TOTAL  = dbo.LookupDictionaryItem(N'Total:',Default)

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories @HierarchyName, '%'
Select Distinct CategoryID InTo #tempc From #tempCategory

Declare @NEXT_DATE datetime                            
DECLARE @CORRECTED_DATE datetime                            
Declare @OnHandQuantity Decimal(18, 6)
Declare @OnHandFreeQuantity Decimal (18, 6)
Declare @FDATE DateTime 

SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/' + CAST(DATEPART(mm, @TODATE) as nvarchar) + '/' + cast(DATEPART(yyyy, @TODATE) AS nVarChar)
SET  @NEXT_DATE = CAST(DATEPART(dd, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar) + '/' 
+ CAST(DATEPART(mm, dbo.Fn_GetOperartingDate(GETDATE())) as nvarchar) + '/' 
+ cast(DATEPART(yyyy, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar)
Set @FDATE = CAST(DATEPART(dd, @FROMDATE) AS nvarchar) + '/' + CAST(DATEPART(mm, @FROMDATE) as nvarchar) + '/' + cast(DATEPART(yyyy, @FROMDATE) AS nvarchar)


Create Table #temp1([ProductCode] nVarChar(255), [Item Code] nVarChar(255), [UOM] nVarChar(255), 
[Opening Stock] Decimal(18, 6), [Purchase] Decimal(18, 6), [Total Stock] Decimal(18, 6),
[Sales] Decimal(18, 6), [Other Disposals] Decimal(18, 6), [Closing Stock] Decimal(18, 6),
[Old PKD Date] nVarChar(255),Active1 int)

Create Table #temp2([ProductCode] nVarChar(255), [Item Code] nVarChar(255), [UOM] nVarChar(255), 
[Opening Stock] Decimal(18, 6), [Purchase] Decimal(18, 6), [Total Stock] Decimal(18, 6),
[Sales] Decimal(18, 6), [Other Disposals] Decimal(18, 6), [Closing Stock] Decimal(18, 6),
[Old PKD Date] nVarChar(255),Active1 int)


Insert InTo #temp1 Select [Item Code], "Item Code" = [Item Code], 
  "UOM" = Case @UOM When 'Sales UOM' Then IsNull((Select IsNull([Description], '') From UOM Where UOM = its.UOM), '')
                    When 'Conversion Factor' Then IsNull((Select IsNull(ConversionUnit, '') From ConversionTable Where ConversionID = its.ConversionUnit), '')
                    When 'Reporting UOM' Then IsNull((Select IsNull([Description], '') From UOM Where UOM = its.ReportingUOM), '') End, 

  "Opening Stock" = Case @UOM When 'Sales UOM' Then [Opening Stock] * 1
                              When 'Conversion Factor' Then [Opening Stock] * IsNull(its.ConversionFactor, 1)
                              When 'Reporting UOM' Then [Opening Stock] / IsNull(its.ReportingUnit, 1) End, 

  "Purchase" = Case @UOM When 'Sales UOM' Then [Purchase] * 1
                              When 'Conversion Factor' Then [Purchase] * IsNull(its.ConversionFactor, 1)
                              When 'Reporting UOM' Then [Purchase] / IsNull(its.ReportingUnit, 1) End, 

  "Total Stock" = Case @UOM When 'Sales UOM' Then ([Opening Stock] + [Purchase]) * 1
                              When 'Conversion Factor' Then ([Opening Stock] + [Purchase]) * IsNull(its.ConversionFactor, 1)
                              When 'Reporting UOM' Then ([Opening Stock] + [Purchase]) / IsNull(its.ReportingUnit, 1) End,
  
  "Sales" = Case @UOM When 'Sales UOM' Then [Sales] * 1
                              When 'Conversion Factor' Then [Sales] * IsNull(its.ConversionFactor, 1)
                              When 'Reporting UOM' Then [Sales] / IsNull(its.ReportingUnit, 1) End, 

  "Other Disposals" = Case @UOM When 'Sales UOM' Then ([Closing Stock] - ([Opening Stock] + [Purchase] - [Sales])) * 1
                              When 'Conversion Factor' Then ([Closing Stock] - ([Opening Stock] + [Purchase] - [Sales])) * IsNull(its.ConversionFactor, 1)
                              When 'Reporting UOM' Then ([Closing Stock] - ([Opening Stock] + [Purchase] - [Sales])) / IsNull(its.ReportingUnit, 1) End,

  "Closing Stock" = Case @UOM When 'Sales UOM' Then [Closing Stock] * 1
                              When 'Conversion Factor' Then [Closing Stock] * IsNull(its.ConversionFactor, 1)
                              When 'Reporting UOM' Then [Closing Stock] / IsNull(its.ReportingUnit, 1) End,

  "Old PKD Dat" = [Old Pkd Date], "Active1"= its.Active From
-- Table 1  S1
(Select "Item Code" = its.Product_Code,

  "Opening Stock" = IsNull((Select IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)
    From OpeningDetails Where Product_Code = its.Product_Code And Opening_Date = @FDATE), 0),

  "Purchase" = IsNull((Select Sum(IsNull(QuantityReceived, 0) + IsNull(FreeQty, 0) - IsNull(QuantityRejected, 0)) From 
    GRNAbstract ga, GRNDetail gd Where ga.GRNID = gd.GRNID And GRNDate Between @FromDate And
    @ToDate And Product_Code = its.Product_Code And IsNull(GRNStatus, 0) & 96 = 0), 0) - 

    IsNull((Select Sum(IsNull(Quantity, 0)) From AdjustmentReturnAbstract ara, AdjustmentReturnDetail ard Where
    ara.AdjustmentID = ard.AdjustmentID And AdjustmentDate Between @FromDate And @ToDate And 
    IsNull(Status, 0) & 192 = 0 And Product_Code = its.Product_Code), 0),

  "Sales" = IsNull((Select Sum(Case InvoiceType When 4 Then -1 Else 1 End * Quantity) 
    From InvoiceAbstract inv, InvoiceDetail invd Where inv.InvoiceID = invd.InvoiceID
    And Product_Code = its.Product_Code And InvoiceDate Between @FromDate And @ToDate 
    And IsNull(Status, 0) & 192 = 0 And Case InvoiceType When 4 Then IsNull(Status, 0) & 32 Else 0 End = 0), 0) +

    IsNull((Select Sum(IsNull(Quantity, 0)) From DispatchAbstract da, DispatchDetail dd Where 
    da.DispatchID = dd.DispatchID And DispatchDate Between @FromDate And @ToDate And 
    dd.Product_Code = its.Product_Code And IsNull(da.Status, 0) & 192 = 0), 0),

  "Closing Stock" = dbo.OnHandQ(@CORRECTED_DATE, @NEXT_DATE, its.Product_Code),

  "Old Pkd Date" = (Select Convert(nVarChar,Month(Min(PKD))) + '/' + 
                    Convert(nVarChar,Year(Min(PKD))) From Batch_Products Where 
                    Product_Code = Its.Product_Code And Isnull(Batch_Products.Quantity,0) > 0)
  From Items its, #tempc te Where its.CategoryID = te.CategoryID) si, Items its Where
  [Item Code] = Product_Code 

Insert into #Temp2 Select * From #Temp1 Where Active1=1 Or (Active1=0  And 
([Opening Stock]<>0 Or [Purchase]<>0 Or [Total Stock]<>0 Or [Sales] <>0 Or 
[Other Disposals]<>0 Or [Closing Stock]<>0))

Insert InTo #temp2 Select '', @TOTAL, '', Sum([Opening Stock]), Sum([Purchase]), 
  Sum([Total Stock]), Sum([Sales]), Sum([Other Disposals]), Sum([Closing Stock]),
  '','' From #temp2  

Select [ProductCode], [Item Code], [UOM] , 
[Opening Stock] , [Purchase] , [Total Stock] ,
[Sales] , [Other Disposals] , [Closing Stock] ,
[Old PKD Date] From #temp2

Drop Table #temp1
Drop Table #temp2

