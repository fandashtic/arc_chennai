CREATE PROCEDURE spr_list_Itemwise_Purchase_Orders_MUOM(@PRODUCT nvarchar(15),
						   @FROMDATE DATETIME,
						   @TODATE DATETIME, @UOMDesc nvarchar(50))
AS
SELECT PODetail.PONumber, 
"PONumber" = VoucherPrefix.Prefix + CAST(POAbstract.DocumentID AS nvarchar), 
POAbstract.PODate, 
"PO Quantity" = 
			Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(PODetail.Quantity, (Select Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
				from Items Where Items.Product_Code = PoDetail.Product_Code))   
      		When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(PODetail.Quantity, (Select Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
				from Items Where Items.Product_Code = PoDetail.Product_Code))   
   			Else PODetail.Quantity
     		End,
"Pending Quantity" =
			Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(PODetail.Pending, (Select Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
				from Items Where Items.Product_Code = PoDetail.Product_Code))    
      		When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(PODetail.Pending, (Select Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
				from Items Where Items.Product_Code = PoDetail.Product_Code))    
   			Else PODetail.Pending
     		End,
"Purchase Price" = 
			Case When @UOMdesc = 'UOM1' then PODetail.PurchasePrice * (Select Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
				from Items Where Items.Product_Code = PoDetail.Product_Code)
      		When @UOMdesc = 'UOM2' then PODetail.PurchasePrice * (Select Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
				from Items Where Items.Product_Code = PoDetail.Product_Code)
   			Else PODetail.PurchasePrice
     		End,
Vendors.Vendor_Name
FROM POAbstract, PODetail, Vendors, VoucherPrefix
WHERE POAbstract.PODate BETWEEN @FROMDATE AND @TODATE
AND POAbstract.PONumber = PODetail.PONumber
AND POAbstract.VendorID = Vendors.VendorID
AND PODetail.Product_Code = @PRODUCT
AND VoucherPrefix.TranID = 'PURCHASE ORDER'
ORDER BY POAbstract.PODate, POAbstract.PONumber



