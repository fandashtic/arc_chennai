CREATE procedure spr_list_Itemwise_VAT_Report          
(          
          
 @FromDate datetime,           
 @ToDate DateTime,          
 @Tax nvarchar(10),          
 @Locality nvarchar(15),          
 @ItemCode nvarchar(2550)
-- @ItemName nvarchar(2550) --Unused         
)           
as
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @ItemCode='%'
   insert into #tmpProd select product_code from items
else
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)
          
begin          
 declare @TaxValue decimal(18,6)  
 If @Tax = '%'   
 set @TaxValue = 0  
 else  
 Set @TaxValue = convert(decimal(18,6),@Tax)  
           
create table #VATReport          
(          
 [Tax Code] Int,
 [Temp Tax Desc] nvarchar(520) COLLATE SQL_Latin1_General_CP1_CI_AS,          
 [Tax Desc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,          
 [Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,          
 [Total Purchase (%c)]  Decimal(18,6),          
 [Tax on Purchase (%c)]  Decimal(18,6),          
 [Total Purchase Return (%c)]  Decimal(18,6),          
 [Tax on Purchase Return (%c)]  Decimal(18,6),          
 [Net Purchase (%c)]  Decimal(18,6),          
 [Net Purchase Tax (%c)]  Decimal(18,6),          
 [Total Sales (%c)]  Decimal(18,6),          
 [Tax on Sales (%c)]  Decimal(18,6),          
 [Total Retail Sales (%c)]  Decimal(18,6),          
 [Tax on Retail Sales (%c)]  Decimal(18,6),          
 [Sales Return Saleable (%c)]  Decimal(18,6),          
 [Tax on Sales Return Saleable (%c)]  Decimal(18,6),          
 [Sales Return Damages (%c)]  Decimal(18,6),          
 [Tax on Sales Return Damages (%c)]  Decimal(18,6),          
 [Total Retail Sales Return (%c)]  Decimal(18,6),          
 [Tax on Retail Sales Return (%c)]  Decimal(18,6),          
 [Net Sales Return (%c)]  Decimal(18,6),          
 [Net Tax on Sales Return (%c)]  Decimal(18,6),          
 [Net Sales (%c)]  Decimal(18,6),          
 [Net Tax on Sales (%c)]  Decimal(18,6),          
 [Net VAT Payable (%c)] Decimal(18,6)          
)          
          
          
if Isnumeric(@Tax) = 1          
begin          
 set @Tax = convert(nvarchar,convert(decimal(18,6),@Tax))          
end          
else          
begin          
 set @Tax = '%'          
end          
           
--take distinct (products and tax percentages) from Bills, Adj Returns and Invoices          
insert into #VATReport ([Tax Code], [Temp Tax Desc], [Tax Desc], [Tax %])          
-- Bills           
          
select  IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,BD.TaxSuffered)+char(15)+   
(case when BD.TaxSuffered = 0 then 'Exempt' else max([Tax_Description]) end),   
(case when BD.TaxSuffered = 0 then 'Exempt' else max([Tax_Description]) end),    
(case when BD.TaxSuffered = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end)  
from BillAbstract BA
Inner Join BillDetail BD On BA.BillID = BD.BillID
Inner Join Vendors V On V.VendorID = BA.VendorID
Left Outer Join Tax  On BD.TaxCode = Tax.Tax_Code
where--It.ProductName like @ItemName and         
 BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)         
 and BA.BillDate between @FromDate and @ToDate          
 and BA.Status = 0          
 and (  
  BD.TaxSuffered = @TaxValue  
  Or @Tax = '%'  
 )  
-- and BD.TaxSuffered *= Tax.Percentage  
 and V.Locality like (          
 case @Locality           
 when 'Local' then '1'          
 when 'Outstation' then '2'          
 else '%' end)          
group by Tax.Tax_Code, BD.TaxSuffered
--having SUM(BD.Amount + BD.TaxAmount)>0          
          
