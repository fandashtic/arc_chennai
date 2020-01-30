Create procedure Sp_Get_InvoiceDetailForSR_MUOM_ITC(
	@InvoiceNo nVarchar(255),
	@CustomerType int)
as 

Declare @InvNo Integer
declare @NewEnh Integer
If not exists (select flag from tbl_merp_configabstract where screencode='RSH01')
	set @NewEnh = 0
else
Begin
	if (select flag from tbl_merp_configabstract where screencode='RSH01') = 0
		set @NewEnh =1
	else
		set @NewEnh = 0
End


Select * into #tempInvoiceDetails from dbo.sp_splitin2rows(@InvoiceNo,',')

Set @InvNo = Cast(@InvoiceNo as Integer)
if @NewEnh = 0
Begin
-- For Van Invoice
If (Select IsNull(Status,0) From InvoiceAbstract Where InvoiceID = @InvNo) & 16 <> 0
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
    "DiscountPercentage" = 0,-- MAX(DiscountPercentage), 
	"Track_Inventory" = ItemCategories.Track_Inventory, 
	"TrackPKD" = Items.TrackPKD, 
	"uom" = IsNull(InvoiceDetail.UOM,0),
	"MRP" = InvoiceDetail.MRP,
	"PurchasePrice"  = (Max(InvoiceDetail.PurchasePrice) / SUM(case when InvoiceDetail.UOMQty > 0 then Invoicedetail.UomQty else 1 end)),    
    "SalesPrice" = Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0),
	"SCHEMEID" = 0,--ISNULL(MAX(InvoiceDetail.SchemeID), 0) , 
	"SPLCATSCHEMEID" = 0,--ISNULL(MAX(InvoiceDetail.SPLCATSchemeID), 0) ,
    "FREESERIAL" = 0,--ISNULL(MAX(InvoiceDetail.FREESERIAL), '') , 
	"SPLCATSERIAL" = 0,--ISNULL(MAX(InvoiceDetail.SPLCATSERIAL), '')  ,
    "SCHEMEDISCPERCENT" = 0,--ISNULL(AVG(InvoiceDetail.SchemeDiscPercent), 0) , 
	"SCHEMEDISCAMOUNT" = 0,--ISNULL(SUM(InvoiceDetail.SchemeDiscAmount), 0) ,
    "SPLCATDISCPERCENT" = 0,-- ISNULL(AVG(InvoiceDetail.SPLCATDiscPercent), 0) , 
	"SPLCATDISCAMOUNT" = 0,--ISNULL(SUM(InvoiceDetail.SPLCATDiscAmount), 0) ,
    "SPECIALCATEGORYSCHEME" = ISNULL(MAX(InvoiceDetail.SpecialCategoryScheme), 0) ,
	"PTS" = ISNULL(MAX(BP.PTS), 0) ,
    "PTR" = ISNULL(MAX(BP.PTR), 0) ,
    "ECP" = ISNULL(MAX(BP.ECP), 0) ,
    "Company_Price" = ISNULL(MAX(BP.Company_Price), 0) ,
	"ApplicableOn" = ISNULL(MAX(InvoiceDetail.TaxSuffAPPLICABLEON), 0) ,
    "ParTOff" = ISNULL(MAX(InvoiceDetail.TaxSuffPartOff), 0) ,
    "TaxID" = MAX(InvoiceDetail.TaxID),
	Isnull(InvoiceDetail.OtherCG_Item,0) as  OtherCG_Item,
	"GroupID" = (Select IsNull(GroupID, 0) From v_mERP_ItemWithCG Where Product_Code = InvoiceDetail.Product_Code),
    "TAXONSALES" = MAX(Items.TOQ_Sales),
	"Serial" = InvoiceDetail.Serial,
	"PendingQty" = Sum(isnull(InvoiceDetail.PendingQty,0))
    From InvoiceDetail, Batch_Products BP , Items, ItemCategories,#tempInvoiceDetails, VanStatementDetail VSD
	WHERE InvoiceDetail.InvoiceID =  #tempInvoiceDetails.itemvalue AND 
	Isnull(InvoiceDetail.Flagword,0) <> 1 And
	InvoiceDetail.Product_Code = Items.Product_Code AND 
	BP.Batch_Code = VSD.Batch_Code And
	VSD.ID = InvoiceDetail.Batch_Code AND 
	Items.CategoryID = ItemCategories.CategoryID
    GROUP BY InvoiceDetail.Product_Code, Items.ProductName,
    InvoiceDetail.Batch_Number, InvoiceDetail.UOMPrice, InvoiceDetail.FlagWord, 
    Items.ProductName, Items.Track_Batches, ItemCategories.Price_Option, 
    Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0), 
    ItemCategories.Track_Inventory, Items.TrackPKD, InvoiceDetail.UOM,InvoiceDetail.MRP,InvoiceDetail.Serial,InvoiceDetail.OtherCG_Item 
	order by InvoiceDetail.Serial
