Create procedure spr_Vat_Disallowed_Report_upload ( @FromDate Datetime, @ToDate Datetime, 
	@CategoryLevel nvarchar(100)
    , @TradeDiscount nvarchar(50), @UOM nvarchar(100) = 'n/a')
as 
Declare @level Int, @voucherprefix nvarchar(100), @LevelOfReport nvarchar(100)
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Declare @DayClosed Int
set dateformat dmy 
 
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
Select Top 1 @WDCode = RegisteredOwner From Setup    

Select @DayClosed = 0
If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') = 1
Begin
    If ((Select dbo.StripTimeFromDate(LastInventoryUpload) From Setup) >=  dbo.StripTimeFromDate(@ToDate))
    Set @DayClosed = 1
End

/* Report should be generated only if the last day of the month is Closed */
If @DayClosed = 0
    Goto OvernOut

If @CompaniesToUploadCode='ITC001'  
 Set @WDDest= @WDCode  
Else  
Begin  
 Set @WDDest= @WDCode  
 Set @WDCode= @CompaniesToUploadCode  
End  
select @voucherprefix = prefix from voucherprefix where tranId = 'Invoice'
If @CategoryLevel = 'System SKU'
    select @level = 5
Else
    select @level = hierarchyId from Itemhierarchy where hierarchyName = @CategoryLevel 

--select @LevelOfReport '@LevelOfReport', @CategoryLevel '@CategoryLevel', @voucherprefix '@voucherprefix', @level '@level' 
--If @LevelOfReport = 'Detail' and ( @level = 2 or @level = 3 or @level = 4 )
--Begin 
----select x.[WD Code1], x.[WD Code], x.[WD Dest], x.[From Date], x.[To Date], x.[Division], x.[Sub Category], x.[Market SKU], x.[Item Code],	x.[Item Name], x.[Batch], x.[Sales Invoice Number],
----    x.[Invoice Reference], x.[Invoice Date], x.[Invoice Type],x.[UOM], x.[Quantity], x.[Price Before Discount],x.[Discount amount],x.[Trade Discount],x.[Price After Discount], x.[Sales Amount], 
----    x.[VAT Percentage], x.[Output VAT], x.[Purchase Bill Number], x.[Bill Reference], x.[Bill Date], x.[Vendor Code], x.[Vendor Name],x.[Purchase Price],x.[Purchase Amount],x.[VAT Percentage], x.[Input VAT], x.[VAT Disallowed]
--	select x.* from 
--    (select N'' [WD Code1], N'' [WD Code], N'' [WD Dest], N'' [From Date], N'' [To Date], N'' [Division], N'' [Sub Category], N'' [Market SKU], N'' [Item Code],	N'' [Item Name], N'' [Batch], N'' [Sales Invoice Number],
--    N'' [Invoice Reference], N'' [Invoice Date], N'' [Invoice Type],N'' [UOM], 0 [Quantity], 0 [Price Before Discount],0 [Discount Amount],0 [Trade Discount],0 [Price After Discount], 0 [Sales Amount], 
--    0 [Output VAT Percentage], 0 [Output VAT], N'' [Purchase Bill Number], N'' [Bill Reference], N'' [Bill Date], N'' [Vendor Code], N'' [Vendor Name],0 [Purchase Price],0 [Purchase Amount],0 [Input VAT Percentage], 0 [Input VAT],0 [VAT Disallowed]) as x
--	where x.quantity > 0 
--End
--If @LevelOfReport = 'Detail' and @UOM = 'N/A' 
--Begin 
--    select @UOM = 'Base Uom'
--End
set @LevelOfReport = 'Summary'
Create Table #Items 
( 
Prd_code NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
DivId Int, SubCtgId Int, MktSKUId Int , 
Uom int, conversionfactor Decimal(18, 6), conversionunit Int, 
UOM1 Int, Uom1_Conversion Decimal(18, 6), Uom2 Int, Uom2_Conversion Decimal(18, 6) ) 

