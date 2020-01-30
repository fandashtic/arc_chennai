Create procedure spr_Vat_Disallowed_Report_DiscOrFree ( @FromDate Datetime, @ToDate Datetime, 
	@CategoryLevel nvarchar(100), @TradeDiscount nvarchar(50), @UOM nvarchar(100) = 'n/a')
as 
Declare @level Int, @voucherprefix nvarchar(100), @LevelOfReport nvarchar(100)
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)
Declare @DiscountORFree int 
Declare @temp datetime
set dateformat dmy 
                    
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)

if(@FromDate > @temp )
begin
	select 0,'This report cannot be generated for GST period' as Reason
	goto GSTOut
end               
                 
if(@ToDate > @temp )
begin
	set @ToDate  = @temp 
	--goto GSTOut
end    
 
Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
Select Top 1 @WDCode = RegisteredOwner From Setup    

select @DiscountORFree = IsNull(Flag,0) from tbl_mERP_ConfigDetail where ScreenCode ='DFRFLAG' and XMLAttribute ='DISCORFREE'

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

Create Table #tmpSales(InvoiceId int ,product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
virtualBatch int,InvoiceNo nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
DivId int,SubCtgId int,MktSKUId int,Docreference nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceDate datetime, flagword int,AdditionalDiscount decimal(18,6),Invoicetype nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceTypeNo int,uom nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,qtyInBuom decimal(18,6),
qty decimal(18,6),pricebeforediscount decimal(18,6),prdDiscountamt decimal(18,6),tradeDiscountamt decimal(18,6),
priceaftdiscount decimal(18,6),Saleamt decimal(18,6),vatpcnt decimal(18,6),Salevatamt decimal(18,6),
purchaseprice decimal(18,6),purchasepriceInBuom decimal(18,6),[Disallowance Type] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status int,TAXONQTY int,Taxamount decimal(18,6))

Create Table #TmpI(InvoiceId int, product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 virtualBatch int , Batch_Number nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,saleprice decimal(18,6), 
 DivId int, SubCtgId int, MktSKUId int, UOM int , UOM1 int,UOM2 int, UOM1_Conversion decimal(18,6),
 UOM2_Conversion decimal(18,6),InvoiceNo nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 Docreference nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,InvoiceDate datetime,  flagword int,
 AdditionalDiscount decimal(18,6),InvoiceType int , Quantity decimal(18,6),  ptr decimal(18,6),
 Discountvalue decimal(18,6) ,stcredit decimal(18,6),  pts decimal(18,6),
 CustomerId nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,taxId int , status int, stpayable  decimal(18,6),
 cstpayable decimal(18,6),  amount decimal(18,6), serial int,TAXONQTY int,Taxamount decimal(18,6))
						
--TmpInvoiceabstract
Select Ia.* 
into #TmpInvoiceabstract 
from Invoiceabstract Ia
where dbo.StripTimeFromDate(Ia.InvoiceDate) >= @FromDate and dbo.StripTimeFromDate(Ia.InvoiceDate) <= @toDate
and Ia.status & 128 = 0 and Ia.Invoicetype In ( 1, 3, 4 ) 
--TmpInvoiceDetail
Select Id.*
into #TmpInvoiceDetail 
from InvoiceDetail Id 
Join #TmpInvoiceabstract Ia on Ia.InvoiceId = Id.InvoiceId
Join #Items Itm On Itm.Prd_code = ID.Product_code 
where dbo.StripTimeFromDate(Ia.InvoiceDate) >= @FromDate and dbo.StripTimeFromDate(Ia.InvoiceDate) <= @toDate
and Ia.status & 128 = 0 and Ia.Invoicetype In ( 1, 3, 4 )	