Else -- Non Van Invoice
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
    "DiscountPercentage" = 0,--MAX(DiscountPercentage), 
	"Track_Inventory" = ItemCategories.Track_Inventory, 
	"TrackPKD" = Items.TrackPKD, 
	"uom" = IsNull(InvoiceDetail.UOM,0),
	"MRP" = InvoiceDetail.MRP,
	"PurchasePrice"  = (Max(InvoiceDetail.PurchasePrice) / SUM(case when InvoiceDetail.UOMQty > 0 then Invoicedetail.UomQty else 1 end)),    
    "SalesPrice" = Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0),
	"SCHEMEID" = 0,-- ISNULL(MAX(InvoiceDetail.SchemeID), 0) , 
	"SPLCATSCHEMEID" = 0,-- ISNULL(MAX(InvoiceDetail.SPLCATSchemeID), 0) ,
    "FREESERIAL" = 0,--ISNULL(MAX(InvoiceDetail.FREESERIAL), '') , 
	"SPLCATSERIAL" = 0,--ISNULL(MAX(InvoiceDetail.SPLCATSERIAL), '')  ,
    "SCHEMEDISCPERCENT" = 0,-- ISNULL(AVG(InvoiceDetail.SchemeDiscPercent), 0) , 
	"SCHEMEDISCAMOUNT" = 0,-- ISNULL(SUM(InvoiceDetail.SchemeDiscAmount), 0) ,
    "SPLCATDISCPERCENT" = 0,-- ISNULL(AVG(InvoiceDetail.SPLCATDiscPercent), 0) , 
	"SPLCATDISCAMOUNT" = 0,-- ISNULL(SUM(InvoiceDetail.SPLCATDiscAmount), 0) ,
    "SPECIALCATEGORYSCHEME" =  ISNULL(MAX(InvoiceDetail.SpecialCategoryScheme), 0) ,
	"PTS" = ISNULL(MAX(BP.PTS), 0) ,
    "PTR" = ISNULL(MAX(BP.PTR), 0) ,
    "ECP" = ISNULL(MAX(BP.ECP), 0) ,
    "Company_Price" = ISNULL(MAX(BP.Company_Price), 0) ,
	"ApplicableOn" = ISNULL(MAX(InvoiceDetail.TaxSuffAPPLICABLEON), 0) ,
    "ParTOff" = ISNULL(MAX(InvoiceDetail.TaxSuffPartOff), 0) ,
    "TaxID" = MAX(InvoiceDetail.TaxID),
	Isnull(InvoiceDetail.OtherCG_Item,0) as  OtherCG_Item,
	"GroupID" = (Select IsNull(GroupID, 0) From v_mERP_ItemWithCG Where Product_Code = InvoiceDetail.Product_Code),
	"TAXONSALES" = MAX(InvoiceDetail.TAXONQTY),
	"Serial" = InvoiceDetail.Serial,
	"PendingQty" = Sum(isnull(InvoiceDetail.PendingQty,0))
    From InvoiceDetail, Batch_Products BP , Items, ItemCategories,#tempInvoiceDetails
	WHERE InvoiceDetail.InvoiceID =  #tempInvoiceDetails.itemvalue AND 
	Isnull(InvoiceDetail.Flagword,0) <> 1 And
	InvoiceDetail.Product_Code = Items.Product_Code AND 
	BP.Batch_Code = InvoiceDetail.Batch_Code AND 
	Items.CategoryID = ItemCategories.CategoryID 	
    GROUP BY InvoiceDetail.Product_Code, Items.ProductName,
    InvoiceDetail.Batch_Number, InvoiceDetail.UOMPrice, InvoiceDetail.FlagWord, 
    Items.ProductName, Items.Track_Batches, ItemCategories.Price_Option, 
    Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0), 
    ItemCategories.Track_Inventory, Items.TrackPKD, InvoiceDetail.UOM,InvoiceDetail.MRP,InvoiceDetail.Serial,InvoiceDetail.OtherCG_Item 
	order by InvoiceDetail.Serial
