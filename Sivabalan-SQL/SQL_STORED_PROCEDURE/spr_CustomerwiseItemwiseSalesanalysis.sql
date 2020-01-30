
Create Procedure spr_CustomerwiseItemwiseSalesanalysis
(@ProductHierarchy nVarchar(255), @Category nVarchar(2550),    
 @ItemCode nVarChar(2550), @UOM nVarchar(100),     
 @CusType nVarchar(100), @FromDate DateTime, @ToDate DateTime)    
As    
Declare @Delimeter as Char(1)                
Set @Delimeter=Char(15)                
    
Create Table #tempCategory (CategoryID int, Status int)     
Exec GetLeafCategories @ProductHierarchy, @Category    
    
Create Table #tmpProd(Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
    
If @ItemCode = N'%'      
 Insert InTo #tmpProd Select Product_code From Items      
Else      
 Insert InTo #tmpProd Select * From dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)      
    
If @CusType = N'Trade'    
Begin    
--select @UOM    
 Select invd.Product_Code, "Item Code" = invd.Product_Code,     
 "Item Name" = its.ProductName,     
    
 "UOM" = Case @UOM When N'Base UOM' Then     
 (Select [Description] From UOM Where UOM.UOM = its.UOM)    
 When N'Reporting UOM' Then     
 (Select [Description] From UOM Where UOM.UOM = its.ReportingUOM)    
 When N'Conversion Factor' Then
 (Select ConversionUnit From ConversionTable Where ConversionTable.ConversionID = its.ConversionUnit)
 When N'UOM 1' Then
 (Select [Description] From UOM Where UOM.UOM = its.UOM1)  
 When N'UOM 2' Then
 (Select [Description] From UOM Where UOM.UOM = its.UOM2)  
 End,     
    
 "Total Quantity Sold" = Case @UOM When N'Base UOM' Then  Sum(Case inva.InvoiceType When 4 Then Case inva.Status & 32 When 0     
 Then 0 - invd.Quantity End Else invd.Quantity End)     
 When N'Reporting UOM' Then Sum(Case inva.InvoiceType When 4 Then Case inva.Status & 32 When 0     
 Then 0 - invd.Quantity End Else invd.Quantity End) / IsNull(its.ReportingUnit, 1)    
 When N'Conversion Factor' Then Sum(Case inva.InvoiceType When 4 Then Case inva.Status & 32 When 0     
 Then 0 - invd.Quantity End Else invd.Quantity End) * IsNull(its.ConversionFactor, 1) 
 When N'UOM 1' Then Sum(Case inva.InvoiceType When 4 Then Case inva.Status & 32 When 0     
 Then 0 - invd.Quantity End Else invd.Quantity End) / IsNull(its.UOM1_Conversion, 1) 
 When N'UOM 2' Then Sum(Case inva.InvoiceType When 4 Then Case inva.Status & 32 When 0     
 Then 0 - invd.Quantity End Else invd.Quantity End) / IsNull(its.UOM2_Conversion, 1) 
 End,     
    
 "Total Value (%c)" = Sum(Case inva.InvoiceType When 4 Then Case inva.Status & 32 When 0     
 Then 0 - invd.Amount End Else invd.Amount End),     
    
 "Productive Outlets" = Count(Distinct Case When inva.InvoiceType In (1, 3) Then inva.CustomerID End),     
    
 "Total Customers" = (Select Count(CustomerID) From Customer Where Active = 1 And     
        IsNull(MembershipCode, '') = '' And CustomerID Not In ('0'))    
    
 From InvoiceAbstract inva, InvoiceDetail invd, Items its    
 Where inva.InvoiceID = invd.InvoiceID And invd.Product_Code = its.Product_code And     
