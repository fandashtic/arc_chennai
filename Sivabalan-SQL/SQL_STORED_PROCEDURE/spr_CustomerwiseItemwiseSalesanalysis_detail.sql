Create Procedure spr_CustomerwiseItemwiseSalesanalysis_detail    
(@ItemCode nVarChar(2550), @UOM nVarchar(100),    
  @CusType nVarchar(100), @FromDate DateTime, @ToDate DateTime)    
As    
Declare @Inv nVarchar(50)    
Declare @RInv nVarchar(50)    
    
Select @Inv = Prefix From Voucherprefix Where TranID = 'Invoice'    
Select @RInv = Prefix From Voucherprefix Where TranID = 'Retail Invoice'    
    
If @CusType = N'Trade'    
Begin    
 Select inva.InvoiceID, "Invoice Id" = Case IsNULL(inva.GSTFlag ,0)
when 0 then @Inv + Cast(inva.DocumentID As nVarchar) else   IsNULL(inva.GSTFullDocID,'')
                End,     
 "Doc Reference" = inva.DocReference, "Invoice Date" = inva.InvoiceDate,     
 "Customer ID" = inva.CustomerID, "Customer" = cus.Company_Name,     
    
 "Quantity" = Case @UOM When N'Base UOM' Then  Sum(Case inva.InvoiceType When 4 Then Case inva.Status & 32 When 0     
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
    
 "Value (%c)" = Sum(Case inva.InvoiceType When 4 Then Case inva.Status & 32 When 0     
 Then 0 - invd.Amount End Else invd.Amount End)    
    
 From InvoiceAbstract inva, InvoiceDetail invd, Customer cus, Items its Where    
 inva.InvoiceID = invd.InvoiceID And inva.CustomerID = cus.CustomerID     
 And invd.Product_Code = its.Product_code     
 And inva.InvoiceDate Between @FromDate And @ToDate And     
 inva.InvoiceType In (1, 3, 4) And IsNull(inva.Status, 0) & 192 = 0 And     
 invd.Product_Code = @ItemCode And     
 Case inva.InvoiceType When 4 Then inva.Status & 32 Else 0 End = 0     
 Group By inva.InvoiceID, inva.DocReference, inva.InvoiceDate, inva.GSTFlag,inva.GSTFullDocID,    
 inva.CustomerID, cus.Company_Name, its.ReportingUnit, its.ConversionFactor,    
 inva.DocumentID,its.UOM1_Conversion,its.UOM2_Conversion    
    
End    
Else    
Begin    
 Select inva.InvoiceID, "Invoice Id" = Case IsNULL(inva.GSTFlag ,0)
when 0 then @RInv + Cast(inva.DocumentID As nVarchar) else  IsNULL(inva.GSTFullDocID,'') end ,     
 "Doc Reference" = inva.DocReference, "Invoice Date" = inva.InvoiceDate,     
 "Customer ID" = inva.CustomerID, "Customer" = cus.Company_Name,     
    
 "Quantity" = Case @UOM When N'Base UOM' Then  Sum(Case inva.InvoiceType     
 When 5 Then 0 - invd.Quantity Else invd.Quantity End)     
 When N'Reporting UOM' Then Sum(Case inva.InvoiceType     
 When 5 Then 0 - invd.Quantity Else invd.Quantity End) / IsNull(its.ReportingUnit, 1)    
 When N'Conversion Factor' Then Sum(Case inva.InvoiceType     
 When 5 Then 0 - invd.Quantity Else invd.Quantity End) * IsNull(its.ConversionFactor, 1)   
 When N'UOM 1' Then Sum(Case inva.InvoiceType     
 When 5 Then 0 - invd.Quantity Else invd.Quantity End) / IsNull(its.UOM1_Conversion, 1)   
 When N'UOM 2' Then Sum(Case inva.InvoiceType     
 When 5 Then 0 - invd.Quantity Else invd.Quantity End) / IsNull(its.UOM2_Conversion, 1)   
End,     
    
 "Value (%c)" = Sum(Case inva.InvoiceType When 5      
 Then 0 - invd.Amount Else invd.Amount End)    
    
 From InvoiceAbstract inva, InvoiceDetail invd, Customer cus, Items its Where    
 inva.InvoiceID = invd.InvoiceID And inva.CustomerID = cus.CustomerID     
 And invd.Product_Code = its.Product_code     
 And inva.InvoiceDate Between @FromDate And @ToDate And     
 inva.InvoiceType In (2, 5) And IsNull(inva.Status, 0) & 192 = 0 And     
 invd.Product_Code = @ItemCode     
 Group By inva.InvoiceID, inva.DocReference, inva.InvoiceDate, inva.GSTFlag,inva.GSTFullDocID,     
 inva.CustomerID, cus.Company_Name, its.ReportingUnit, its.ConversionFactor,    
 inva.DocumentID,its.UOM1_Conversion,its.UOM2_Conversion   
    
End 
