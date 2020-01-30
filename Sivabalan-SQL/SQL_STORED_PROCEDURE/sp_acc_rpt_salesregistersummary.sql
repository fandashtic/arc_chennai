


CREATE procedure sp_acc_rpt_salesregistersummary(@fromdate datetime,@todate datetime)
as
create table #salesregistersummary(InvoiceDate nvarchar(20) ,GoodsValueSales decimal(18,6),
GoodsValueSalesReturnDamages decimal(18,6),GoodsValueSalesReturnSaleable decimal(18,6),
TotalTaxSuffered decimal(18,6),TotalDiscount decimal(18,6),TotalTaxApplicable decimal(18,6),
NetSales decimal(18,6),colorinfo integer)

insert into #salesregistersummary 
select "Date" = dbo.sp_acc_StripDateFromTime(InvoiceDate),
"Goods Value(Sales)" = Sum(Case isnull(InvoiceType,0)
When 4 Then
0
Else
GoodsValue
End), 
"Goods Value(Sales Return Damages)" = Sum(Case isnull(InvoiceType,0)
When 4 Then
Case isnull(Status,0) & 32 
When 0 Then
0
Else
GoodsValue
End
Else
0
End),
"Goods Value(Sales Return Saleable)" = Sum(Case isnull(InvoiceType,0)
When 4 Then
	Case isnull(Status,0) & 32 
	When 0 Then
	GoodsValue
	Else
	0
	End
Else
0
End),
"Total Tax Suffered" = Sum(Case isnull(InvoiceType,0)
When 4 Then
0 - TotalTaxSuffered
Else
TotalTaxSuffered
End),
"Total Discount" = Sum(Case isnull(InvoiceType,0)
When 4 Then
0 - (DiscountValue + AddlDiscountValue + ProductDiscount)
Else
(DiscountValue + AddlDiscountValue + ProductDiscount)
End),
"Total Tax Applicable" = Sum(Case isnull(InvoiceType,0)
When 4 Then
0 - isnull(TotalTaxApplicable,0)
Else
isnull(TotalTaxApplicable,0)
End),
"Net Sales" = Sum(Case isnull(InvoiceType,0)
When 4 Then
0 - isnull(NetValue,0) - isnull(Freight,0)
Else 
isnull(NetValue,0) - isnull(Freight,0)
End),0
From InvoiceAbstract
Where dbo.stripdatefromtime(InvoiceAbstract.InvoiceDate)Between @FromDate And @ToDate And
isnull(InvoiceAbstract.Status,0) & 128 = 0 And
isnull(InvoiceType,0) in (1, 2, 3, 4)
Group By dbo.sp_acc_StripDateFromTime(InvoiceDate)

insert #salesregistersummary
select 'Total',sum(isnull(GoodsValueSales,0)),sum(isnull(GoodsValueSalesReturnDamages,0)),
sum(isnull(GoodsValueSalesReturnSaleable,0)),sum(isnull(TotalTaxSuffered,0)),
sum(isnull(TotalDiscount,0)),sum(isnull(TotalTaxApplicable,0)),sum(isnull(NetSales,0)),1
from #salesregistersummary 


select 'Date'= InvoiceDate, 'Goods Value - Sales'=GoodsValueSales,
'Goods Value - Salese Return(Damages)'=GoodsValueSalesReturnDamages,
'Goods Value - Sales Return(Saleable)' =GoodsValueSalesReturnSaleable,
'Total Tax Suffered'=TotalTaxSuffered,'Total Discount'= TotalDiscount,
'Total Tax Applicable'=TotalTaxApplicable,'Net Value'= NetSales,colorinfo
from  #salesregistersummary

drop table  #salesregistersummary