if  @DiscountORFree = 1  -- only Discount Scheme
begin
insert into #TmpI(InvoiceId ,product_code ,virtualBatch, Batch_Number,saleprice, DivId, SubCtgId,MktSKUId ,UOM,UOM1,UOM2,UOM1_Conversion,
 UOM2_Conversion ,InvoiceNo,Docreference ,InvoiceDate ,flagword ,AdditionalDiscount ,InvoiceType, Quantity, ptr,
 Discountvalue,stcredit,pts,CustomerId,taxId, status, stpayable,cstpayable,amount ,serial ,TAXONQTY ,Taxamount)
Select Id.InvoiceId, Id.product_code, max(Id.Batch_code) virtualBatch, max(Id.Batch_Number) Batch_Number, Id.saleprice,  Itm.DivId, Itm.SubCtgId, Itm.MktSKUId, itm.UOM, itm.UOM1, itm.UOM2, itm.UOM1_Conversion,itm.UOM2_Conversion
, @voucherprefix + convert(varchar(20), Ia.DocumentId) 'InvoiceNo'	
, Ia.Docreference, Ia.InvoiceDate, max(Id.flagword) flagword
, max(Ia.AdditionalDiscount) AdditionalDiscount
, Ia.InvoiceType, sum(Id.Quantity) Quantity, max(Id.Saleprice) ptr, sum(Id.Discountvalue) Discountvalue 
, max(Id.stcredit) stcredit, max(Id.pts) pts, CustomerId, max(taxId) taxId, status
, max(stpayable) stpayable, max(cstpayable) cstpayable, max(amount) amount, serial, Id.TAXONQTY, Sum(Id.Taxamount) Taxamount
from #TmpInvoiceabstract Ia
Join #TmpInvoiceDetail Id on Ia.InvoiceId = Id.InvoiceId
Join #Items Itm On Itm.Prd_code = ID.Product_code 
where dbo.StripTimeFromDate(Ia.InvoiceDate) >= @FromDate and dbo.StripTimeFromDate(Ia.InvoiceDate) <= @toDate
and Ia.status & 128 = 0 and Ia.Invoicetype In ( 1, 3, 4 ) 
and Id.Saleprice <> 0 --added to display only Discount Scheme
group by Id.InvoiceId, Id.product_code, @voucherprefix + convert(varchar(20), Ia.DocumentId), serial 
, Ia.Docreference, Ia.InvoiceDate, Ia.InvoiceType, CustomerId, status, Id.saleprice ,  Itm.DivId, Itm.SubCtgId, Itm.MktSKUId
, itm.UOM, itm.UOM1, itm.UOM2, itm.UOM1_Conversion,itm.UOM2_Conversion, Id.TAXONQTY
end
Else if  @DiscountORFree = 2  -- only Free Item
begin
insert into #TmpI(InvoiceId ,product_code ,virtualBatch, Batch_Number,saleprice, DivId, SubCtgId,MktSKUId ,UOM,UOM1,UOM2,UOM1_Conversion,
 UOM2_Conversion ,InvoiceNo,Docreference ,InvoiceDate ,flagword ,AdditionalDiscount ,InvoiceType, Quantity, ptr,
 Discountvalue,stcredit,pts,CustomerId,taxId, status, stpayable,cstpayable,amount ,serial ,TAXONQTY ,Taxamount)