-- purchase Return          
union  
Select IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,ARD.Tax)+char(15)+   
(case when ARD.Tax = 0 then 'Exempt' else max([Tax_Description]) end),   
(case when ARD.Tax = 0 then 'Exempt' else max([Tax_Description]) end),   
(case when ARD.Tax = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end)  
from AdjustmentReturnDetail ARD
Inner Join AdjustmentReturnAbstract ARA On ARA.AdjustmentID = ARD.AdjustmentID 
Inner Join Vendors V On ARA.VendorID = V.VendorID
Left Outer Join Tax  On ARD.Tax = Tax.Percentage  and ARD.TaxSuffApplicableOn = Tax.LSTApplicableOn and ARD.TaxSuffPartOff = Tax.LSTPartOff 
where 
--It.ProductName like @ItemName and         
 ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)          
 and (isnull(ARA.Status,0) & 128) = 0          
 and ARA.AdjustmentDate between @FromDate and @ToDate          
 and (  
  ARD.Tax = @TaxValue  
  Or @Tax = '%'  
 )  
 and cast(V.Locality as nvarchar) like           
 (case @Locality           
 when 'Local' then '1'           
 when 'Outstation' then '2'           
 else '%' end) + '%'          
group by Tax.Tax_Code, ARD.Tax
--having sum(ARD.Total_Value)>0          
          
union  
Select IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,IDt.TaxCode)+char(15)+   
(Case When IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),   
(Case When IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),   
(Case When IDt.TaxCode = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end)  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID
Inner Join Customer C On C.CustomerID = IA.CustomerID 
Left Outer Join Tax On IDt.TaxID = Tax.Tax_Code  
where           
--It.ProductName like @ItemName and         
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and IA.InvoiceDate between @FromDate and @ToDate          
and (          
 (--Trade Invoice----------------          
  (IA.Status & 192) = 0          
  and IA.InvoiceType in (1, 3)          
 )-------------------------------          
 or     
 (--Sales Return-----------------        
 (IA.Status & 192) = 0  
    and IA.InvoiceType = 4        
 )-------------------------------        
)          
and (  
  IDt.TaxCode = @TaxValue  
  or @Tax = '%'  
  )  
--and IDt.TaxCode *= Tax.Percentage  
and C.Locality = 1       
and (case @Locality when '%' then 1 when 'Local' then 1 else 0 end) = 1          
group by Tax.Tax_Code,IDt.TaxCode, C.Locality
union  
Select IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,IDt.TaxCode2)+char(15)+   
(Case When IDt.TaxCode2 = 0 then 'Exempt' else max([Tax_Description]) end),   
(Case When IDt.TaxCode2 = 0 then 'Exempt' else max([Tax_Description]) end),   
(Case When IDt.TaxCode2 = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) end)  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID
 Inner Join Customer C On C.CustomerID = IA.CustomerID
 Left Outer Join Tax  On IDt.TaxID = Tax.Tax_Code
where           
--It.ProductName like @ItemName and         
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and IA.InvoiceDate between @FromDate and @ToDate          
and (          
 (--Trade Invoice----------------          
  (IA.Status & 192) = 0          
  and IA.InvoiceType in (1, 3)          
 )-------------------------------          
 or     
 (--Sales Return-----------------        
 (IA.Status & 192) = 0  
    and IA.InvoiceType = 4        
 )-------------------------------        
)          
and (  
  IDt.TaxCode2 = @TaxValue  
  or @Tax = '%'  
  )  
--and IDt.TaxCode2 *= Tax.CST_Percentage  
and C.Locality = 2  
and (case @Locality when '%' then 1 when 'Outstation' then 1 else 0 end) = 1                  
group by Tax.Tax_Code, C.Locality, IDt.TaxCode2
--having sum(IDt.Amount)>0          
union  
-- Retail Invoice          
Select IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,IDt.TaxCode)+char(15)+   
(Case When IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),   
(Case When IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),   
(Case When IDt.TaxCode = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end)  
from InvoiceAbstract IA
Inner Join  InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID
Right Outer Join Customer C On C.CustomerID = Cast(IA.CustomerID  as int)
Inner Join Tax  On IDt.TaxID = Tax.Tax_Code
where --It.ProductName like @ItemName and         
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and IA.InvoiceDate between @FromDate and @ToDate          
and (Isnull(IA.Status, 0) & 192) = 0          
and IA.InvoiceType in (2,5,6)          
and (  
  IDt.TaxCode = @TaxValue  
  or @Tax = '%'  
  )  