--  Case @UOM  When 'Sales UOM' Then its.UOM     
--      When 'Reporting UOM' Then its.ReportingUOM End *= UOM.UOM And     
-- its.uom = uom.uom And    
 inva.InvoiceDate Between @FromDate And @ToDate And     
 inva.InvoiceType In (1, 3, 4) And IsNull(inva.Status, 0) & 192 = 0 And     
 Case inva.InvoiceType When 4 Then inva.Status & 32 Else 0 End  = 0 And    
 its.CategoryID In (Select CategoryID From #tempCategory) And     
 its.Product_Code In (Select Product_Code From #tmpProd)    
 Group By invd.Product_Code, its.ProductName, its.UOM, its.ReportingUOM,     
 its.ConversionUnit, its.ReportingUnit, its.ConversionFactor,its.UOM1,its.UOM2,its.UOM1_Conversion,its.UOM2_Conversion    
End    
Else    
Begin    
 Select invd.Product_Code, "Item Code" = invd.Product_Code,     
 "Item Name" = its.ProductName,     
    
 "UOM" = Case @UOM When N'Base UOM' Then     
 (Select [Description] From UOM Where UOM.UOM = its.UOM)    
 When N'Reporting UOM' Then     
 (Select [Description] From UOM Where UOM.UOM = its.ReportingUOM)    
 When N'Conversion Factor' Then
 (Select ConversionUnit From ConversionTable Where ConversionTable.ConversionID = its.ConversionUnit)
 When N'UOM 1' Then
 (Select [Description] From UOM Where UOM.UOM = its.UOM1)  
 When N'UOM 2' Then
 (Select [Description] From UOM Where UOM.UOM = its.UOM2)  
 End,     
    
 "Total Quantity Sold" = Case @UOM When N'Base UOM' Then  Sum(Case inva.InvoiceType When 5 Then 0 - invd.Quantity Else invd.Quantity End)    
 When N'Reporting UOM' Then Sum(Case inva.InvoiceType When 5 Then 0 - invd.Quantity Else invd.Quantity End) / IsNull(its.ReportingUnit, 1)    
 When N'Conversion Factor' Then Sum(Case inva.InvoiceType When 5 Then 0 - invd.Quantity Else invd.Quantity End) * IsNull(its.ConversionFactor, 1) 
 When N'UOM 1' Then Sum(Case inva.InvoiceType When 5 Then 0 - invd.Quantity Else invd.Quantity End) / IsNull(its.UOM1_Conversion, 1) 
 When N'UOM 2' Then Sum(Case inva.InvoiceType When 5 Then 0 - invd.Quantity Else invd.Quantity End) / IsNull(its.UOM2_Conversion, 1) 
 End,     
    
 "Total Value (%c)" = Sum(Case inva.InvoiceType When 5 Then 0 - invd.Amount Else invd.Amount End),     
    
 "Productive Outlets" = Count(Distinct inva.CustomerID),     
    
  "Total Outlets" =  (Select Count(CustomerID) From (Select CustomerID From Customer Where Active = 1 And     
 IsNull(MembershipCode, '') <> '' Union     
 Select CustomerID From Customer Where Active = 1 And CustomerID In ('0')) comb)    
    
 From InvoiceAbstract inva, InvoiceDetail invd, Items its, UOM     
 Where inva.InvoiceID = invd.InvoiceID And invd.Product_Code = its.Product_code And     
 its.UOM = UOM.UOM And     
 inva.InvoiceDate Between @FromDate And @ToDate And     
 inva.InvoiceType In (2, 5) And IsNull(inva.Status, 0) & 192 = 0 And     
 Case inva.InvoiceType When 4 Then inva.Status & 32 Else 0 End  = 0 And    
 its.CategoryID In (Select CategoryID From #tempCategory) And    
 its.Product_Code In (Select Product_Code From #tmpProd)    
 Group By invd.Product_Code, its.ProductName, its.UOM, its.ReportingUOM,     
 its.ConversionUnit, its.ReportingUnit, its.ConversionFactor,its.UOM1,its.UOM2,its.UOM1_Conversion,its.UOM2_Conversion    
    
End    
    
Drop Table #tempCategory    
Drop Table #tmpProd    