Select Id.InvoiceId, Id.product_code, max(Id.Batch_code) virtualBatch, max(Id.Batch_Number) Batch_Number, Id.saleprice,  Itm.DivId, Itm.SubCtgId, Itm.MktSKUId, itm.UOM, itm.UOM1, itm.UOM2, itm.UOM1_Conversion,itm.UOM2_Conversion
, @voucherprefix + convert(varchar(20), Ia.DocumentId) 'InvoiceNo'	
, Ia.Docreference, Ia.InvoiceDate, max(Id.flagword) flagword
, max(Ia.AdditionalDiscount) AdditionalDiscount
, Ia.InvoiceType, sum(Id.Quantity) Quantity, max(Id.Saleprice) ptr, sum(Id.Discountvalue) Discountvalue 
, max(Id.stcredit) stcredit, max(Id.pts) pts, CustomerId, max(taxId) taxId, status
, max(stpayable) stpayable, max(cstpayable) cstpayable, max(amount) amount, serial, Id.TAXONQTY, Sum(Id.Taxamount) Taxamount
from #TmpInvoiceabstract Ia
Join #TmpInvoiceDetail Id on Ia.InvoiceId = Id.InvoiceId
Join #Items Itm On Itm.Prd_code = ID.Product_code 
where dbo.StripTimeFromDate(Ia.InvoiceDate) >= @FromDate and dbo.StripTimeFromDate(Ia.InvoiceDate) <= @toDate
and Ia.status & 128 = 0 and Ia.Invoicetype In ( 1, 3, 4 ) 
and Id.saleprice = 0 and Id.pts > 0 --added to display only Free Item
group by Id.InvoiceId, Id.product_code, @voucherprefix + convert(varchar(20), Ia.DocumentId), serial 
, Ia.Docreference, Ia.InvoiceDate, Ia.InvoiceType, CustomerId, status, Id.saleprice ,  Itm.DivId, Itm.SubCtgId, Itm.MktSKUId
, itm.UOM, itm.UOM1, itm.UOM2, itm.UOM1_Conversion,itm.UOM2_Conversion, Id.TAXONQTY
end
Else if  @DiscountORFree = 3  -- Both Discount Scheme and Free Item
begin
insert into #TmpI(InvoiceId ,product_code ,virtualBatch, Batch_Number,saleprice, DivId, SubCtgId,MktSKUId ,UOM,UOM1,UOM2,UOM1_Conversion,
 UOM2_Conversion ,InvoiceNo,Docreference ,InvoiceDate ,flagword ,AdditionalDiscount ,InvoiceType, Quantity, ptr,
 Discountvalue,stcredit,pts,CustomerId,taxId, status, stpayable,cstpayable,amount ,serial ,TAXONQTY ,Taxamount)
Select Id.InvoiceId, Id.product_code, max(Id.Batch_code) virtualBatch, max(Id.Batch_Number) Batch_Number, Id.saleprice,  Itm.DivId, Itm.SubCtgId, Itm.MktSKUId, itm.UOM, itm.UOM1, itm.UOM2, itm.UOM1_Conversion,itm.UOM2_Conversion
, @voucherprefix + convert(varchar(20), Ia.DocumentId) 'InvoiceNo'	
, Ia.Docreference, Ia.InvoiceDate, max(Id.flagword) flagword
, max(Ia.AdditionalDiscount) AdditionalDiscount
, Ia.InvoiceType, sum(Id.Quantity) Quantity, max(Id.Saleprice) ptr, sum(Id.Discountvalue) Discountvalue 
, max(Id.stcredit) stcredit, max(Id.pts) pts, CustomerId, max(taxId) taxId, status
, max(stpayable) stpayable, max(cstpayable) cstpayable, max(amount) amount, serial, Id.TAXONQTY, Sum(Id.Taxamount) Taxamount
 from #TmpInvoiceabstract Ia
Join #TmpInvoiceDetail Id on Ia.InvoiceId = Id.InvoiceId
Join #Items Itm On Itm.Prd_code = ID.Product_code 
where dbo.StripTimeFromDate(Ia.InvoiceDate) >= @FromDate and dbo.StripTimeFromDate(Ia.InvoiceDate) <= @toDate
and Ia.status & 128 = 0 and Ia.Invoicetype In ( 1, 3, 4 ) 
group by Id.InvoiceId, Id.product_code, @voucherprefix + convert(varchar(20), Ia.DocumentId), serial 
, Ia.Docreference, Ia.InvoiceDate, Ia.InvoiceType, CustomerId, status, Id.saleprice ,  Itm.DivId, Itm.SubCtgId, Itm.MktSKUId
, itm.UOM, itm.UOM1, itm.UOM2, itm.UOM1_Conversion,itm.UOM2_Conversion, Id.TAXONQTY
end

