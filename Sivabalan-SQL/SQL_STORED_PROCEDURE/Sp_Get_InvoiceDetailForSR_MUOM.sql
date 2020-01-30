Create procedure [dbo].[Sp_Get_InvoiceDetailForSR_MUOM](
	@InvoiceNo nVarchar(255),
	@CustomerType int)
as 

Select * into #tempInvoiceDetails from dbo.sp_splitin2rows(@InvoiceNo,',')

Select InvoiceDetail.Product_Code, 
	"Quantity" = SUM(InvoiceDetail.UOMQty),
    "UOMPrice" = InvoiceDetail.UOMPrice, 
	"Batch_Number" = InvoiceDetail.Batch_Number, 
	"Flagword" = InvoiceDetail.Flagword,
    "Batch_Code" = 0, 
	"TaxCode" = MAX(InvoiceDetail.TaxCode), 
	"TaxCode2" = MAX(InvoiceDetail.TaxCode2), 
	"TaxSuffered" = MAX(InvoiceDetail.TaxSuffered), 
	"TaxSuffered2" = MAX(TaxSuffered2), 
    "ProductName" = Items.ProductName, 
	"Track_Batches" = Items.Track_Batches, 
	"Price_Option" = ItemCategories.Price_Option, 
    "DiscountPercentage" = MAX(DiscountPercentage), 
	"Track_Inventory" = ItemCategories.Track_Inventory, 
	"TrackPKD" = Items.TrackPKD, 
	"uom" = IsNull(InvoiceDetail.UOM,0),
	"MRP" = InvoiceDetail.MRP,
	"PurchasePrice"  = (Max(InvoiceDetail.PurchasePrice) / SUM(InvoiceDetail.UOMQty)),
    "SalesPrice" = Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0),
	"SCHEMEID" = ISNULL(MAX(InvoiceDetail.SchemeID), 0) , 
	"SPLCATSCHEMEID" = ISNULL(MAX(InvoiceDetail.SPLCATSchemeID), 0) ,
    "FREESERIAL" = ISNULL(MAX(InvoiceDetail.FREESERIAL), '') , 
	"SPLCATSERIAL" = ISNULL(MAX(InvoiceDetail.SPLCATSERIAL), '')  ,
    "SCHEMEDISCPERCENT" = ISNULL(AVG(InvoiceDetail.SchemeDiscPercent), 0) , 
	"SCHEMEDISCAMOUNT" = ISNULL(SUM(InvoiceDetail.SchemeDiscAmount), 0) ,
    "SPLCATDISCPERCENT" = ISNULL(AVG(InvoiceDetail.SPLCATDiscPercent), 0) , 
	"SPLCATDISCAMOUNT" = ISNULL(SUM(InvoiceDetail.SPLCATDiscAmount), 0) ,
    "SPECIALCATEGORYSCHEME" = ISNULL(MAX(InvoiceDetail.SpecialCategoryScheme), 0) ,
	"PTS" = ISNULL(MAX(BP.PTS), 0) ,
    "PTR" = ISNULL(MAX(BP.PTR), 0) ,
    "ECP" = ISNULL(MAX(BP.ECP), 0) ,
    "Company_Price" = ISNULL(MAX(BP.Company_Price), 0) ,
	"ApplicableOn" = ISNULL(MAX(InvoiceDetail.TaxSuffAPPLICABLEON), 0) ,
    "ParTOff" = ISNULL(MAX(InvoiceDetail.TaxSuffPartOff), 0) ,
    "TaxID" = MAX(InvoiceDetail.TaxID)
    From InvoiceDetail
	Inner Join #tempInvoiceDetails on InvoiceDetail.InvoiceID =  #tempInvoiceDetails.itemvalue
	Inner Join Items on InvoiceDetail.Product_Code = Items.Product_Code
	Inner Join ItemCategories on Items.CategoryID = ItemCategories.CategoryID
	Right Join Batch_Products BP on BP.Batch_Code = InvoiceDetail.Batch_Code
	--WHERE InvoiceDetail.InvoiceID =  #tempInvoiceDetails.itemvalue AND 
	--InvoiceDetail.Product_Code = Items.Product_Code AND 
	--BP.Batch_Code =* InvoiceDetail.Batch_Code AND 
	--Items.CategoryID = ItemCategories.CategoryID
    GROUP BY InvoiceDetail.Product_Code, Items.ProductName,
    InvoiceDetail.Batch_Number, InvoiceDetail.UOMPrice, InvoiceDetail.FlagWord, 
    Items.ProductName, Items.Track_Batches, ItemCategories.Price_Option, 
    Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0), 
    ItemCategories.Track_Inventory, Items.TrackPKD, InvoiceDetail.UOM,InvoiceDetail.MRP,InvoiceDetail.Serial 
	order by InvoiceDetail.Serial