--#Items - to save the Details of all the Items
Insert Into #Items 
Select distinct Itm.product_code, ItcDiv.CategoryId DivId,
ItcSubC.CategoryId SubCId, 
ItcMkt.CategoryId MktId, 
Itm.uom, Itm.Conversionfactor, Itm.conversionunit,  
Itm.uom1, Itm.uom1_Conversion, Itm.uom2, Itm.uom2_conversion
From ItemCategories ItcDiv 
Join ItemCategories ItcSubC on ItcDiv.CategoryId = ItcSubC.ParentId 
Join ItemCategories ItcMkt on ItcSubC.CategoryId = ItcMkt.ParentId  
Join Items Itm on ItcMkt.CategoryId = Itm.CategoryId 


Select I.InvoiceId, I.product_code, I.virtualBatch, I.InvoiceNo	
    , I.DivId, I.SubCtgId, I.MktSKUId
    , I.Docreference, I.InvoiceDate, I.flagword 
    , I.AdditionalDiscount
    , convert(varchar(20), (Case when I.InvoiceType In (1, 3 ) then 'Sales'	
                                when I.InvoiceType In (2 ) then 'Retail Invoice'
                                when I.InvoiceType In (4 ) then 
                                    Case when status & 32 = 0 then 'Sale Return-Saleable' 
                                        when status & 32 <> 0 then 'Sale Return-Damage' 
                                    End
                            End) ) 'Invoicetype'	
    , I.InvoiceType 'InvoiceTypeNo'	
    , convert(varchar(20), (Case when @uom = 'Base Uom' then uom.Description
                                when @uom = 'Uom 1' then uom1.Description
                                when @uom = 'Uom 2' then uom2.Description
                            end) ) 'uom'
    , convert(Decimal(18,6), ( I.Quantity 
                                * ( Case when I.InvoiceType In (1, 3) then 1  
                                    when I.InvoiceType In (4) then -1 
                                    End ))) 'qtyInBuom'
    , convert(Decimal(18,6), ((Case when @levelofreport = 'summary' then I.Quantity 
                                        when @levelofreport = 'Detail' then  				  
                                    Case when @uom = 'Base Uom' then I.Quantity 
                                         when @uom = 'Uom 1' then I.Quantity/Isnull(Uom1_Conversion,1)
                                         when @uom = 'Uom 2' then I.Quantity/Isnull(Uom2_Conversion,1)	
                                    end
                               end)
                               * (Case when I.InvoiceType In (1, 3) then 1 
                                       when I.InvoiceType In (4 ) then -1 
                                   End) ) ) 'qty'
    , convert(Decimal(18,6), (Case when @levelofreport = 'summary' then I.ptr 
                                when @levelofreport = 'Detail' then  				  
                                    Case when @uom = 'Base Uom' then I.ptr 
                                        when @uom = 'Uom 1' then (I.ptr*Uom1_Conversion)
                                        when @uom = 'Uom 2' then (I.ptr*Uom2_Conversion)
                                    end
                                end) ) 'pricebeforediscount'
    , (I.Discountvalue) 'prdDiscountamt'

    , convert(Decimal(18,6), 
            Case when @TradeDiscount = 'yes' then 
                (((I.ptr * I.Quantity) - I.Discountvalue)
                    * I.AdditionalDiscount/100)
                Else
                    0
            End )  'tradeDiscountamt'  


    , convert(Decimal(18,6),(Case when @levelofreport = 'summary' then
                                    Case when @TradeDiscount = 'yes' then 
                                        (I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) -
                                        ((((I.ptr * I.Quantity) - I.Discountvalue)
                                            * I.AdditionalDiscount/100) / (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))
                                        Else 
                                        (I.ptr - (I.Discountvalue/ (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) 
                                    end
                                when @levelofreport = 'Detail' then  	
                                    Case when @TradeDiscount = 'yes' then
                                        Case when @uom = 'Base Uom' then  
                                            (I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) -
                                            ((((I.ptr * I.Quantity) - I.Discountvalue)
                                                * I.AdditionalDiscount/100) / (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))

                                            when @uom = 'Uom 1' then 
                                                ((I.ptr*Uom1_Conversion) - (I.Discountvalue/((Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End)/Isnull(Uom1_Conversion,1)))) -
                                                ((((I.ptr * I.Quantity) - I.Discountvalue)
                                                    * I.AdditionalDiscount/100) / ((Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End)/Isnull(Uom1_Conversion,1)))

                                            when @uom = 'Uom 2' then 
                                                ((I.ptr*Uom2_Conversion) - (I.Discountvalue/((Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End)/Isnull(Uom2_Conversion,1)))) -
                                                ((((I.ptr * I.Quantity) - I.Discountvalue)
                                                    * I.AdditionalDiscount/100) / ((Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End)/Isnull(Uom2_Conversion,1)))

                                        end
                                    else
                                       Case when @uom = 'Base Uom' then (I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) 
                                           when @uom = 'Uom 1' then (I.ptr*Uom1_Conversion) - (I.Discountvalue/((Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End)/Isnull(Uom1_Conversion,1)))
                                           when @uom = 'Uom 2' then (I.ptr*Uom2_Conversion) - (I.Discountvalue/((Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End)/Isnull(Uom2_Conversion,1)))
                                       end
                                    end
                                end) ) 'priceaftdiscount'
    

    , convert(Decimal(18,6),( Case when @TradeDiscount = 'yes' then 
                                    (I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) -
                                        ((((I.ptr * I.Quantity) - I.Discountvalue)
                                            * I.AdditionalDiscount/100) / (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End)) 
                               Else 
                                    (I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) 
                               end * I.Quantity )
                              * Case when I.InvoiceType In (1, 3) then 1  
                                      when I.InvoiceType In (4) then -1 
                                End ) 'Saleamt' 		
    
    , ( Case when Customer.locality = 1 then tax.percentage Else tax.cst_percentage End) 'vatpcnt'

    , convert(Decimal(18, 6), ( Case when @TradeDiscount = 'yes' then Isnull(I.stpayable, 0) + Isnull(I.cstpayable, 0) 
                                when @TradeDiscount = 'no' then Isnull(I.stpayable, 0) + Isnull(I.cstpayable, 0) + Isnull(I.stcredit,0) 
                              End
                              * ( Case when I.InvoiceType In (1, 3) then 1  
                                        when I.InvoiceType In (4) then -1 
                                  End )))  'Salevatamt' 

    , convert(Decimal(18,6),(Case when @levelofreport = 'summary' then I.pts 
                                  when @levelofreport = 'Detail' then  				  
                                    Case when @uom = 'Base Uom' then I.pts 
                                         when @uom = 'Uom 1' then (I.pts*Uom1_Conversion)
                                         when @uom = 'Uom 2' then (I.pts*Uom2_Conversion)
                                    end
                              end)) 'purchaseprice' 
    , convert(Decimal(18,6),I.pts) 'purchasepriceInBuom' 
    , Case when I.saleprice = 0 and I.pts > 0 then 'Free Item'
        Else 'Discount Scheme'
      end 'Disallowance Type'
	, I.Status
	, I.TAXONQTY
	, I.Taxamount
	Into #tmpSales  -- Data related to Sales
    from 
	(
          Select Id.InvoiceId, Id.product_code, max(Id.Batch_code) virtualBatch, max(Id.Batch_Number) Batch_Number, Id.saleprice,  Itm.DivId, Itm.SubCtgId, Itm.MktSKUId, itm.UOM, itm.UOM1, itm.UOM2, itm.UOM1_Conversion,itm.UOM2_Conversion
		  , @voucherprefix + convert(varchar(20), Ia.DocumentId) 'InvoiceNo'	
		  , Ia.Docreference, Ia.InvoiceDate, max(Id.flagword) flagword
		  , max(Ia.AdditionalDiscount) AdditionalDiscount
		  , Ia.InvoiceType, sum(Id.Quantity) Quantity, max(Id.Saleprice) ptr, sum(Id.Discountvalue) Discountvalue 
		  , max(Id.stcredit) stcredit, max(Id.pts) pts, CustomerId, max(taxId) taxId, status
		  , max(stpayable) stpayable, max(cstpayable) cstpayable, max(amount) amount, serial,Id.TAXONQTY, Sum(Taxamount) Taxamount
		  from Invoiceabstract Ia
		  Join InvoiceDetail Id on Ia.InvoiceId = Id.InvoiceId
		  Join #Items Itm On Itm.Prd_code = ID.Product_code 
		  where dbo.StripTimeFromDate(Ia.InvoiceDate) >= @FromDate and dbo.StripTimeFromDate(Ia.InvoiceDate) <= @toDate
		  and Ia.status & 128 = 0 and Ia.Invoicetype In ( 1, 3, 4 ) 
		  group by Id.InvoiceId, Id.product_code, @voucherprefix + convert(varchar(20), Ia.DocumentId), serial 
		  , Ia.Docreference, Ia.InvoiceDate, Ia.InvoiceType, CustomerId, status, Id.saleprice ,  Itm.DivId, Itm.SubCtgId, Itm.MktSKUId
		  , itm.UOM, itm.UOM1, itm.UOM2, itm.UOM1_Conversion,itm.UOM2_Conversion,Id.TAXONQTY
        )I  -- Base level Data taken from Invoice
    Join Uom on I.uom = uom.uom Join Uom uom1 on I.uom1 = uom1.uom Join Uom uom2 on I.uom2 = uom2.uom
    Join Customer on I.CustomerId = customer.customerId
    Join tax on I.taxId = tax.tax_code 	--select * from #tmpSales

	select S.*, Case when  S.Status & 16 = 0 then BP.GRN_ID Else vanBP.GRN_ID End GRN_ID
	 ,Case when S.Status & 16 = 0 then IsNull(Bp.StockTransferID, 0) Else IsNull(vanBP.StockTransferID,0) End StockTransferID
	 ,Case when S.Status & 16 = 0 then BP.taxsuffered Else vanBP.taxsuffered End taxsuffered
	 ,Case when S.Status & 16 = 0 then BP.batch_number Else vanBP.batch_number End batch_number
	 ,Case when S.Status & 16 = 0 then BP.batch_code Else vanBP.batch_code End batch_code
	Into #tmpSalesBatch -- Getting Batch Information
 	from #tmpSales S
	Left outer Join Batch_products Bp on ( S.virtualBatch = Bp.Batch_code and S.Status & 16 = 0 )    -- Normal Sales
    Left outer Join vanStatementDetail vst on ( S.virtualBatch = vst.Id and S.Status & 16 <> 0 )	 -- van Sales
    Left outer Join Batch_products vanBP on ( vst.Batch_code = vanBp.Batch_code and S.Status & 16 <> 0 ) -- van Sales
--  select * from #tmpSalesBatch


--#SystemSKU - Purchase Data linked to Invoice data
Select SB.*, IsNull(g.DocRef, '') 'PbillNo'
, Case when Ba.DocIdReference Is not null then Ba.DocIdReference
     when SIA.Docserial Is not null then IsNull(SIA.DocPrefix, '') + convert(varchar(15), SIA.DocumentID) 
  End 'BillRef'   
, Case when Ba.BillDate Is not null then Ba.BillDate
     when SIA.DocumentDate Is not null then SIA.DocumentDate 
  End 'BillDate'   
, SIA.warehouseId 
, Ba.VendorId 
, convert(Decimal(18,6),(SB.purchasepriceInBuom* SB.qtyInBuom)) 'PurchaseAmt', SB.taxsuffered Grntaxsuffered
, convert(Decimal(18,6),(Case When SB.TAXONQTY=1 Then (SB.qtyInBuom*SB.taxsuffered) Else ((SB.purchasepriceInBuom*SB.qtyInBuom)*SB.taxsuffered/100) End)) 'purchasevatamt'
--, convert(Decimal(18,6),((SB.purchasepriceInBuom* SB.qtyInBuom)*SB.Grntaxsuffered/100) - Salevatamt) 'vatDiff' 
, (Case when Invoicetypeno In ( 1,3 ) then
            convert(Decimal(18,6),(Case When SB.TAXONQTY=1 Then (SB.qtyInBuom*SB.taxsuffered) Else ((SB.purchasepriceInBuom*SB.qtyInBuom)*SB.taxsuffered/100) End)-Salevatamt)
  when Invoicetypeno In ( 4 ) then 
            convert(Decimal(18,6),Salevatamt-(Case When SB.TAXONQTY=1 Then (SB.qtyInBuom*SB.taxsuffered) Else ((SB.purchasepriceInBuom*SB.qtyInBuom)*SB.taxsuffered/100) End))
        Else
            0
    End) 'vatDiff' 
, SB.taxsuffered 'Purchase Tax Percentage', taxtype.taxtype
Into #SystemSKU 
from #tmpSalesBatch SB 
Left outer Join Grnabstract g on IsNull(SB.Grn_Id,0) = g.GrnId
Left outer Join Billabstract ba on IsNull(g.BillId,0) = ba.BillId
Left outer Join tbl_mERP_Taxtype taxtype on IsNull(ba.taxtype, 0) = taxtype.taxId
Left outer Join StockTransferInAbstract SIA on IsNull(SB.StockTransferID,0) = SIA.Docserial 
where 
--	convert(Decimal(18,6),((S.purchasepriceInBuom* S.qtyInBuom)*Bp.Grntaxsuffered/100) - Salevatamt) > 0  
    (Case when flagword = 1 then
            Case when IsNull(taxtype.taxtype, '') Not In ( 'FLST', 'CST') then 1 
                Else
                0
            End
        when Invoicetypeno In ( 1, 3 ) and convert(Decimal(18,6),(Case When SB.TAXONQTY=1 Then (SB.qtyInBuom*SB.taxsuffered) Else ((SB.purchasepriceInBuom*SB.qtyInBuom)*SB.taxsuffered/100) End)-Salevatamt)>0 then 
            Case when IsNull(taxtype.taxtype, '') Not In ( 'FLST', 'CST') then 1 
                Else
                0
            End
        when Invoicetypeno In ( 4 ) and Convert(Decimal(18,6),Salevatamt-(Case When SB.TAXONQTY=1 Then (SB.qtyInBuom*SB.taxsuffered) Else ((SB.purchasepriceInBuom*SB.qtyInBuom)*SB.taxsuffered/100) End))>0 then
            Case when IsNull(taxtype.taxtype, '') Not In ( 'FLST', 'CST') then 1 
                Else
                0
            End
        Else
            0
    End)= 1



If @LevelOfReport = 'Detail' and @level = 5 
Begin	
    select @WDCode [WD Code1], @WDCode [WD Code], @WDDest [WD Dest], @FromDate [From Date], @ToDate [To Date]
    , ItmD.Category_name [Division], ItmS.Category_name [Sub Category], ItmM.Category_name [Market SKU]
    , Itm.product_code [Item Code],	ProductName [Item Name], Batch_Number [Batch], InvoiceNo [Sales Invoice Number]
    , Docreference [Invoice Reference], InvoiceDate [Invoice Date], Invoicetype [Invoice Type],sku.uom [UOM]
    , qty [Quantity], pricebeforediscount [Price Before Discount], prdDiscountamt [Discount Amount]
    , Case when @TradeDiscount = 'yes' then tradeDiscountamt Else 0 End [Trade Discount]   
    , priceaftdiscount [Price After Discount], Saleamt [Sales Amount], vatpcnt [Output VAT Percentage]
    , Salevatamt [Output VAT], PbillNo [Purchase Bill Number], BillRef [Bill Reference], BillDate [Bill Date]
    , Case when sku.VendorId Is not Null then sku.VendorId 
           when warehouse.warehouseId Is not Null then warehouse.warehouseId
           Else ''
      End [Vendor Code]
    , Case when vendor_Name Is not Null then vendor_Name
           when warehouse.warehouse_name Is not Null then warehouse.warehouse_name
           Else ''
      End [Vendor Name]
    , purchaseprice [Purchase Price]
    , PurchaseAmt [Purchase Amount], Grntaxsuffered [Input VAT Percentage], purchasevatamt [Input VAT]
    , vatDiff [VAT Disallowed]
    , [Purchase Tax Percentage]
    from #SystemSKU sku Join Items Itm on sku.product_code = Itm.product_code 
    Join ItemCategories ItmD on sku.DivId = ItmD.CategoryId
    Join ItemCategories ItmS on sku.SubCtgId = ItmS.CategoryId
    Join ItemCategories ItmM on sku.MktSKUId = ItmM.CategoryId
    Left outer Join vendors on sku.vendorId = vendors.vendorId 
    Left outer Join warehouse on sku.warehouseId = warehouse.warehouseId 

--	where (Case when InvoiceTypeNo In (1, 3) then 
--				Case when vatDiff > 0 then 1 Else 0 End
--			Else
--				0
--			end	) = 1
end
Else If @LevelOfReport = 'summary' and @level = 5 
begin
-- summary level Data for System-sku
    select @WDCode [WD Code1], @WDCode [WD Code], @WDDest [WD Dest], @FromDate [From Date], @ToDate [To Date]
    , ItmD.Category_name [Division], ItmS.Category_name [Sub Category], ItmM.Category_name [Market SKU]
    , Itm.product_code [Item Code], Itm.productName [Item Name], [Purchase Tax Percentage], sku.[Output VAT Percentage] [Sales Tax Percentage]
    , [Disallowance Type], sku.[Sales made Less than Input Vat], sku.[Output VAT], sku.[Input VAT], sku.[VAT Disallowed]
    from 	
    (select DivId, SubCtgId, MktSKUId, product_code, sum(Saleamt) [Sales made Less than Input Vat]
     , vatpcnt [Output VAT Percentage]
     , sum(Salevatamt) [Output VAT]
     , sum(purchasevatamt) [Input VAT], sum(vatDiff  * case Invoicetypeno when 4 then -1 else 1 end) [VAT Disallowed]
     , [Purchase Tax Percentage], [Disallowance Type]
     from #SystemSKU 
     group by DivId, SubCtgId, MktSKUId, product_code, vatpcnt, [Purchase Tax Percentage], [Disallowance Type]
     having sum(vatDiff  * case Invoicetypeno when 4 then -1 else 1 end) > 0 or [Disallowance Type] = 'Free Item'
	) sku
    Join Items Itm on sku.product_code = Itm.product_code 
    Join ItemCategories ItmD on sku.DivId = ItmD.CategoryId
    Join ItemCategories ItmS on sku.SubCtgId = ItmS.CategoryId
    Join ItemCategories ItmM on sku.MktSKUId = ItmM.CategoryId
    order by ItmD.Category_name, ItmS.Category_name, ItmM.Category_name
    , Itm.product_code--, Itm.productName

End
Else If @LevelOfReport = 'summary' and @level = 4 
begin
-- summary level Data for market-sku
    select @WDCode [WD Code1], @WDCode [WD Code], @WDDest [WD Dest], @FromDate [From Date], @ToDate [To Date]
    , ItmD.Category_name [Division], ItmS.Category_name [Sub Category], ItmM.Category_name [Market SKU]
    , sku.[Output VAT Percentage] [Sales Tax Percentage], sum(sku.[Sales made Less than Input Vat]) [Sales made Less than Input Vat]
    , sum(sku.[Output VAT]) [Output VAT], [Purchase Tax Percentage], sum(sku.[Input VAT]) [Input VAT], sum(sku.[VAT Disallowed]) [VAT Disallowed]
    from 	
    (select DivId, SubCtgId, MktSKUId, product_code, sum(Saleamt) [Sales made Less than Input Vat]
     , vatpcnt [Output VAT Percentage]
     , sum(Salevatamt) [Output VAT]
     , sum(purchasevatamt) [Input VAT], sum(vatDiff  * case Invoicetypeno when 4 then -1 else 1 end) [VAT Disallowed]
     , [Purchase Tax Percentage]
     from #SystemSKU 
     group by DivId, SubCtgId, MktSKUId, product_code, vatpcnt, [Purchase Tax Percentage]
     having sum(vatDiff) > 0 
    ) sku
    Join ItemCategories ItmD on sku.DivId = ItmD.CategoryId
    Join ItemCategories ItmS on sku.SubCtgId = ItmS.CategoryId
    Join ItemCategories ItmM on sku.MktSKUId = ItmM.CategoryId
    group by sku.[Output VAT Percentage], ItmD.Category_name, ItmS.Category_name, ItmM.Category_name, [Purchase Tax Percentage]
    order by ItmD.Category_name, ItmS.Category_name, ItmM.Category_name

End
Else If @LevelOfReport = 'summary' and @level = 3 
begin
-- summary level Data for subcategory
    select @WDCode [WD Code1], @WDCode [WD Code], @WDDest [WD Dest], @FromDate [From Date], @ToDate [To Date]
    , ItmD.Category_name [Division], ItmS.Category_name [Sub Category]
    , sku.[Output VAT Percentage] [Sales Tax Percentage], sum(sku.[Sales made Less than Input Vat]) [Sales made Less than Input Vat]
    , sum(sku.[Output VAT]) [Output VAT], [Purchase Tax Percentage], sum(sku.[Input VAT]) [Input VAT], sum(sku.[VAT Disallowed]) [VAT Disallowed]
    from 	
    (select DivId, SubCtgId, MktSKUId, product_code, sum(Saleamt) [Sales made Less than Input Vat]
     , vatpcnt [Output VAT Percentage]
     , sum(Salevatamt) [Output VAT]
     , sum(purchasevatamt) [Input VAT], sum(vatDiff  * case Invoicetypeno when 4 then -1 else 1 end) [VAT Disallowed]
     , [Purchase Tax Percentage]
     from #SystemSKU 
     group by DivId, SubCtgId, MktSKUId, product_code, vatpcnt, [Purchase Tax Percentage]
     having sum(vatDiff) > 0 
    ) sku
    Join ItemCategories ItmD on sku.DivId = ItmD.CategoryId
    Join ItemCategories ItmS on sku.SubCtgId = ItmS.CategoryId
    group by sku.[Output VAT Percentage], ItmD.Category_name, ItmS.Category_name, [Purchase Tax Percentage]
    order by ItmD.Category_name, ItmS.Category_name

End
Else If @LevelOfReport = 'summary' and @level = 2 
begin
-- summary level Data for Division
    select @WDCode [WD Code1],  @WDCode [WD Code], @WDDest [WD Dest], @FromDate [From Date], @ToDate [To Date]
    , ItmD.Category_name [Division], [Purchase Tax Percentage]
    , sku.[Output VAT Percentage] [Sales Tax Percentage], [Disallowance Type], Sum(sku.[Sales made Less than Input Vat]) [Sales made Less than Input Vat]
    , sum(sku.[Output VAT]) [Output VAT], Sum(sku.[Input VAT]) [Input VAT], sum(sku.[VAT Disallowed]) [VAT Disallowed]
    from 	
    (select DivId, SubCtgId, MktSKUId, product_code, sum(Saleamt) [Sales made Less than Input Vat]
     , vatpcnt [Output VAT Percentage]
     , sum(Salevatamt) [Output VAT]
     , sum(purchasevatamt) [Input VAT], sum(vatDiff  * case Invoicetypeno when 4 then -1 else 1 end) [VAT Disallowed], [Purchase Tax Percentage], [Disallowance Type]
     from #SystemSKU 
     group by DivId, SubCtgId, MktSKUId, product_code, vatpcnt, [Purchase Tax Percentage], [Disallowance Type]
     having sum(vatDiff  * case Invoicetypeno when 4 then -1 else 1 end) > 0  or [Disallowance Type] = 'Free Item'
    ) sku
    Join ItemCategories ItmD on sku.DivId = ItmD.CategoryId
    Group by sku.[Output VAT Percentage], ItmD.Category_name , [Purchase Tax Percentage], [Disallowance Type]
    order by ItmD.Category_name
End
OvernOut:
