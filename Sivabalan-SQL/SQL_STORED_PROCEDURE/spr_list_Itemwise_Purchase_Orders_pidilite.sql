CREATE procedure [dbo].[spr_list_Itemwise_Purchase_Orders_pidilite](@PRODUCT nvarchar(15),  
         @FROMDATE DATETIME,  
         @TODATE DATETIME,@UOMDesc nvarchar(50))  
AS  
SELECT PODetail.PONumber,   
"PONumber" = VoucherPrefix.Prefix + CAST(POAbstract.DocumentID AS nvarchar),POAbstract.PODate,   
"PO Quantity" =   
   Case When @UOMdesc = 'UOM1' then PODetail.Quantity/ (Select Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End  
    			from Items Where Items.Product_Code = PoDetail.Product_Code)     
        When @UOMdesc = 'UOM2' then PODetail.Quantity/ (Select Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End  
				from Items Where Items.Product_Code = PoDetail.Product_Code)     
       	when @UOMdesc = 'Conversion Factor' then PODetail.Quantity *(Select Case When IsNull(Items.ConversionFactor, 0) = 0 Then 1 Else Items.ConversionFactor End   
	    		from Items Where Items.Product_Code = PoDetail.Product_Code)  
      	When @UOMdesc = 'Reporting Uom' Then  PODetail.Quantity/ (Select Case When IsNull(Items.ReportingUnit, 0) = 0 Then 1 Else Items.ReportingUnit End  
				from Items Where Items.Product_Code = PoDetail.Product_Code)   
      	Else PODetail.Quantity  
       End,  
"Pending Quantity" =  
   Case When @UOMdesc = 'UOM1' then PODetail.Pending/ (Select Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End  
    			from Items Where Items.Product_Code = PoDetail.Product_Code)      
        When @UOMdesc = 'UOM2' then PODetail.Pending/ (Select Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End  
    			from Items Where Items.Product_Code = PoDetail.Product_Code)      
       	when @UOMdesc = 'Conversion Factor' then PODetail.Pending *(Select Case When IsNull(Items.ConversionFactor, 0) = 0 Then 1 Else Items.ConversionFactor End   
    			from Items Where Items.Product_Code = PoDetail.Product_Code)  
      	When @UOMdesc = 'Reporting Uom' Then  PODetail.Pending/(Select Case When IsNull(Items.ReportingUnit, 0) = 0 Then 1 Else Items.ReportingUnit End  
				from Items Where Items.Product_Code = PoDetail.Product_Code)    
      	Else PODetail.Pending  
       End,  
"Purchase Price" =   
   Case When @UOMdesc = 'UOM1' then PODetail.PurchasePrice * (Select Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End  
    			from Items Where Items.Product_Code = PoDetail.Product_Code)  
        When @UOMdesc = 'UOM2' then PODetail.PurchasePrice * (Select Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End  
    			from Items Where Items.Product_Code = PoDetail.Product_Code)  
       	when @UOMdesc = 'Conversion Factor' then PODetail.PurchasePrice *(Select Case When IsNull(Items.ConversionFactor, 0) = 0 Then 1 Else Items.ConversionFactor End   
    			from Items Where Items.Product_Code = PoDetail.Product_Code)  
      	When @UOMdesc = 'Reporting Uom' Then  (PODetail.PurchasePrice * (Select ITems.ReportingUnit From Items Where Items.Product_Code = PoDetail.Product_Code))   
      	Else PODetail.PurchasePrice  
       End,  
Vendors.Vendor_Name,"Division"=Brand.BrandName  
FROM POAbstract, PODetail, Vendors, VoucherPrefix,Brand  
WHERE POAbstract.PODate BETWEEN @FROMDATE AND @TODATE  
AND POAbstract.PONumber = PODetail.PONumber  
AND POAbstract.VendorID = Vendors.VendorID  
AND PODetail.Product_Code = @PRODUCT  
AND VoucherPrefix.TranID = 'PURCHASE ORDER'  
AND isnull(POAbstract.Status,0) & 192 = 0  
AND POAbstract.BrandID*=Brand.BrandID  
ORDER BY POAbstract.PODate, POAbstract.PONumber
