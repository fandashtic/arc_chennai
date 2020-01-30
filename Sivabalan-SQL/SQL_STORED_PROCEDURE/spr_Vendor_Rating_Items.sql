CREATE Procedure spr_Vendor_Rating_Items (@Vendor nvarchar(20),
					  @FromDate Datetime,
					  @ToDate Datetime)
As

Select Distinct GRNDetail.Product_Code, 
"Item Code" = GRNDetail.Product_Code,
"Item Name" = Items.ProductName,
"Quantity Supplied" = Isnull(sum(case Batch_Products.Free
		when 0 then
		IsNull(Batch_Products.QuantityReceived,0)
	     	End),0),
"Free Quantity" = Isnull(sum(case Batch_Products.Free
		when 1 then
		IsNull(Batch_Products.QuantityReceived,0)
	     	End),0),
"Value" = IsNull(sum(case Batch_Products.Free
		when 0 then
		IsNull((Batch_Products.QuantityReceived),0)
	     	End * Batch_Products.PurchasePrice),0)

From GRNDetail, GRNAbstract, Items,Batch_Products Where
GRNAbstract.VendorID = @Vendor And
GRNDetail.GRNID = GRNAbstract.GRNID And
IsNull(GRNAbstract.GRNStatus, 0) & 128 = 0 And  
IsNull(GRNAbstract.GRNStatus, 0) & 32 = 0 And  
GRNAbstract.GRNDate Between @FromDate And @ToDate And
GRNDetail.Product_Code = Items.Product_Code
And Batch_Products.Product_Code = Items.Product_Code
And GRNAbstract.GRNID = Batch_Products.GRN_ID
group by GRNDetail.Product_Code,Items.ProductName