--and IDt.TaxCode *= Tax.Percentage  
and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1          
group by Tax.Tax_Code, IDt.TaxCode
--having sum(IDt.Amount)>0          
--order By BD.TaxSuffered          
--Total Purchase amount          
update #VATReport set [Total Purchase (%c)] =  (          
 select SUM(BD.Amount)          
 from BillDetail BD, BillAbstract BA, Vendors V
 where BD.BillID = BA.BillID          
 and BA.Status = 0           
 and BA.BillDate between @FromDate and @ToDate          
 and BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)         
 and (case when BD.TaxSuffered=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end) = [Tax %]  
 and V.VendorID = BA.VendorID          
 and (  
  ([Tax Desc] = 'Exempt' and BD.TaxSuffered = 0) or   
  (  
   BD.TaxSuffered = (case V.Locality when 1 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)   
     and [Tax Desc] = (Case when BD.TaxSuffered=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)  
  )  
 )  
 and [Tax Code] = BD.TaxCode
 and V.Locality like (case @Locality           
    when 'Local' then '1'          
    when 'Outstation' then '2'          
    else '%' end)          
)          

------------------------------------------------------------------------------------
--select * from #VATReport
------------------------------------------------------------------------------------          
--Tax amount on Purchase          
update #VATReport set [Tax on Purchase (%c)] =  (          
 select SUM(BD.TaxAmount)          
 from BillDetail BD, BillAbstract BA, Vendors V
 where BD.BillID = BA.BillID       
  and BA.Status = 0           
  and BA.BillDate between @FromDate and @ToDate          
  and BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)         
  and convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) = [Tax %]  
  and V.VendorID = BA.VendorID          
  and BD.TaxSuffered = (case V.Locality when 1 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)   
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])  
  and [Tax Code] = IsNull(BD.TaxCode, 0)
  and V.Locality like (          
  case @Locality           
  when 'Local' then '1'          
  when 'Outstation' then '2'          
  else '%' end          
 )          
)          
--Total Purchase Return amount          
update #VATReport set [Total Purchase Return (%c)] = (          
 select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V
 where ARA.AdjustmentID = ARD.AdjustmentID          
  and (isnull(ARA.Status,0) & 128) = 0          
  and ARA.AdjustmentDate between @FromDate and @ToDate          
  and ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
  and (Case when ARD.Tax=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end) = [Tax %]  
  and V.VendorID = ARA.VendorID          
  and (  
  ([Tax Desc] = 'Exempt' and ARD.Tax = 0) or   
  (  
   ARD.Tax = (case V.Locality when 1 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)   
     and [Tax Desc] = (Case when ARD.Tax=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)  
  )  
 )  
  and V.Locality like (          
  case @Locality           
  when 'Local' then '1'          
  when 'Outstation' then '2'          
  else '%' end          
 )          
)          
--Tax amount on Purchase Return          
update #VATReport set [Tax on Purchase Return (%c)] = (          
 select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V
 where ARA.AdjustmentID = ARD.AdjustmentID          
  and (isnull(ARA.Status,0) & 128) = 0          
  and ARA.AdjustmentDate between @FromDate and @ToDate          
  and ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)          
  and convert(nvarchar,convert(decimal(18,6),ARD.Tax)) = [Tax %]  
  and ARA.VendorID = V.VendorID          
  and ARD.Tax = (case V.Locality when 1 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)   
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])  
  and cast(V.Locality as nvarchar) like (case @Locality           
  when 'Local' then '1'           
  when 'Outstation' then '2'           
  else '%' end) + '%'          
)          

------------------------------------------------------------------------------------
--select * from #VATReport
-------------------------------------------------------------------------------------          
          
update #VATReport set [Net Purchase (%c)] = isnull([Total Purchase (%c)],0) - isnull([Total Purchase Return (%c)],0)          
update #VATReport set [Net Purchase Tax (%c)] = isnull([Tax on Purchase (%c)],0) - isnull([Tax on Purchase Return (%c)],0)          
          
----------------------------------------------------------------------------------------
--select * from #VATReport
------------------------------------------------------------------------------------
          
--Total sales amount          
update #VATReport set [Total Sales (%c)] = (          
          
select sum(IDt.Amount) - sum(case @Locality           
when 'Local' then isnull(IDt.STPayable,0)          
when 'Outstation' then isnull(IDT.CSTPayable,0)          
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
where Idt.InvoiceID = IA.InvoiceID          
and (IA.Status & 192) = 0          
and IA.InvoiceType in (1, 3)          
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and [Tax %] = (case C.Locality when 1 then  
     (case when IDt.TaxCode=0 then 'Exempt'   
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)  
      else   
     (case when IDt.TaxCode2=0 then 'Exempt'   
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)   
    End)  
and [Tax Code] = IsNull(IDt.TaxID, 0)
and IA.CustomerID = C.CustomerID          
and ((C.Locality = 1 and ([Tax Desc] = 'Exempt' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or  
 (C.Locality = 2 and ([Tax Desc] = 'Exempt' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))  
and [Tax Desc] = (Case [Tax Desc] when 'Exempt' then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end)  
and cast(C.Locality as nvarchar) like (case @Locality           
when 'Local' then '1'           
when 'Outstation' then '2'           
else '%' end) + '%'          
)          
          
--Tax on sales          
update #VATReport set [Tax on Sales (%c)] = (          
select sum(case @Locality           
when 'Local' then isnull(IDt.STPayable,0)          
when 'Outstation' then isnull(IDT.CSTPayable,0)          
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)           
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
where Idt.InvoiceID = IA.InvoiceID          
and (IA.Status & 192) = 0          
and IA.InvoiceType in (1, 3)          
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and [Tax %] = (case C.Locality when 1 then  
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode))   
      else   
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2))   
    End)  
and [Tax Code] = IsNull(IDt.TaxID, 0)
and IA.CustomerID = C.CustomerID          
and ((C.Locality = 1 and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or  
 (C.Locality = 2 and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))  
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc])  
and cast(C.Locality as nvarchar) like (case @Locality           
 when 'Local' then '1'           
 when 'Outstation' then '2'           
 else '%' end) + '%'          
)          
          
-- Update Total Retail Sales           
update #VATReport set  [Total Retail Sales (%c)] = (          
select sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0))  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID
Left Outer Join Customer C On IA.CustomerID = C.CustomerID          
where (IA.Status & 192) = 0          
and IA.InvoiceType in (2)          
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and (case when IDt.TaxCode=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end) = [Tax %]  
and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1  
and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = [Tax Desc]) end)  
and [Tax Desc] = (case when IDt.TaxCode=0 then 'Exempt' else (select Tax.Tax_Description from tax where Tax_Description = [Tax Desc]) end)  
and [Tax Code] = IsNUll(IDt.TaxID, 0)
and IDt.Amount>-1  
)  
          
