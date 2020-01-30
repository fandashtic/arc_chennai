
CREATE PROCEDURE spr_list_items_in_invoice_MUOM_ITC
(
@INVOICEID int,
@UOMDesc nvarchar(30),
@Salesman nvarchar(4000) = 'All',
@TaxCompBrkUp nVARCHAR(10) = 'No',
@CustomerID nVarchar(2250),
@CustomerName nVarchar(2250)
)
AS


DECLARE @ADDNDIS AS Decimal(18,6)
DECLARE @TRADEDIS AS Decimal(18,6)

Declare @MaxCTDynamicCols int
Declare @MaxLTDynamicCols int
Declare @Col int
Declare @LTColCnt int
Declare @CTColCnt int
Declare @Tax_Code int
Declare @Tax_Code1 int
Declare @SQL nvarchar(4000)
Declare @CompType nvarchar(10)
Declare @CompType1 nvarchar(10)
Declare @DynFields nvarchar(4000)
Declare @TaxCompVal decimal(18,6)
Declare @TaxCompPer decimal(18,6)
Declare @CatName nvarchar(510)
Declare @TaxComp_Code int
Declare @TaxComp_desc nvarchar (50)
Declare @TaxPer decimal(18,6)
Declare @LTPrefix nvarchar(10)
Declare @CTPrefix nvarchar(10)
Declare @Product_Code nvarchar(510)
Declare @IntraPrefix nvarchar(10)
Declare @InterPrefix nvarchar(10)

Declare @CS_TaxCode int

Set @LTPrefix = 'LST '
Set @CTPrefix  = 'CST '
Set @IntraPrefix = 'Intra '
Set @InterPrefix  = 'Inter '


SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract
WHERE InvoiceID = @INVOICEID

if @TaxCompBrkUp <> 'Yes'
Begin

