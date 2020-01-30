CREATE procedure [dbo].[spr_list_SalesDay_Invoice_Sales]  
(  
 @ItemCode NVarChar(15),     
 @BranchName NVarChar(4000),    
 @UnUsed1 NVarChar(2550),       
 @UnUsed2 NVarChar(2550),  
 @UnUsed3 NVarChar(2550),        
 @Uom NVarChar(100),    
 @FromDate DateTime,    
 @TODATE DateTime  
)    
AS    
  
Declare @Delimeter as Char(1)   
Set @Delimeter=Char(15)    
  
Set @FromDate = dbo.StripDateFromTime(@FromDate)        
Set @ToDate = dbo.StripDateFromTime(@ToDate)     
  
CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)          
If @BranchName = N'%'              
 Insert InTo #TmpBranch Select Distinct CompanyId From Reports    
Else              
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * from dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))    
  
DECLARE @INV AS NVarChar(50)    
DECLARE @INVAMND AS NVarChar(50)    
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE'    
SELECT @INVAMND = Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE AMENDMENT'    
  
Declare  @CIDSetUp As NVarChar(50)  
Select @CIDSetUp=RegisteredOwner From Setup   
  
SELECT   
 Cast(InvoiceDetail.InvoiceID As NVarChar),  
 "Distributor Code" = @CIDSetUp,  
 "InvoiceID" =     
  CASE InvoiceAbstract.InvoiceType    
   WHEN 1 THEN @INV    
   ELSE @INVAMND    
  END + CAST(InvoiceAbstract.DocumentID AS NVarChar),    
 "Doc Reference"=DocReference,    
 "Invoice Type" =   
  Case InvoiceAbstract.InvoiceType    
   WHEN 2 THEN 'Retail Invoice'    
   ELSE 'Trade Invoice'     
  END,    
 "Invoice Date" = InvoiceAbstract.InvoiceDate,     
 "CustomerID" = Case InvoiceType When 2 Then IsNull(Cash_Customer.CustomerName,'') Else InvoiceAbstract.CustomerID End,    
 "Customer Name" = Case InvoiceType When 2 Then IsNull(Cash_Customer.CustomerName,'') Else Customer.Company_Name End,    
 "Quantity" = CAST(Sum(  
  Case @Uom   
   When 'Sales UOM' Then InvoiceDetail.Quantity    
   When 'UOM1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)    
   When 'UOM2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM2_Conversion)   
  End)   
  AS NVarChar) + ' ' + CAST(UOM.Description AS NVarChar),     
 "Conversion Factor" = CAST(CAST(Sum(InvoiceDetail.Quantity * Items.ConversionFactor) AS Decimal(18,6)) AS NVarChar) + ' ' + CAST(ConversionTable.ConversionUnit AS NVarChar),    
  "Reporting UOM" = Cast(Sum(dbo.sp_Get_ReportingQty(ISNULL(InvoiceDetail.Quantity, 0), Items.ReportingUnit)) As NVarChar) + ' ' + CAST((SELECT Description FROM UOM WHERE UOM = Items.ReportingUOM) AS NVarChar),    
 "Batch" = Batch_Products.Batch_Number,    
 "PKD" = Batch_Products.PKD,    
 "Expiry" = Batch_Products.Expiry,    
 "Sale Price (%c)" = ISNULL(InvoiceDetail.SalePrice,0),    
 "Net Value (%c)" = ISNULL(SUM(InvoiceDetail.Amount), 0)    
FROM   
 InvoiceAbstract, InvoiceDetail, UOM, ConversionTable, Items,  
 Batch_Products, Customer, Cash_Customer    
WHERE   
 InvoiceDetail.Product_Code = @ItemCode     
 AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID    
 AND (InvoiceAbstract.InvoiceType <>4 )     
 AND InvoiceAbstract.Status & 128 = 0    
 AND dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) = @FromDate    
 AND dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) =  @TODATE     
 AND InvoiceDetail.Product_Code =  Items.Product_Code    
 AND   
 (Case @Uom   
   When 'Sales UOM' Then Items.UOM When 'UOM1' Then Items.UOM1     
   When 'UOM2' Then Items.UOM2   
  End) *= UOM.UOM    
 AND Items.ConversionUnit *= ConversionTable.ConversionID    
 AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code    
 And InvoiceAbstract.CustomerID *= Customer.CustomerID    
 And InvoiceAbstract.CustomerID *= Cast(Cash_Customer.CustomerID As NVarChar)    
GROUP BY   
 InvoiceDetail.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.CustomerID,     
 InvoiceType, Customer.Company_Name, Cash_Customer.CustomerName,    
 InvoiceAbstract.InvoiceDate,InvoiceAbstract.DocReference,    
 InvoiceDetail.SalePrice, ConversionTable.ConversionUnit, Items.ReportingUOM,   
 UOM.Description, Batch_Products.Batch_Number, Batch_Products.PKD, Batch_Products.Expiry    
  
Union All  
  
Select   
 Reports.CompanyID,"Distributor Code" = Reports.CompanyID,      
 "InvoiceId" = RDR.Field1,"Doc Reference" = RDR.Field2,          
 "Invoice Type" = RDR.Field3,"Invoice Date" = RDR.Field4,        
 "CustomerID" = RDR.Field5,"Customer Name" = RDR.Field6,     
 "Quantity" = 
  Case @UOM   
   When 'Sales UOM' Then 
			 Case   
		    When RDR.Field7 = '' Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
		    When RDR.Field7 = NULL Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
		    Else Cast(Cast(Left(RDR.Field7,CharIndex(' ',RDR.Field7)-1) As Decimal(18,6))AS NVarChar)+ ' ' + Cast(UOM.Description AS NVarChar)   
		  End   
   When 'UOM1' Then 
			 Case   
	    When RDR.Field7 = '' Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
	    When RDR.Field7 = NULL Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
	    Else Cast(dbo.sp_Get_ReportingQty(Cast(Left(RDR.Field7,CharIndex(' ',RDR.Field7)-1) As Decimal(18,6)), UOM1_Conversion)AS NVarChar)+ ' ' + Cast(UOM.Description AS NVarChar)            
		  End
   When 'UOM2' Then 
			 	Case   
			    When RDR.Field7 = '' Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
			    When RDR.Field7 = NULL Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
			    Else Cast(dbo.sp_Get_ReportingQty(Cast(Left(RDR.Field7,CharIndex(' ',RDR.Field7)-1) As Decimal(18,6)), UOM2_Conversion) AS NVarChar)+ ' ' + Cast(UOM.Description AS NVarChar)   
				  End
			End,   				
 "Conversion Factor" = 
			Case   
			 When RDR.Field7 = '' Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
			 When RDR.Field7 = NULL Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
			 Else Cast(Cast(Left(RDR.Field7,CharIndex(' ',RDR.Field7)-1) * Items.ConversionFactor AS Decimal(18,6)) As NVarChar) + ' ' + Cast(ConversionTable.ConversionUnit As NVarChar)
			End,
 "Reporting UOM" = 
			Case   
			 When RDR.Field7 = '' Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
			 When RDR.Field7 = NULL Then Cast(Cast(0 As Decimal(18,6)) As NVarChar) 
			 Else Cast(dbo.sp_Get_ReportingUOMQty(@ItemCode, IsNull(Cast(Left(RDR.Field7,CharIndex(' ',RDR.Field7)-1) As Decimal(18,6)), 0)) As NVarChar)+ ' ' + Cast((Select Description From UOM Where UOM = Items.ReportingUOM) As NVarChar)    
			End,
 "Batch" = RDR.Field10,  
 "PKD" = RDR.Field11,"Expiry" =RDR.Field12,  
 "Sale Price" = RDR.Field13,"Net Value (%c)" = RDR.Field14  
From   
 Reports,ReportAbstractReceived RAR,ReportDetailReceived RDR,Items,UOM,ConversionTable,Manufacturer  
Where   
 Reports.ReportID In (Select Max(ReportID) From Reports Where ReportName = N'Sales Day Book'  
 And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Sales Day Book') Where dbo.StripDateFromTime(FromDate) = @FromDate And dbo.StripDateFromTime(ToDate) = @ToDate)  Group By CompanyId)
 And RAR.ReportID = Reports.ReportID    
 And CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)  
 And RAR.Field1 = @ItemCode  
 And Items.Product_Code = @ItemCode  
 And RAR.RecordID = RDR.RecordID    
 And RDR.Field1 <> N'InvoiceID' And RDR.Field1 <> N'SubTotal:' And RDR.Field1 <> N'GrandTotal:'   
 And   
 (Case @UOM   
  When 'Sales UOM' Then Items.UOM When 'UOM1' Then Items.UOM1     
  When 'UOM2' Then Items.UOM2   
 End) *= UOM.UOM  And  
 Items.ConversionUnit*=ConversionTable.ConversionID  
Group By   
 UOM.Description,Items.ReportingUOM,ConversionTable.ConversionUnit,  
 UOM1_Conversion,UOM2_Conversion,Reports.CompanyID,RDR.Field1,RDR.Field2,  
 RDR.Field3,RDR.Field4,RDR.Field5,RDR.Field6,RDR.Field7,RDR.Field8,RDR.Field9,  
 RDR.Field10,RDR.Field11,RDR.Field12,RDR.Field13,RDR.Field14,Items.ConversionFactor