-- Update Tax Retail Sales           
update #VATReport set [Tax on Retail Sales (%c)] = (          
select sum(isnull(IDt.STPayable,0))  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID
Left Outer Join Customer C On IA.CustomerID = C.CustomerID
Inner Join Tax  On IDt.TaxCode = Tax.Percentage   
where (IA.Status & 192) = 0          
and IA.InvoiceType in (2)          
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) = [Tax %]  
and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1  
and Tax.Tax_Description = [Tax Desc]  
and [Tax Code] = IsNull(IDt.TaxID, 0)
and IDt.Amount>-1  
)  
  
          
--Total Sales return saleable amount          
update #VATReport set [Sales Return Saleable (%c)] = (          
select sum(isnull(IDt.Amount, 0)) - sum(case @Locality           
when 'Local' then isnull(IDt.STPayable,0)          
when 'Outstation' then isnull(IDT.CSTPayable,0)          
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
where Idt.InvoiceID = IA.InvoiceID          
 and (IA.Status & 192) = 0           
 and (IA.Status & 32) = 0  
 and IA.InvoiceType = 4           
 and IDt.SalePrice <> 0          
 and IA.InvoiceDate between @FromDate and @ToDate          
 and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
 and [Tax %] = (case C.Locality when 1 then  
     (case when IDt.TaxCode=0 then 'Exempt'   
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)  
      else   
     (case when IDt.TaxCode2=0 then 'Exempt'   
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)   
    End)  
 and [Tax Code] = IsNull(IDt.TaxID, 0)
 and IA.CustomerID = C.CustomerID          
 and ((C.Locality = 1 and ([Tax Desc] = 'Exempt' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or  
 (C.Locality = 2 and ([Tax Desc] = 'Exempt' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))  
 and [Tax Desc] = (Case [Tax Desc] when 'Exempt' then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end)  
 and cast(C.Locality as nvarchar) like (case @Locality           
     when 'Local' then '1'           
     when 'Outstation' then '2'           
     else '%' end) + '%'          
)          
          
--tax amount on sales return saleable          
update #VATReport set [Tax on Sales Return Saleable (%c)] = (          
select sum(case @Locality           
when 'Local' then isnull(IDt.STPayable,0)          
when 'Outstation' then isnull(IDT.CSTPayable,0)          
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)           
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C  
where Idt.InvoiceID = IA.InvoiceID          
and (IA.Status & 192) = 0           
and (IA.Status & 32) = 0           
and IA.InvoiceType = 4           
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and [Tax %] = (case C.Locality when 1 then  
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode))  
      else   
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2))  
    End)  
and [Tax Code] = IsNull(IDt.TaxID, 0)
and IA.CustomerID = C.CustomerID          
and ((C.Locality = 1 and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or  
 (C.Locality = 2 and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))  
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc])  
and cast(C.Locality as nvarchar) like (case @Locality           
     when 'Local' then '1'           
     when 'Outstation' then '2'           
     else '%' end) + '%'          
)          
          
--total Sales Return Damages          
update #VATReport set [Sales Return Damages (%c)] = (          
select sum(IDt.Amount)  - sum(case @Locality           
when 'Local' then isnull(IDt.STPayable,0)          
when 'Outstation' then isnull(IDT.CSTPayable,0)          
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
where Idt.InvoiceID = IA.InvoiceID 
and (IA.Status & 192) = 0           
and (IA.Status & 32) <> 0           
and IA.InvoiceType = 4           
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and [Tax %] = (case C.Locality when 1 then  
     (case when IDt.TaxCode=0 then 'Exempt'   
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)  
      else   
     (case when IDt.TaxCode2=0 then 'Exempt'   
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)   
    End)  
and [Tax Code] = IsNull(IDt.TaxID, 0)
and IA.CustomerID = C.CustomerID          
and ((C.Locality = 1 and ([Tax Desc] = 'Exempt' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or  
 (C.Locality = 2 and ([Tax Desc] = 'Exempt' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))  
and [Tax Desc] = (Case [Tax Desc] when 'Exempt' then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end)  
and cast(C.Locality as nvarchar) like (case @Locality           
     when 'Local' then '1'           
     when 'Outstation' then '2'           
     else '%' end) + '%'          
)          
          
--Tax amount on sales return damages          
update #VATReport set [Tax on Sales Return Damages (%c)] = (          
select sum(case @Locality           
when 'Local' then isnull(IDt.STPayable,0)          
when 'Outstation' then isnull(IDT.CSTPayable,0)          
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)           
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
where Idt.InvoiceID = IA.InvoiceID          
and (IA.Status & 192) = 0           
and (IA.Status & 32) <> 0           
and IA.InvoiceType = 4           
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and [Tax %] = (case C.Locality when 1 then  
     (case when IDt.TaxCode=0 then 'Exempt'   
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)  
      else   
     (case when IDt.TaxCode2=0 then 'Exempt'   
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)   
    End)  
and [Tax Code] = IsNull(IDt.TaxID, 0)
and IA.CustomerID = C.CustomerID          
and ((C.Locality = 1 and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or  
 (C.Locality = 2 and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))  
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc])  
and cast(C.Locality as nvarchar) like (case @Locality           
     when 'Local' then '1'           
     when 'Outstation' then '2'           
     else '%' end) + '%'          
)          
-- Update Total Retail Sales Return  
update #VATReport set  [Total Retail Sales Return (%c)] = (          
select abs(sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0)))  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID
Left Outer Join Customer C On IA.CustomerID = C.CustomerID          
where (IA.Status & 192) = 0          
and IA.InvoiceType in (5,6)          
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and (case when IDt.TaxCode=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end) = [Tax %]  
and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1  
and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = [Tax Desc]) end)  
and [Tax Desc] = (case when IDt.TaxCode=0 then 'Exempt' else (select Tax.Tax_Description from tax where Tax_Description = [Tax Desc]) end)  
and [Tax Code] = IsNull(IDt.TaxID, 0)
--and IDt.Amount<0  
)  
          
