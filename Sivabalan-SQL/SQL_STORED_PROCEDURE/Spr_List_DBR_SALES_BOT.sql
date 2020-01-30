CREATE Procedure Spr_List_DBR_SALES_BOT
(@Cuscode nvarchar(30),@UOMdesc nvarchar(30),@FromDate datetime, @Todate datetime)
as
Create Table #temp
(
 PlevelOne nvarchar(30),
 PlevelLast nvarchar(30),
 ItemCode nvarchar(30),
 ItemName nvarchar(30),
 Qty Decimal(18,6),
 CnvFactor Decimal(18,6),
 ReportUnit Decimal(18,6), 
 Amt Decimal(18,6),
 defaultUOM integer, 
 ReportUOM integer,
 ConvUOM integer	
)


DECLARE @FirstLevel nVARCHAR(100)  
DECLARE @LastLevel nVARCHAR(100)  
DECLARE @Mysql nVARCHAR(4000)  

Select @UOMdesc = Dbo.LookupDictionaryItem2(@UOMdesc,Default)
  
 SET @FirstLevel = dbo.GetHierarchyColumn(N'FIRST')
 SET @LastLevel= dbo.GetHierarchyColumn(N'LAST')

Insert into #temp
Select dbo.fn_FirstLevelCategory(Items.CategoryId),ItemCategories.Category_Name,Invoicedetail.Product_Code, Items.ProductName,
Case When Invoiceabstract.InvoiceType <> 4 then Invoicedetail.Quantity
     Else 0-Invoicedetail.Quantity
End,Items.ConversionFactor,Items.ReportingUnit,
Case When Invoiceabstract.InvoiceType <> 4 then Invoicedetail.Amount
     Else 0-Invoicedetail.Amount
End,Items.UOM,Items.ReportingUOM,Items.ConversionUnit
From Invoicedetail,Items,Invoiceabstract,ItemCategories
Where Invoicedetail.InvoiceId=Invoiceabstract.InvoiceId
and Invoicedetail.Product_code=Items.Product_code
and ItemCategories.CategoryId=Items.CategoryId
and Invoiceabstract.Customerid=@cuscode
and Invoiceabstract.Invoicedate Between @fromdate and @todate
and (INvoiceabstract.Status & 128)=0
AND INvoiceabstract.InvoiceType <> 2

Update #temp set Cnvfactor=1 where cnvfactor=0

Select #temp.Itemcode,#temp.PlevelOne ,#temp.PlevelLast,#temp.ItemName,
"UOM"=Case When @UOMdesc='Sales UOM' then dbo.fn_GetUOMDesc(#temp.defaultUOM,0)
           When @UOMDesc='Conversion Factor' then dbo.fn_GetUOMDesc(#temp.ConvUOM,1)
	   Else dbo.fn_GetUOMDesc(#temp.ReportUOM,0)
       End,     
"Quantity"=Case When @UOMdesc='Sales UOM' then Sum(#temp.Qty)			       
                When @UOMDesc='Conversion Factor' then Sum(#temp.Qty * #temp.CnvFactor) 
	        Else sum(#temp.Qty/#temp.ReportUnit)
	   End,
"Amt"=Sum(#temp.Amt) into #tempfinal
From #temp 
Group by #temp.Itemcode,#temp.ItemName,#temp.PlevelOne,#temp.PlevelLast,#temp.Amt, #temp.defaultUOM,#temp.ConvUOM,#temp.ReportUOM
Order by #temp.PlevelOne,#temp.PlevelLast,#temp.Amt desc

Set @lastlevel= Upper(SUBSTRING(@lastlevel, 1, 1)) + Lower(SUBSTRING(@lastlevel, 2, len(@lastlevel)))
Set @Firstlevel= Upper(SUBSTRING(@Firstlevel, 1, 1)) + Lower(SUBSTRING(@firstlevel, 2, len(@firstlevel)))

	Set @Mysql='Set quoted_identifier off;Select Itemcode,['+ @FirstLevel + ']=PlevelOne,['+ @lastLevel + ']=PlevelLast,'
	Set @Mysql= @Mysql + ' "Item Code"=ItemCode,"Item Name"=ItemName,['+ @UOMdesc +']=UOM,"Quantity"=Sum(Quantity),'
	Set @mysql=@Mysql + ' "SalesValue"=Sum(Amt)from #tempfinal group by ItemCode,PlevelOne,PlevelLast,ItemName,UOM'
        exec (@mysql)

drop table #temp
drop table #tempfinal