End
else
Begin
-- For Van Invoice
If (Select IsNull(Status,0) From InvoiceAbstract Where InvoiceID = @InvNo) & 16 <> 0
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
    "DiscountPercentage" = 0,-- MAX(DiscountPercentage), 
	"Track_Inventory" = ItemCategories.Track_Inventory, 
	"TrackPKD" = Items.TrackPKD, 
	"uom" = IsNull(InvoiceDetail.UOM,0),
	"MRP" = InvoiceDetail.MRP,
	"PurchasePrice"  = (Max(InvoiceDetail.PurchasePrice) / SUM(case when InvoiceDetail.UOMQty > 0 then Invoicedetail.UomQty else 1 end)),    
    "SalesPrice" = Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0),
	"SCHEMEID" = 0,--ISNULL(MAX(InvoiceDetail.SchemeID), 0) , 
	"SPLCATSCHEMEID" = 0,--ISNULL(MAX(InvoiceDetail.SPLCATSchemeID), 0) ,
    "FREESERIAL" = 0,--ISNULL(MAX(InvoiceDetail.FREESERIAL), '') , 
	"SPLCATSERIAL" = 0,--ISNULL(MAX(InvoiceDetail.SPLCATSERIAL), '')  ,
    "SCHEMEDISCPERCENT" = 0,--ISNULL(AVG(InvoiceDetail.SchemeDiscPercent), 0) , 
	"SCHEMEDISCAMOUNT" = 0,--ISNULL(SUM(InvoiceDetail.SchemeDiscAmount), 0) ,
    "SPLCATDISCPERCENT" = 0,-- ISNULL(AVG(InvoiceDetail.SPLCATDiscPercent), 0) , 
	"SPLCATDISCAMOUNT" = 0,--ISNULL(SUM(InvoiceDetail.SPLCATDiscAmount), 0) ,
    "SPECIALCATEGORYSCHEME" = ISNULL(MAX(InvoiceDetail.SpecialCategoryScheme), 0) ,
	"PTS" = ISNULL(MAX(BP.PTS), 0) ,
    "PTR" = ISNULL(MAX(BP.PTR), 0) ,
    "ECP" = ISNULL(MAX(BP.ECP), 0) ,
    "Company_Price" = ISNULL(MAX(BP.Company_Price), 0) ,
	"ApplicableOn" = ISNULL(MAX(InvoiceDetail.TaxSuffAPPLICABLEON), 0) ,
    "ParTOff" = ISNULL(MAX(InvoiceDetail.TaxSuffPartOff), 0) ,
    "TaxID" = MAX(InvoiceDetail.TaxID),
	Isnull(InvoiceDetail.OtherCG_Item,0) as  OtherCG_Item,
	"GroupID" = (Select IsNull(GroupID, 0) From v_mERP_ItemWithCG Where Product_Code = InvoiceDetail.Product_Code),
    "TAXONSALES" = MAX(Items.TOQ_Sales),
	"Serial" = InvoiceDetail.Serial,
	"PendingQty" = Sum(isnull(InvoiceDetail.PendingQty,0)) 
    From InvoiceDetail, Batch_Products BP , Items, ItemCategories,#tempInvoiceDetails, VanStatementDetail VSD
	WHERE InvoiceDetail.InvoiceID =  #tempInvoiceDetails.itemvalue AND 
	Isnull(InvoiceDetail.Flagword,0) <> 1 And
	InvoiceDetail.Product_Code = Items.Product_Code AND 
	BP.Batch_Code = VSD.Batch_Code And
	VSD.ID = InvoiceDetail.Batch_Code AND 
	Items.CategoryID = ItemCategories.CategoryID
    GROUP BY InvoiceDetail.Product_Code, Items.ProductName,
    InvoiceDetail.Batch_Number, InvoiceDetail.UOMPrice, InvoiceDetail.FlagWord, 
    Items.ProductName, Items.Track_Batches, ItemCategories.Price_Option, 
    Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0), 
    ItemCategories.Track_Inventory, Items.TrackPKD, InvoiceDetail.UOM,InvoiceDetail.MRP,InvoiceDetail.Serial,InvoiceDetail.OtherCG_Item 
	order by InvoiceDetail.Serial