-- Update Tax Retail Sales Return  
update #VATReport set [Tax on Retail Sales Return (%c)] = (          
select abs(sum(isnull(IDt.STPayable,0)))  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID
Left Outer Join Customer C On IA.CustomerID = C.CustomerID
Inner Join Tax On IDt.TaxCode = Tax.Percentage   
where (IA.Status & 192) = 0          
and IA.InvoiceType in (5,6)          
and IDt.SalePrice <> 0          
and IA.InvoiceDate between @FromDate and @ToDate          
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
and (case when IDt.TaxCode=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end) = [Tax %]  
and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1  
and [Tax Desc] = Tax.Tax_Description  
and [Tax Code] = IsNull(IDt.TaxID, 0)
--and IDt.Amount<0  
)  
  
------------------------------------------------------------------------------------------------
--select * from #VATReport
---------------------------------------------------------------------------------------------        
update #VATReport set [Net Sales Return (%c)] = isnull([Sales Return Saleable (%c)],0) + isnull([Sales Return Damages (%c)],0) + isnull([Total Retail Sales Return (%c)],0)  
update #VATReport set [Net Tax on Sales Return (%c)] = isnull([Tax on Sales Return Saleable (%c)],0) + isnull([Tax on Sales Return Damages (%c)],0) + isnull([Tax on Retail Sales Return (%c)],0)  
  
Update #VATReport set [Total Sales (%c)] = Isnull([Total Sales (%c)], 0)  
Update #VATReport set [Tax on Sales (%c)] = Isnull([Tax on Sales (%c)], 0)  
  
Update #VATReport set [Total Purchase (%c)] = (case [Total Purchase (%c)] when 0 then null else [Total Purchase (%c)] end)          
Update #VATReport set [Tax on Purchase (%c)] = (case [Tax on Purchase (%c)] when 0 then null else [Tax on Purchase (%c)] end)  
Update #VATReport set [Total Purchase Return (%c)] = (case [Total Purchase Return (%c)] when 0 then null else [Total Purchase Return (%c)] end)          
Update #VATReport set [Tax on Purchase Return (%c)] = (case [Tax on Purchase Return (%c)] when 0 then null else [Tax on Purchase Return (%c)] end)          
Update #VATReport set [Net Purchase (%c)] = (case [Net Purchase (%c)] when 0 then null else [Net Purchase (%c)] end)          
Update #VATReport set [Net Purchase Tax (%c)] = (case [Net Purchase Tax (%c)] when 0 then null else [Net Purchase Tax (%c)] end)          
Update #VATReport set [Total Sales (%c)] = (case [Total Sales (%c)] when 0 then null else [Total Sales (%c)]  end)          
Update #VATReport set [Tax on Sales (%c)] = (case [Tax on Sales (%c)] when 0 then null else [Tax on Sales (%c)] end)          
Update #VATReport set [Sales Return Saleable (%c)] = (case [Sales Return Saleable (%c)] when 0 then null else [Sales Return Saleable (%c)] end)          
Update #VATReport set [Tax on Sales Return Saleable (%c)] = (case [Tax on Sales Return Saleable (%c)] when 0 then null else [Tax on Sales Return Saleable (%c)] end)          
Update #VATReport set [Sales Return Damages (%c)] = (case [Sales Return Damages (%c)] when 0 then null else [Sales Return Damages (%c)] end)          
Update #VATReport set [Tax on Sales Return Damages (%c)] = (case [Tax on Sales Return Damages (%c)] when 0 then null else [Tax on Sales Return Damages (%c)] end)          
  
Update #VATReport set [Total Retail Sales (%c)] = (case [Total Retail Sales (%c)] when 0 then null else [Total Retail Sales (%c)] end)        
Update #VATReport set [Tax on Retail Sales (%c)] = (case [Tax on Retail Sales (%c)] when 0 then null else [Tax on Retail Sales (%c)] end)        
Update #VATReport set [Total Retail Sales Return (%c)] = (case [Total Retail Sales Return (%c)] when 0 then null else [Total Retail Sales Return (%c)] end)        
Update #VATReport set [Tax on Retail Sales Return (%c)] = (case [Tax on Retail Sales Return (%c)] when 0 then null else [Tax on Retail Sales Return (%c)] end)        
  
update #VATReport set [Net Sales (%c)] = isnull([Total Sales (%c)],0) + isnull([Total Retail Sales (%c)],0) - isnull([Net Sales Return (%c)],0)          
update #VATReport set [Net Tax on Sales (%c)] = isnull([Tax on Sales (%c)],0) + isnull([Tax on Retail Sales (%c)],0) - isnull([Net Tax on Sales Return (%c)],0)          
update #VATReport set [Net VAT Payable (%c)] = isnull([Net Tax on Sales (%c)],0) - isnull([Net Purchase Tax (%c)],0)          
  
Update #VATReport set [Net Sales Return (%c)] = (case [Net Sales Return (%c)] when 0 then null else [Net Sales Return (%c)] end)          
Update #VATReport set [Net Tax on Sales Return (%c)] = (case [Net Tax on Sales Return (%c)] when 0 then null else [Net Tax on Sales Return (%c)] end)          
Update #VATReport set [Net Sales (%c)] = (case [Net Sales (%c)] when 0 then null else [Net Sales (%c)] end)          
Update #VATReport set [Net Tax on Sales (%c)] = (case [Net Tax on Sales (%c)] when 0 then null else [Net Tax on Sales (%c)] end)          
Update #VATReport set [Net VAT Payable (%c)] = (case [Net VAT Payable (%c)] when 0 then null else [Net VAT Payable (%c)] end)          
  
Update #VATReport set [Tax Desc] = 'Exempt' where [Tax %]='Exempt'  

--------------------------------------------------------------------------------------
--select * from #VATReport
------------------------------------------------------------------------------------

          
select [Temp Tax Desc], [Tax Desc], [Tax %], 
[Total Purchase (%c)] = Sum(IsNull([Total Purchase (%c)], 0)),          
[Tax on Purchase (%c)] = Sum(IsNull([Tax on Purchase (%c)], 0)), 
[Total Purchase Return (%c)] = Sum(IsNull([Total Purchase Return (%c)], 0)), 
[Tax on Purchase Return (%c)] = Sum(IsNull([Tax on Purchase Return (%c)], 0)),
[Net Purchase (%c)] = Sum(IsNull([Net Purchase (%c)], 0)), 
[Net Purchase Tax (%c)] = Sum(IsNull([Net Purchase Tax (%c)], 0)), 
[Total Sales (%c)]= Sum(IsNull([Total Sales (%c)], 0)),
[Tax on Sales (%c)] = Sum(IsNull([Tax on Sales (%c)], 0)), 
[Total Retail Sales (%c)] = Sum(IsNull([Total Retail Sales (%c)], 0)), 
[Tax on Retail Sales (%c)] = Sum(IsNull([Tax on Retail Sales (%c)], 0)), 
[Sales Return Saleable (%c)] = Sum(IsNull([Sales Return Saleable (%c)], 0)), 
[Tax on Sales Return Saleable (%c)] = Sum(IsNull([Tax on Sales Return Saleable (%c)], 0)),
[Sales Return Damages (%c)] = Sum(IsNull([Sales Return Damages (%c)], 0)), 
[Tax on Sales Return Damages (%c)] = Sum(IsNull([Tax on Sales Return Damages (%c)], 0)), 
[Total Retail Sales Return (%c)] = Sum(IsNull([Total Retail Sales Return (%c)], 0)),   
[Tax on Retail Sales Return (%c)] = Sum(IsNull([Tax on Retail Sales Return (%c)], 0)), 
[Net Sales Return (%c)] = Sum(IsNull([Net Sales Return (%c)], 0)), 
[Net Tax on Sales Return (%c)] = Sum(IsNull([Net Tax on Sales Return (%c)], 0)),   
[Net Sales (%c)] = Sum(IsNull([Net Sales (%c)], 0)), 
[Net Tax on Sales (%c)] = Sum(IsNUll([Net Tax on Sales (%c)], 0)), 
[Net VAT Payable (%c)] = Sum(IsNull([Net VAT Payable (%c)], 0))
From (

select [Temp Tax Desc] = Case [Tax Desc] When 'Exempt' Then 
Convert(nVarChar, 0) + char(15) + Convert(nVarChar, 0) + char(15) + 'Exempt' Else 
[Temp Tax Desc] End
, [Tax Desc], [Tax %], [Total Purchase (%c)] = Sum(IsNull([Total Purchase (%c)], 0)),          
[Tax on Purchase (%c)] = Sum(IsNull([Tax on Purchase (%c)], 0)), 
[Total Purchase Return (%c)] = Sum(IsNull([Total Purchase Return (%c)], 0)), 
[Tax on Purchase Return (%c)] = Sum(IsNull([Tax on Purchase Return (%c)], 0)),
[Net Purchase (%c)] = Sum(IsNull([Net Purchase (%c)], 0)), 
[Net Purchase Tax (%c)] = Sum(IsNull([Net Purchase Tax (%c)], 0)), 
[Total Sales (%c)]= Sum(IsNull([Total Sales (%c)], 0)),
[Tax on Sales (%c)] = Sum(IsNull([Tax on Sales (%c)], 0)), 
[Total Retail Sales (%c)] = Sum(IsNull([Total Retail Sales (%c)], 0)), 
[Tax on Retail Sales (%c)] = Sum(IsNull([Tax on Retail Sales (%c)], 0)), 
[Sales Return Saleable (%c)] = Sum(IsNull([Sales Return Saleable (%c)], 0)), 
[Tax on Sales Return Saleable (%c)] = Sum(IsNull([Tax on Sales Return Saleable (%c)], 0)),
[Sales Return Damages (%c)] = Sum(IsNull([Sales Return Damages (%c)], 0)), 
[Tax on Sales Return Damages (%c)] = Sum(IsNull([Tax on Sales Return Damages (%c)], 0)), 
[Total Retail Sales Return (%c)] = Sum(IsNull([Total Retail Sales Return (%c)], 0)),   
[Tax on Retail Sales Return (%c)] = Sum(IsNull([Tax on Retail Sales Return (%c)], 0)), 
[Net Sales Return (%c)] = Sum(IsNull([Net Sales Return (%c)], 0)), 
[Net Tax on Sales Return (%c)] = Sum(IsNull([Net Tax on Sales Return (%c)], 0)),   
[Net Sales (%c)] = Sum(IsNull([Net Sales (%c)], 0)), 
[Net Tax on Sales (%c)] = Sum(IsNUll([Net Tax on Sales (%c)], 0)), 
[Net VAT Payable (%c)] = Sum(IsNull([Net VAT Payable (%c)], 0))
From #VATReport  Group By 
[Temp Tax Desc], [Tax Desc], [Tax %]
) vtr
Group By 
[Temp Tax Desc], [Tax Desc], [Tax %]
--Where ([Tax Code] > 0 And  Cast([Tax %] As decimal(18,6)) <> 0)   Or ( [Tax Code] = 0 And   [Tax %] = 'Exempt')

drop table #VATReport          
Drop table #tmpProd

end          



