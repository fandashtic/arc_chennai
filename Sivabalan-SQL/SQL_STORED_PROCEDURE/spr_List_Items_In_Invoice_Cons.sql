CREATE Procedure spr_List_Items_In_Invoice_Cons      
(      
 @INVOICEID NVarChar(50),      
 @UOMDesc NVarChar(30),      
 @UnUsed1 DateTime,        
 @UnUsed2 DateTime        
)      
As      
  Declare  @CIDRpt As NVarChar(50)      
  Declare  @CIDSetUp As NVarChar(50)      
      
  Select @CIDSetUp=RegisteredOwner From Setup       
  Select @CIDRpt=Right(@INVOICEID,Len(@CIDSetUp))      
  
  If @CIDRpt <>@CIDSetUp      
   Begin      
    Select      
     RDR.Field1, "Item Code" = RDR.Field1, "Item Name" = RDR.Field2,      
     "Batch" = RDR.Field3,"Quantity" = RDR.Field4,      
     "Volume" =Cast(      
      Case      
       When @UOMdesc = N'UOM1' Then dbo.sp_Get_ReportingQty(SUM(Cast(RDR.Field5 As Decimal(18,6))), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)      
       When @UOMdesc = N'UOM2' Then dbo.sp_Get_ReportingQty(SUM(Cast(RDR.Field5 As Decimal(18,6))), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)      
       Else SUM(Cast(RDR.Field5 As Decimal(18,6)))      
      End      
     As NVarChar),      
     "Sale Price (%c)" = RDR.Field6,      
     "Sale Tax" = RDR.Field7,"Tax Suffered (%c)" = RDR.Field8,"Discount (%c)" = RDR.Field9,      
     "STCredit (%c)" = RDR.Field10, "Total (%c)" =RDR.Field11,"Forum Code" = RDR.Field12,      
     "Tax Suffered Value (%c)" =  RDR.Field13,      
     "Sales Tax Value (%c)" = RDR.Field14      
    From      
     ReportDetailReceived RDR,Items,Reports      
    Where      
     RDR.RecordID =@INVOICEID    
 				And Reports.ReportID In (Select MAX(ReportID) From Reports Where ReportName = N'Invoices'    
					And	ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Invoices') Where FromDate = dbo.StripDateFromTime(@UnUsed1) And ToDate = dbo.StripDateFromTime(@UnUsed2)))    
	    And RDR.Field1=Items.Product_Code    
     And RDR.Field1 <> N'Item Code' And RDR.Field2 <> N'Item Name' And RDR.Field3 <> N'Batch'        
    Group By      
     RDR.Field1,RDR.Field2,RDR.Field3,RDR.Field4,RDR.Field6,RDR.Field7,RDR.Field8,RDR.Field9,      
     RDR.Field10,RDR.Field11,RDR.Field12,RDR.Field13,RDR.Field14,Items.UOM1_Conversion,Items.UOM2_Conversion      
   End      
  Else      
   Begin      
    Declare @INVID As NVarChar(50)      
    Select @INVID=Left(@INVOICEID,Len(@INVOICEID)-Len(@CIDSetUp))      
      
    DECLARE @ADDNDIS AS Decimal(18,6)            
    DECLARE @TRADEDIS AS Decimal(18,6)            
      
    SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract            
    WHERE InvoiceID = @INVID            
      
    SELECT        
     InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,             
     "Item Name" = Items.ProductName, "Batch" = InvoiceDetail.Batch_Number,            
     "Quantity" = SUM(InvoiceDetail.Quantity),      
     "Volume" = Cast((        
      Case       
       When @UOMdesc = N'UOM1' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)          
       When @UOMdesc = N'UOM2' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)          
       Else SUM(InvoiceDetail.Quantity)        
      End) as NVarChar),          
     "Sale Price (%c)" = ISNULL(InvoiceDetail.SalePrice, 0),             
     "Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS NVarChar) + N'%',            
     "Tax Suffered" = CAST(ISNULL(MAX(InvoiceDetail.TaxSuffered), 0) AS NVarChar) + N'%',            
     "Discount" = CAST(SUM(DiscountPercentage) AS NVarChar) + N'%',            
     "STCredit (%c)" =             
      Round((SUM(InvoiceDetail.TaxCode) / 100.00) *            
      ((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -             
      ((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *            
      (@ADDNDIS / 100.00)) +            
      (((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -             
      ((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *            
      (@TRADEDIS / 100.00))), 2),            
     "Total (%c)" = Round(SUM(Amount),2),"Forum Code" = Items.Alias,           
     "Tax Suffered Value (%c)" = IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),      
     "Sales Tax Value (%c)" = Isnull(Sum(STPayable + CSTPayable), 0)      
    FROM       
     InvoiceDetail, Items            
    WHERE         
     InvoiceDetail.InvoiceID = @INVID AND            
     InvoiceDetail.Product_Code = Items.Product_Code            
    GROUP BY       
     InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,             
     InvoiceDetail.SalePrice, Items.Alias,UOM1_Conversion,UOM2_Conversion          
   End      