Else -- Non Van Invoice
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
    "DiscountPercentage" = 0,--MAX(DiscountPercentage), 
	"Track_Inventory" = ItemCategories.Track_Inventory, 
	"TrackPKD" = Items.TrackPKD, 
	"uom" = IsNull(InvoiceDetail.UOM,0),
	"MRP" = InvoiceDetail.MRP,
	"PurchasePrice"  = (Max(InvoiceDetail.PurchasePrice) / SUM(case when InvoiceDetail.UOMQty > 0 then Invoicedetail.UomQty else 1 end)),    
    "SalesPrice" = Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0),
	"SCHEMEID" = 0,-- ISNULL(MAX(InvoiceDetail.SchemeID), 0) , 
	"SPLCATSCHEMEID" = 0,-- ISNULL(MAX(InvoiceDetail.SPLCATSchemeID), 0) ,
    "FREESERIAL" = 0,--ISNULL(MAX(InvoiceDetail.FREESERIAL), '') , 
	"SPLCATSERIAL" = 0,--ISNULL(MAX(InvoiceDetail.SPLCATSERIAL), '')  ,
    "SCHEMEDISCPERCENT" = 0,-- ISNULL(AVG(InvoiceDetail.SchemeDiscPercent), 0) , 
	"SCHEMEDISCAMOUNT" = 0,-- ISNULL(SUM(InvoiceDetail.SchemeDiscAmount), 0) ,
    "SPLCATDISCPERCENT" = 0,-- ISNULL(AVG(InvoiceDetail.SPLCATDiscPercent), 0) , 
	"SPLCATDISCAMOUNT" = 0,-- ISNULL(SUM(InvoiceDetail.SPLCATDiscAmount), 0) ,
    "SPECIALCATEGORYSCHEME" =  ISNULL(MAX(InvoiceDetail.SpecialCategoryScheme), 0) ,
	"PTS" = ISNULL(MAX(BP.PTS), 0) ,
    "PTR" = ISNULL(MAX(BP.PTR), 0) ,
    "ECP" = ISNULL(MAX(BP.ECP), 0) ,
    "Company_Price" = ISNULL(MAX(BP.Company_Price), 0) ,
	"ApplicableOn" = ISNULL(MAX(InvoiceDetail.TaxSuffAPPLICABLEON), 0) ,
    "ParTOff" = ISNULL(MAX(InvoiceDetail.TaxSuffPartOff), 0) ,
    "TaxID" = MAX(InvoiceDetail.TaxID),
	Isnull(InvoiceDetail.OtherCG_Item,0) as  OtherCG_Item,
	"GroupID" = (Select IsNull(GroupID, 0) From v_mERP_ItemWithCG Where Product_Code = InvoiceDetail.Product_Code),
    "TAXONSALES" = MAX(InvoiceDetail.TAXONQTY),
	"Serial" = InvoiceDetail.Serial,
	"PendingQty" = Sum(isnull(InvoiceDetail.PendingQty,0)) 
    From InvoiceDetail, Batch_Products BP , Items, ItemCategories,#tempInvoiceDetails
	WHERE InvoiceDetail.InvoiceID =  #tempInvoiceDetails.itemvalue AND 
	Isnull(InvoiceDetail.Flagword,0) <> 1 And
	InvoiceDetail.Product_Code = Items.Product_Code AND 
	BP.Batch_Code = InvoiceDetail.Batch_Code AND 
	Items.CategoryID = ItemCategories.CategoryID 	
    GROUP BY InvoiceDetail.Product_Code, Items.ProductName,
    InvoiceDetail.Batch_Number, InvoiceDetail.UOMPrice, InvoiceDetail.FlagWord, 
    Items.ProductName, Items.Track_Batches, ItemCategories.Price_Option, 
    Isnull(Case @CustomerType When 1 Then BP.PTS When 2 Then BP.PTR ELSE BP.Company_Price End,0), 
    ItemCategories.Track_Inventory, Items.TrackPKD, InvoiceDetail.UOM,InvoiceDetail.MRP,InvoiceDetail.Serial,InvoiceDetail.OtherCG_Item 
	order by InvoiceDetail.Serial

End