--For Tax Discount as Yes
if @TradeDiscount = 'yes'
BEGIN
		insert into #tmpSales(InvoiceId,product_code,virtualBatch,InvoiceNo,DivId,SubCtgId,MktSKUId,Docreference,InvoiceDate,   flagword,AdditionalDiscount,Invoicetype,InvoiceTypeNo,uom,qtyInBuom,qty,pricebeforediscount,prdDiscountamt,tradeDiscountamt,priceaftdiscount,Saleamt,vatpcnt,Salevatamt,purchaseprice,purchasepriceInBuom,[Disallowance Type],Status,TAXONQTY,Taxamount)
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
			, convert(Decimal(18,6), ( Isnull(I.Quantity,0) 
										* ( Case when I.InvoiceType In (1, 3) then 1  
											when I.InvoiceType In (4) then -1 
											End ))) 'qtyInBuom'
			, convert(Decimal(18,6), ((Case when @levelofreport = 'summary' then Isnull(I.Quantity,0) 
												when @levelofreport = 'Detail' then  				  
											Case when @uom = 'Base Uom' then Isnull(I.Quantity,0) 
												 when @uom = 'Uom 1' then Isnull(I.Quantity,0)/Isnull(Uom1_Conversion,1)
												 when @uom = 'Uom 2' then Isnull(I.Quantity,0)/Isnull(Uom2_Conversion	,1)
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
						((I.ptr * Isnull(I.Quantity,0)) - I.Discountvalue)
							* I.AdditionalDiscount/100)'tradeDiscountamt'  


			, convert(Decimal(18,6),(Case when @levelofreport = 'summary' then
												(I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) -
												((((I.ptr * Isnull(I.Quantity,0)) - I.Discountvalue)
													* I.AdditionalDiscount/100) / (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))
											 when @levelofreport = 'Detail' then  	
												Case when @uom = 'Base Uom' then  
													(I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) -
													((((I.ptr * Isnull(I.Quantity,0)) - I.Discountvalue)
														* I.AdditionalDiscount/100) / (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))

													when @uom = 'Uom 1' then 
														((I.ptr*Uom1_Conversion) - (I.Discountvalue/isnull((Isnull(I.Quantity,0)/Isnull(Uom1_Conversion,1)),1))) -
														((((I.ptr * Isnull(I.Quantity,0)) - I.Discountvalue)
															* I.AdditionalDiscount/100) / Isnull((Isnull(I.Quantity,0)/Isnull(Uom1_Conversion,1)),1)) 

													when @uom = 'Uom 2' then 
														((I.ptr*Uom2_Conversion) - (I.Discountvalue/Isnull((Isnull(I.Quantity,0)/Isnull(Uom2_Conversion,1)),1))) -
														((((I.ptr * Isnull(I.Quantity,0)) - I.Discountvalue)
															* I.AdditionalDiscount/100) / Isnull((Isnull(I.Quantity,0)/Isnull(Uom2_Conversion,1)),1))

												end
										end) ) 'priceaftdiscount'
		    

		    , convert(Decimal(18,6),(((I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) -
                                        ((((I.ptr * Isnull(I.Quantity,0)) - I.Discountvalue)
                                            * I.AdditionalDiscount/100) / (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End)))
                               * Isnull(I.Quantity,0) )
                              * Case when I.InvoiceType In (1, 3) then 1  
                                      when I.InvoiceType In (4) then -1 
                                End ) 'Saleamt' 				
		    
			, ( Case when Customer.locality = 1 then tax.percentage Else tax.cst_percentage End) 'vatpcnt'

			, convert(Decimal(18, 6), (( Isnull(I.stpayable, 0) + Isnull(I.cstpayable, 0)) 
									  * (( Case when I.InvoiceType In (1, 3) then 1  
												when I.InvoiceType In (4) then -1 
										  End) )))  'Salevatamt' 

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
			,I.Taxamount
			from #TmpI I  -- Base level Data taken from Invoice
			Join Uom on I.uom = uom.uom Join Uom uom1 on I.uom1 = uom1.uom Join Uom uom2 on I.uom2 = uom2.uom
			Join Customer on I.CustomerId = customer.customerId
			Join tax on I.taxId = tax.tax_code 	--select * from #tmpSales



		insert into #tmpSales(InvoiceId,product_code,virtualBatch,InvoiceNo,DivId,SubCtgId,MktSKUId,Docreference,InvoiceDate,   flagword,AdditionalDiscount,Invoicetype,InvoiceTypeNo,uom,qtyInBuom,qty,pricebeforediscount,prdDiscountamt,tradeDiscountamt,priceaftdiscount,Saleamt,vatpcnt,Salevatamt,purchaseprice,purchasepriceInBuom,[Disallowance Type],Status,TAXONQTY,Taxamount)
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
			, convert(Decimal(18,6), ( Isnull(I.Quantity,0) 
										* ( Case when I.InvoiceType In (1, 3) then 1  
											when I.InvoiceType In (4) then -1 
											End ))) 'qtyInBuom'
			, convert(Decimal(18,6), ((Case when @levelofreport = 'summary' then Isnull(I.Quantity,0) 
												when @levelofreport = 'Detail' then  				  
											Case when @uom = 'Base Uom' then Isnull(I.Quantity,0) 
												 when @uom = 'Uom 1' then Isnull(I.Quantity,0)/isnull(Uom1_Conversion,1)
												 when @uom = 'Uom 2' then Isnull(I.Quantity,0)/isnull(Uom2_Conversion	,1)
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

			, convert(Decimal(18,6),0)  'tradeDiscountamt'  


			, convert(Decimal(18,6),(Case when @levelofreport = 'summary' then
												(I.ptr - (I.Discountvalue/ (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) 
										when @levelofreport = 'Detail' then  	
											   Case when @uom = 'Base Uom' then (I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) 
												   when @uom = 'Uom 1' then (I.ptr*Uom1_Conversion) - (I.Discountvalue/Isnull((Isnull(I.Quantity,0)/Isnull(Uom1_Conversion,1)),1))
												   when @uom = 'Uom 2' then (I.ptr*Uom2_Conversion) - (I.Discountvalue/Isnull((Isnull(I.Quantity,0)/Isnull(Uom2_Conversion,1)),1))
											   end
										end) ) 'priceaftdiscount'
		    

			, convert(Decimal(18,6),((I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0) End))) 
									 * Isnull(I.Quantity,0) )
									  * Case when I.InvoiceType In (1, 3) then 1  
											  when I.InvoiceType In (4) then -1 
										End ) 'Saleamt' 		
		    
			, ( Case when Customer.locality = 1 then tax.percentage Else tax.cst_percentage End) 'vatpcnt'

			, convert(Decimal(18, 6), ((Isnull(I.stpayable, 0) + Isnull(I.cstpayable, 0) + Isnull(I.stcredit,0)) * 
										(( Case when I.InvoiceType In (1, 3) then 1  
												when I.InvoiceType In (4) then -1 
										  End) )))  'Salevatamt' 

			, convert(Decimal(18,6),(Case when @levelofreport = 'summary' then I.pts 
										  when @levelofreport = 'Detail' then  				  
											Case when @uom = 'Base Uom' then I.pts 
												 when @uom = 'Uom 1' then (I.pts*Uom1_Conversion)
												 when @uom = 'Uom 2' then (I.pts*Uom2_Conversion)
											end
									  end)) 'purchaseprice' 
			, convert(Decimal(18,6),I.pts) 'purchasepriceInBuom' 
			, 'Trade Discount'
			, I.Status
			, I.TAXONQTY
			, I.Taxamount
			from  #TmpI I -- Base level Data taken from Invoice
			Join Uom on I.uom = uom.uom and I.ptr <> 0
			Join Uom uom1 on I.uom1 = uom1.uom 
			Join Uom uom2 on I.uom2 = uom2.uom
			Join Customer on I.CustomerId = customer.customerId
			Join tax on I.taxId = tax.tax_code 


END
ELSE
BEGIN
		--For Tax Discount as No
		insert into #tmpSales(InvoiceId,product_code,virtualBatch,InvoiceNo,DivId,SubCtgId,MktSKUId,Docreference,InvoiceDate,   flagword,AdditionalDiscount,Invoicetype,InvoiceTypeNo,uom,qtyInBuom,qty,pricebeforediscount,prdDiscountamt,tradeDiscountamt,priceaftdiscount,Saleamt,vatpcnt,Salevatamt,purchaseprice,purchasepriceInBuom,[Disallowance Type],Status,TAXONQTY,Taxamount)
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
			, convert(Decimal(18,6), ( Isnull(I.Quantity,0) 
										* ( Case when I.InvoiceType In (1, 3) then 1  
											when I.InvoiceType In (4) then -1 
											End ))) 'qtyInBuom'
			, convert(Decimal(18,6), ((Case when @levelofreport = 'summary' then Isnull(I.Quantity,0) 
												when @levelofreport = 'Detail' then  				  
											Case when @uom = 'Base Uom' then Isnull(I.Quantity,0) 
												 when @uom = 'Uom 1' then Isnull(I.Quantity,0)/Isnull(Uom1_Conversion,1)
												 when @uom = 'Uom 2' then Isnull(I.Quantity,0)/Isnull(Uom2_Conversion	,1)
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

			, convert(Decimal(18,6),0)  'tradeDiscountamt'  


			, convert(Decimal(18,6),(Case when @levelofreport = 'summary' then
												(I.ptr - (I.Discountvalue/ (Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0)  End))) 
										when @levelofreport = 'Detail' then  	
											   Case when @uom = 'Base Uom' then (I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0)  End))) 
												   when @uom = 'Uom 1' then (I.ptr*Uom1_Conversion) - (I.Discountvalue/Isnull((Isnull(I.Quantity,0)/Uom1_Conversion),1))
												   when @uom = 'Uom 2' then (I.ptr*Uom2_Conversion) - (I.Discountvalue/Isnull((Isnull(I.Quantity,0)/Uom2_Conversion),1))
											   end
										end) ) 'priceaftdiscount'
		    

			, convert(Decimal(18,6),((I.ptr - (I.Discountvalue/(Case When Isnull(I.Quantity,0) = 0 Then 1 Else Isnull(I.Quantity,0)  End))) 
									 * Isnull(I.Quantity,0) )
									  * Case when I.InvoiceType In (1, 3) then 1  
											  when I.InvoiceType In (4) then -1 
										End ) 'Saleamt' 		
		    
			, ( Case when Customer.locality = 1 then tax.percentage Else tax.cst_percentage End) 'vatpcnt'

			, convert(Decimal(18, 6), ((Isnull(I.stpayable, 0) + Isnull(I.cstpayable, 0) + Isnull(I.stcredit,0)) * (( Case when I.InvoiceType In (1, 3) then 1  
												when I.InvoiceType In (4) then -1 
										  End ))))  'Salevatamt' 

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
			from #TmpI I-- Base level Data taken from Invoice
			Join Uom on I.uom = uom.uom Join Uom uom1 on I.uom1 = uom1.uom Join Uom uom2 on I.uom2 = uom2.uom
			Join Customer on I.CustomerId = customer.customerId
			Join tax on I.taxId = tax.tax_code 	--select * from #tmpSales

			
END

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

If @LevelOfReport = 'summary' and @level = 5 
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
GSTOut:
