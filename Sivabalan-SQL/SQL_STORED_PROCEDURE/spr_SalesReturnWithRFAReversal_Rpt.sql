Create procedure dbo.spr_SalesReturnWithRFAReversal_Rpt( @Dt nvarchar(100) )  
as 
Begin

set dateformat dmy

Declare @Delimeter char(1), @SplSchDet varchar(4000), @RptParam varchar(1000), @RFAflag Int
, @InvoiceId Int, @prd_code varchar(4000), @serial Int, @SchItmData varchar(1000)
, @Idt Int, @quantity Decimal(18, 6), @amount Decimal(18, 6), @FromDate Datetime, @ToDate Datetime

Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
Select Top 1 @WDCode = RegisteredOwner From Setup    
Select Top 1 @RFAflag = IsNull(flag, 0) From tbl_merp_configabstract where screencode = 'RFA01'
If @CompaniesToUploadCode='ITC001'  
    Set @WDDest= @WDCode  
Else  
Begin  
    Set @WDDest= @WDCode  
    Set @WDCode= @CompaniesToUploadCode  
End

Create table #tmpSchData( Idt Int Identity (1, 1), InvoiceId Int, prd_code varchar(1000), serial Int, quantity Decimal(18, 6), amount Decimal(18, 6), SchData varchar(1000))
Create table #tmpSchItmData( Idt Int Identity (1, 1), tmpIdt Int, InvoiceId Int, prd_code varchar(1000), serial Int
, quantity Decimal(18, 6), amount Decimal(18, 6), SchItmData varchar(1000)) 
select @FromDate = convert(datetime, ('01/' + @Dt), 103)  
select @ToDate = convert(datetime, dateadd(d, -1, dateadd(m, 1, @FromDate )), 103)

select @RptParam = convert(varchar(10), @FromDate, 103) + '|' + convert(varchar(10), @ToDate, 103) 
select @Delimeter = char(15)

Select Ia.DocumentId, Ia.InvoiceId, Ia.InvoiceDate,
Cast( IsNull(Reverse(left(reverse(IsNull(NewReference,'')), 
        Case When PATINDEX( N'%[^0-9]%', Reverse(IsNull(newreference, ''))) > 0 Then PATINDEX( N'%[^0-9]%',Reverse(IsNull(NewReference, ''))) -1
			 Else Len(IsNull(NewReference, '')) End )) , 0)
         As Integer ) Nref
, Ia.creationtime, customer.customerId, customer.company_name 
Into #tmpIa
from Invoiceabstract Ia
Join customer on Ia.customerId = customer.customerId
where Ia.status & 128 = 0 and Ia.Invoicetype = 4 and Ia.InvoiceDate > @FromDate and Ia.InvoiceDate <= @ToDate
and (len(rtrim(ltrim(IsNull(Ia.NewReference,''))))) > 0 

select I.InvoiceId, max(Ia.InvoiceId) Orig_Id Into #tmpSRWithRef from #tmpIa I Join Invoiceabstract Ia on I.Nref = Ia.DocumentId 
Group by I.InvoiceId


select tmp.InvoiceId, tmp.product_code prd_code, tmp.SaleQty quantity
, tmp.SaleValue amount, tmp.SchemeID SchId, tmp.SlabID
, ( Case when @RFAflag = 1 then tmp.RebateValue_tax Else tmp.RebateValue End ) DscAmt 
, Itm.DivId
Into #tmpInvoiceSch 
from tbl_merp_NonQPSData tmp 

Join #tmpIa tmp_SR on tmp.InvoiceId = tmp_SR.InvoiceId 
Join ( Select ItcDiv.CategoryId DivId, Itm.product_code  
	From ItemCategories ItcDiv 
	Join ItemCategories ItcSubC on ItcDiv.CategoryId = ItcSubC.ParentId 
	Join ItemCategories ItcMkt on ItcSubC.CategoryId = ItcMkt.ParentId 
	Join Items Itm on ItcMkt.CategoryId = Itm.CategoryId 
	where Itm.Active = 1 ) Itm on tmp.product_code = Itm.product_code  

select #tmpIa.CustomerId, #tmpIa.company_name CustomerName, schabs.ActivityCode
, schabs.Description ActivityDescription, schabs.ActiveFrom, schabs.ActiveTo
, Ia.InvoiceDate Original_InvDate, #tmpIa.DocumentId Ret_InvoiceNo, #tmpIa.InvoiceDate Ret_InvoiceDate
, ISch.prd_code SKUCode, ( 0 - ISch.quantity) ReturnSalesQty, (0 - ISch.amount) ReturnSalesValue
, IsNull(Null, 0) ReturnRebateQty, (0 - ISch.DscAmt) DscAmt, DivId
Into #tmpRptData 
from #tmpInvoiceSch ISch Join tbl_merp_schemeabstract schabs on ISch.SchId = schabs.SchemeId
Join #tmpIa on ISch.InvoiceId = #tmpIa.InvoiceId
Join #tmpSRWithRef SRef on #tmpIa.InvoiceId = SRef.InvoiceId
Join Invoiceabstract Ia on SRef.Orig_Id = Ia.InvoiceId 
Join tbl_mERP_SchemePayoutPeriod schPP on schabs.SchemeId = schPP.SchemeId 
    and dbo.StripTimeFromDate(Ia.InvoiceDate) >= schPP.PayoutPeriodFrom and dbo.StripTimeFromDate(Ia.InvoiceDate) <= schPP.PayoutPeriodTo -- + datediff(d, schabs.schemeto, schabs.expirydate)

where schabs.RFAApplicable = 1 and dbo.StripTimeFromDate(#tmpIa.InvoiceDate) > schPP.PayoutPeriodTo
order by #tmpIa.DocumentId, ISch.prd_code 


select category_name DtRpt, @WDCode [WD Code], @WDDest [WD Dest], @FromDate [From Date], @ToDate [To Date]
, category_name Division, Return_Scheme_Value_WithRef from 
(   select DivId, sum(DscAmt) Return_Scheme_Value_WithRef 
    from #tmpRptData 
    group by DivId ) tmp Join Itemcategories Ic on tmp.DivId = Ic.categoryId

End