select * into #tmpMainDataOne from (
SELECT  InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,
"Item Name" = Items.ProductName,
"Batch" = InvoiceDetail.Batch_Number,
--      "Quantity" = SUM(InvoiceDetail.Quantity),
"Quantity" =(
Case When @UOMdesc = 'UOM1' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
When @UOMdesc = 'UOM2' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
Else SUM(InvoiceDetail.Quantity)
End),
"Volume" = (
Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)
When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)
Else SUM(InvoiceDetail.Quantity)
End),
--"Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),
"Sales Price" = (
Case When @UOMdesc = 'UOM1' then (InvoiceDetail.SalePrice) * Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
When @UOMdesc = 'UOM2' then (InvoiceDetail.SalePrice) * Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
Else (InvoiceDetail.SalePrice)
End),
"Invoice UOM" = (Select Description From UOM Where UOM = InvoiceDetail.UOM),
"Invoice Qty" = Sum(InvoiceDetail.UOMQty),
"Sale Tax" = Round((Max(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2)), 2) ,
"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0) ,
"Discount" = SUM(DiscountPercentage) ,
"STCredit" =
Round((SUM(InvoiceDetail.TaxCode) / 100.00) *
((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -
((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *
(@ADDNDIS / 100.00)) +
(((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -
((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *
(@TRADEDIS / 100.00))), 2),
"Total" = Round(SUM(Amount),2),
"Forum Code" = Items.Alias,
"Tax Suffered Value" = IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),
"Sales Tax Value" = Isnull(Sum(STPayable + CSTPayable), 0) , "Serial" = InvoiceDetail.Serial,
"Tax On Quantity" = TAXONQTY,
"HSN Number" = Max(InvoiceDetail.HSNNumber)
FROM InvoiceDetail, Items
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND
InvoiceDetail.Product_Code = Items.Product_Code
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,
InvoiceDetail.SalePrice, Items.Alias, UOM1_Conversion,UOM2_Conversion,InvoiceDetail.UOM , InvoiceDetail.Serial,TAXONQTY,InvoiceDetail.HSNNumber
) temp

Select Product_code = Product_code, "Item Code" = [Item Code], "Item Name" = [Item Name],
"Batch" =  [Batch], "Quantity" = Sum([Quantity]), "Volume" = Sum([Volume]), "Sales Price" = [Sales Price],
"Invoice UOM" = [Invoice UOM], "Invoice Qty" = Sum([Invoice Qty]), "Sale Tax" = Case When [Tax On Quantity] = 1 Then CAST(Max([Sale Tax]) AS nVARCHAR) Else CAST(Max([Sale Tax]) AS nVARCHAR) + '%' End,
"Tax Suffered" = CAST(Max([Tax Suffered])  AS nVARCHAR) + '%', "Discount" = CAST(Sum([Discount])  AS nVARCHAR) + '%',
"STCredit" = Sum([STCredit]), "Total" = Sum([Total]), "Forum Code" = [Forum Code],
"Tax Suffered Value" = Sum([Tax Suffered Value]) ,
"Sales Tax Value" = Sum([Sales Tax Value]),"HSN Number" = MAX([HSN Number])
--, "Serial" = [Serial]
from #tmpMainDataOne
Group By Product_code, [Item Code], [Item Name], [Batch], [Sales Price], [Invoice UOM],[Tax On Quantity],
--[Sale Tax], [Tax Suffered], [Discount],
[Forum Code],[HSN Number]--, [Serial]

End
Else
Begin
select * into #tmpMainDataTwo from
(
SELECT  InvoiceDetail.TaxID as Tax_Code, "Item Code" = InvoiceDetail.Product_Code,
"Item Name" = Items.ProductName,
"Batch" = InvoiceDetail.Batch_Number,
--      "Quantity" = SUM(InvoiceDetail.Quantity),
"Quantity" =(
Case When @UOMdesc = 'UOM1' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
When @UOMdesc = 'UOM2' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
Else SUM(InvoiceDetail.Quantity)
End),
"Volume" = (
Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)
When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)
Else SUM(InvoiceDetail.Quantity)
End),
--      "Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),
"Sales Price" = (
Case When @UOMdesc = 'UOM1' then (InvoiceDetail.SalePrice) * Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
When @UOMdesc = 'UOM2' then (InvoiceDetail.SalePrice) * Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
Else (InvoiceDetail.SalePrice)
End),
"Invoice UOM" = (Select Description From UOM Where UOM = InvoiceDetail.UOM),
"Invoice Qty" = Sum(InvoiceDetail.UOMQty),
"Sale Tax" = Round((Max(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2)), 2) ,
"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0) ,
"Discount" = SUM(DiscountPercentage),
"STCredit" =
Round((SUM(InvoiceDetail.TaxCode) / 100.00) *
((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -
((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *
(@ADDNDIS / 100.00)) +
(((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -
((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *
(@TRADEDIS / 100.00))), 2),
"Total" = Round(SUM(Amount),2),
"Forum Code" = Items.Alias,
"Tax Suffered Value" = IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),
"Sales Tax Value" = Isnull(Sum(STPayable + CSTPayable), 0), "Serial" = InvoiceDetail.Serial,
"Tax On Quantity" = TAXONQTY  ,
"HSN Number" = Max(InvoiceDetail.HSNNumber)
FROM InvoiceDetail, Items
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND
InvoiceDetail.Product_Code = Items.Product_Code
GROUP BY InvoiceDetail.TaxID, InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,
InvoiceDetail.SalePrice, Items.Alias, UOM1_Conversion,UOM2_Conversion,InvoiceDetail.UOM, InvoiceDetail.Serial,TAXONQTY
) tmp

select * into #tmpMainData from (
Select Tax_Code = Tax_Code, "Item Code" = [Item Code], "Item Name" = [Item Name],
"Batch" =  [Batch], "Quantity" = Sum([Quantity]), "Volume" = Sum([Volume]), "Sales Price" = [Sales Price],
"Invoice UOM" = [Invoice UOM], "Invoice Qty" = Sum([Invoice Qty]), "Sale Tax" = Case When [Tax On Quantity] = 1 Then CAST(Max([Sale Tax]) AS nVARCHAR) Else CAST(Max([Sale Tax]) AS nVARCHAR) + '%' End,
"Tax Suffered" = CAST(Max([Tax Suffered])  AS nVARCHAR) + '%', "Discount" = CAST(Sum([Discount])  AS nVARCHAR) + '%',
"STCredit" = Sum([STCredit]), "Total" = Sum([Total]), "Forum Code" = [Forum Code],
"Tax Suffered Value" = Sum([Tax Suffered Value]) ,
"Sales Tax Value" = Sum([Sales Tax Value]) --, "Serial" = [Serial]
,"HSN Number" =MAX([HSN Number])
from #tmpMainDataTwo
Group By  Tax_Code, [Item Code], [Item Name], [Batch], [Sales Price], [Invoice UOM],[Tax On Quantity],
--[Sale Tax], [Tax Suffered], [Discount],
[Forum Code],[HSN Number]--, [Serial]
) temp2


Select * into #tmpCompWiseData
from
(
SELECT InvoiceDetail.Product_Code, InvoiceTaxComponents.Tax_Component_code, TaxComponentDetail.TaxComponent_desc,"CS_TaxCode"=Tax.CS_TaxCode,
InvoiceTaxComponents.Tax_Percentage as CompWiseTaxPer, sum(Tax_Value) as CompWiseTax,
case when sum(isnull(CSTPayable,0)) <> 0 then @CTPrefix --CST Component
else @LTPrefix
end as CompType, InvoiceDetail.TaxID as Tax_Code
FROM (
select InvoiceDetail.Invoiceid, InvoiceDetail.Product_Code, InvoiceDetail.TaxID,
sum(InvoiceDetail.CSTPayable) as CSTPayable
from InvoiceDetail where InvoiceDetail.InvoiceID = @InvoiceID
group by InvoiceDetail.Invoiceid, InvoiceDetail.Product_Code, InvoiceDetail.TaxID
) InvoiceDetail, Items, InvoiceTaxComponents,TaxComponentDetail,Tax

WHERE InvoiceDetail.InvoiceID = @INVOICEID
and InvoiceDetail.Invoiceid = InvoiceTaxComponents.Invoiceid
and Items.Product_Code = InvoiceTaxComponents.Product_Code
and InvoiceDetail.Product_Code = Items.Product_Code
and InvoiceDetail.TaxID = InvoiceTaxComponents.Tax_Code

and TaxComponentDetail.TaxComponent_code = InvoiceTaxComponents.Tax_Component_Code
--and TaxComponentDetail.TaxComponent_desc = InvoiceTaxComponents.Tax_Code

GROUP BY InvoiceDetail.Product_Code, InvoiceTaxComponents.Tax_Component_code,
InvoiceTaxComponents.Tax_Percentage, InvoiceDetail.TaxID , TaxComponentDetail.TaxComponent_desc,Tax.CS_TaxCode
) tmp
--Select * from  #tmpCompWiseData
----------Find the No Of columns To be introduced
select  top 1 @MaxLTDynamicCols = count(Tax_Component_Code) from #tmpCompWiseData where CompType = @LTPrefix and CompWiseTax> 0 and isnull(CS_TaxCode,0)=0
group by Product_Code  order by count(Tax_Component_Code) desc
select  top 1 @MaxCTDynamicCols = count(Tax_Component_Code) from #tmpCompWiseData where CompType = @CTPrefix and CompWiseTax> 0 and isnull(CS_TaxCode,0)=0
group by Product_Code order by count(Tax_Component_Code) desc
----------Add the columns in main data table
if @MaxLTDynamicCols > 0 or @MaxCTDynamicCols > 0
Begin

set @Col = 1  --Dynamic Columns
set @DynFields = ''

--LT Columns
while @Col <= @MaxLTDynamicCols
Begin


Set @SQL = N'Alter Table #tmpMainData Add [' + @LTPrefix + 'Component ' + Cast(@Col as nvarchar) + N' Tax%] decimal(18,6) default 0;'
Set @SQL = @SQL + N'Alter Table #tmpMainData Add [' + @LTPrefix + 'Component ' + Cast(@Col as nvarchar) +  N' Tax Amount] decimal(18,6) default 0;'
Exec(@SQL)
Set @SQL = N'Update #tmpMainData set [' + @LTPrefix + 'Component ' + Cast(@Col as nvarchar) + N' Tax%] = 0;'
Set @SQL = @SQL + N'Update #tmpMainData set [' + @LTPrefix + 'Component ' + Cast(@Col as nvarchar) +  N' Tax Amount] = 0;'
Exec(@SQL)
set @Col = @Col + 1
--  end
End

set @Col = 1

--CT Columns
while @Col <= @MaxCTDynamicCols
Begin
Set @SQL = N'Alter Table #tmpMainData Add [' + @CTPrefix + 'Component ' + Cast(@Col as nvarchar) + N' Tax%] decimal(18,6) default 0;'
Set @SQL = @SQL + N'Alter Table #tmpMainData Add [' + @CTPrefix + 'Component ' + Cast(@Col as nvarchar) +  N' Tax Amount] decimal(18,6) default 0;'
Exec(@SQL)
Set @SQL = N'Update #tmpMainData set [' + @CTPrefix + 'Component ' + Cast(@Col as nvarchar) + N' Tax%] = 0;'
Set @SQL = @SQL + N'Update #tmpMainData set [' + @CTPrefix + 'Component ' + Cast(@Col as nvarchar) +  N' Tax Amount] = 0;'
Exec(@SQL)
set @Col = @Col + 1
--  end
End

----------For every Category and percentage combination
Declare TaxFetch cursor for
select Product_Code from #tmpCompWiseData where  CS_TaxCode = 0   group by Product_Code

Open TaxFetch
Fetch next from Taxfetch into @Product_Code
While(@@FETCH_STATUS =0)
begin
--get the componentwise tax value in the order of Tax_Component_Code
Set @col = 1 --Dynamic Column
Set @LTColCnt = 1
Set @CTColCnt = 1

Declare TaxData cursor for
select CompWiseTax,CompWiseTaxPer, CompType, Tax_Code,TaxComponent_desc,Tax_Component_code  from #tmpCompWiseData
where Product_Code = @Product_Code  and CS_TaxCode = 0
order by Tax_Component_Code, CompType Desc

Open TaxData
Fetch next from TaxData into @TaxCompVal, @TaxCompPer, @CompType1, @Tax_Code1 , @TaxComp_desc , @TaxComp_Code
While(@@FETCH_STATUS =0)
begin
--update the dynamic cols
if @CompType1  = @CTPrefix
Begin
--Update Value
--
Set @SQL=N'update #tmpMainData set [' + @CTPrefix + 'Component ' +  Cast(@CTColCnt as nvarchar) + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''
Exec(@SQL)
--Update Percentage
Set @SQL=N'update #tmpMainData set [' + @CTPrefix + 'Component ' +  Cast(@CTColCnt as nvarchar) + N' Tax%] = ' + Cast(@TaxCompPer as nvarchar)
Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''
Exec(@SQL)
set @CTColCnt = @CTColCnt + 1
-- end
End
Else
Begin
--Update Value

Set @SQL=N'update #tmpMainData set [' + @LTPrefix + 'Component ' + Cast(@LTColCnt as nvarchar) + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''
Exec(@SQL)
--Update Percentage
Set @SQL=N'update #tmpMainData set [' + @LTPrefix + 'Component ' + Cast(@LTColCnt as nvarchar) + N' Tax%] = ' + Cast(@TaxCompPer as nvarchar)
Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''
Exec(@SQL)
set @LTColCnt = @LTColCnt + 1
--  end
End
set @Col = @Col + 1
Fetch next from TaxData into @TaxCompVal, @TaxCompPer, @CompType1, @Tax_Code1  ,@TaxComp_desc  ,@TaxComp_Code
End
Close TaxData
Deallocate TaxData
Fetch next from Taxfetch into @Product_Code
End
Close TaxFetch
Deallocate TaxFetch

End

--------------------------------------------------------------------------------------------------------- second cursor

Declare TaxData cursor for
select distinct TaxComponent_desc from #tmpCompWiseData where CS_TaxCode > 0
--order by Tax_Component_Code, CompType Desc

Open TaxData
Fetch next from TaxData into @TaxComp_desc
While(@@FETCH_STATUS =0)
begin
--update the dynamic cols
-- if @CompType1  = @CTPrefix
Begin
--Update Value
Set @SQL =  N'Alter Table #tmpMainData Add [' +@TaxComp_desc + N' Tax Amount] decimal(18,6) default 0;'
Set @SQL = @SQL +N'Alter Table #tmpMainData Add ['+@TaxComp_desc+ N' Tax Rate] decimal(18,6) default 0;'
Exec(@SQL)
Print @SQL
--  Set @SQL=N'update #tmpMainData set [' +@TaxComp_desc + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
-- Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''--and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
--  Exec(@SQL)
--  --Update Percentage
--Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc+ N'TaxRate] = ' + Cast(@TaxCompPer as nvarchar)
--Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''--and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
--  Exec(@SQL)
set @CTColCnt = @CTColCnt + 1
-- end
End
-- Else
--              Begin
--                   --Update Value

--Set @SQL = @SQL + N'Alter Table #tmpMainData Add ['+@TaxComp_desc + N' Tax Amount] decimal(18,6) default 0;'
--Set @SQL = N'Alter Table #tmpMainData Add ['+@TaxComp_desc+ N'TaxRate] decimal(18,6) default 0;'
--Exec(@SQL)
--                  Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
--                 Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''''-- and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N'''and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
--                   Exec(@SQL)
--                   --Update Percentage
--                  Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc+ N'TaxRate] = ' + Cast(@TaxCompPer as nvarchar)
--                  Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' '--and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N'''and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
--                   Exec(@SQL)
--                   set @LTColCnt = @LTColCnt + 1
--                 --  end
--              End
set @Col = @Col + 1
Fetch next from TaxData into @TaxComp_desc
End
Close TaxData
Deallocate TaxData

Declare TaxFetch cursor for
select Product_Code from #tmpCompWiseData where  CS_TaxCode > 0   group by Product_Code

Open TaxFetch
Fetch next from Taxfetch into @Product_Code
While(@@FETCH_STATUS =0)
begin
--get the componentwise tax value in the order of Tax_Component_Code
Set @col = 1 --Dynamic Column
Set @LTColCnt = 1
Set @CTColCnt = 1

Declare TaxData cursor for
select CompWiseTax,CompWiseTaxPer, CompType, Tax_Code,TaxComponent_desc,Tax_Component_code from #tmpCompWiseData
where Product_Code = @Product_Code  and CS_TaxCode > 0
order by Tax_Component_Code, CompType Desc

Open TaxData
Fetch next from TaxData into @TaxCompVal, @TaxCompPer, @CompType1, @Tax_Code1 ,@TaxComp_desc , @TaxComp_Code
While(@@FETCH_STATUS =0)
begin
--update the dynamic cols
-- if @CompType1  = @CTPrefix
Begin
--Update Value
--                  Set @SQL = @SQL + N'Alter Table #tmpMainData Add [' +@TaxComp_desc + N' Tax Amount] decimal(18,6) default 0;'
--                  Set @SQL = N'Alter Table #tmpMainData Add ['+@TaxComp_desc+ N'TaxRate] decimal(18,6) default 0;'
--Exec(@SQL)
Set @SQL=N'update #tmpMainData set [' +@TaxComp_desc + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''--and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
Exec(@SQL)
Print @SQL
--Update Percentage
Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc+ N' Tax Rate] = ' + Cast(@TaxCompPer as nvarchar)
Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N''''--and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
Exec(@SQL)
print @SQL
set @CTColCnt = @CTColCnt + 1
-- end
End
-- Else
--              Begin
--                   --Update Value

--Set @SQL = @SQL + N'Alter Table #tmpMainData Add ['+@TaxComp_desc + N' Tax Amount] decimal(18,6) default 0;'
--Set @SQL = N'Alter Table #tmpMainData Add ['+@TaxComp_desc+ N'TaxRate] decimal(18,6) default 0;'
--Exec(@SQL)
--                  Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc + N' Tax Amount] = ' + Cast(@TaxCompVal as nvarchar)
--                 Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''''-- and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N'''and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
--                   Exec(@SQL)
--                   --Update Percentage
--                  Set @SQL=N'update #tmpMainData set ['+@TaxComp_desc+ N'TaxRate] = ' + Cast(@TaxCompPer as nvarchar)
--                  Set @SQL= @SQL + N' where [Item Code] = ''' +  Cast(@Product_Code as nvarchar) + N''' '--and Tax_Code = ''' +  Cast(@Tax_Code1 as nvarchar) + N'''and Tax_Component_code = ''' + CAST (@TaxComp_Code as int)
--                   Exec(@SQL)
--                   set @LTColCnt = @LTColCnt + 1
--                 --  end
--              End
set @Col = @Col + 1
Fetch next from TaxData into @TaxCompVal, @TaxCompPer, @CompType1, @Tax_Code1  ,@TaxComp_desc  ,@TaxComp_Code
End
Close TaxData
Deallocate TaxData
Fetch next from Taxfetch into @Product_Code
End
Close TaxFetch
Deallocate TaxFetch
select * from #tmpMainData
drop table #tmpMainData
drop table #tmpCompWiseData
Drop table #tmpMainDataTwo
End


