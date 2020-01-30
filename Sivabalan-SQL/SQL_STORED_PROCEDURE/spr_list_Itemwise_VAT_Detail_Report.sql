CREATE procedure  spr_list_Itemwise_VAT_Detail_Report      
(      
      
 @Tax nvarchar(550),      
 @FromDate datetime,       
 @ToDate DateTime,      
 @TaxUnusedParameter nvarchar(10),      
 @Locality nvarchar(15),      
 @ItemCode nvarchar(510),      
 @ItemName nvarchar(510)      
)       
as      
begin      

 Declare @Delimeter as Char(1)      
 Set @Delimeter=Char(15)      

 declare @TaxCode int
 declare @TaxDesc nvarchar(510)
 declare @Pos as int
 declare @Pos1 as int
 set @Pos = charindex (char(15), @Tax, 1)
 set @TaxCode = substring(@Tax, 1, @Pos-1)
 set @Tax = substring(@Tax, @Pos + 1, 1000)
-- select @tax
 set @Pos = charindex (char(15), @Tax, 1)
--select @tax
 set @TaxDesc = substring(@Tax, @Pos + 1, 510)
 set @Tax = substring(@Tax, 1, @Pos - 1)
--select @tax

--select @TaxCode, @TaxDesc, @Tax
 
--select @pos, @TaxCode , @Pos1 , @Tax , @TaxDesc 

Create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @ItemCode='%'    
   insert into #tmpProd select product_code from items    
else    
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)    


  
 create table #VATReport      
 (      
  [ICode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,      
  [Item Code] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,      
  [Item Name] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,      
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

 --take distinct (products and tax percentages) from Bills, Adj Returns and Invoices      
 insert into #VATReport (ICode, [Item Code], [Item Name], [Tax %])      
  select Distinct It.Product_Code, It.Product_Code, It.ProductName, BD.TaxSuffered      
  from Items It, BillAbstract BA, BillDetail BD, Vendors V
  where       
--   It.ProductName like @ItemName and 
   BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)             
   and BA.BillID = BD.BillID      
   and BD.Product_Code = It.Product_Code      
   and BA.BillDate between @FromDate and @ToDate      
   and BA.Status = 0      
   and BD.TaxSuffered = convert(decimal(18,6),@Tax)
   and (
			Convert(Decimal(18, 6), @Tax) = (case V.Locality when 1 then (Select Tax.Percentage from tax where Tax_Description = @TaxDesc) else (Select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)
			or (convert(decimal(18,6),@Tax) = convert(decimal(18,6),0) and @TaxDesc = 'Exempt' and BD.TaxSuffered = convert(decimal(18,6),0))
		)
   and (
		IsNull(BD.TaxCode, 0) = (Case @TaxCode When 0 Then IsNull(BD.TaxCode, 0) 
					Else  @TaxCode End)
	)
   and V.VendorID = BA.VendorID      
   and (case when BD.TaxSuffered=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end)= @TaxDesc
   and V.Locality like (      
 case @Locality       
         when 'Local' then '1'      
         when 'Outstation' then '2'      
         else '%' end      
        )      
  group by BD.TaxCode, It.Product_Code, It.ProductName, BD.TaxSuffered      
  having SUM(BD.Amount + BD.TaxAmount)>0      
 union      
  select Distinct It.Product_Code, It.Product_Code, It.ProductName, ARD.Tax      
  from Items It, AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V
  where 
--It.ProductName like @ItemName and 
--   It.Product_Code like @ItemCode      
   ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)             
   and ARA.AdjustmentID = ARD.AdjustmentID      
   and (isnull(ARA.Status,0) & 128) = 0      
   and ARD.Product_Code = It.Product_Code      
   and ARA.AdjustmentDate between @FromDate and @ToDate      
   and (
			(ARD.Tax = 0 ) or
			ARD.Tax = (case V.Locality when 1 then (Select Tax.Percentage from tax where Tax_Description = @TaxDesc) else (Select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)
		)
   and ARD.Tax = Case When Convert(Decimal(18, 6), @Tax) = 0 Then ARD.Tax Else convert(decimal(18,6),@Tax) End
   and ARA.VendorID = V.VendorID      
   and (case when ARD.Tax=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc
   and cast(V.Locality as nvarchar) like (case @Locality       
             when 'Local' then '1'       
             when 'Outstation' then '2'       
             else '%' end) + '%'      
  group by It.Product_Code, It.ProductName, ARD.Tax      
  having sum(ARD.Total_Value)>0      
 union      
  select Distinct It.Product_Code, It.Product_Code, It.ProductName, IDt.TaxCode
  from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C
  where       
--   It.ProductName like @ItemName and 
   IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)             
   and IA.InvoiceID = IDt.InvoiceID      
   and IDt.Product_Code = It.Product_Code      
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
   and IDt.TaxCode = Case When Convert(Decimal(18, 6), @Tax) = 0 Then IDt.TaxCode Else convert(decimal(18,6),@Tax) End
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
   and C.CustomerID = IA.CustomerID      
   and C.Locality = 1
   and (case when IDt.TaxCode=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc
   and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = @TaxDesc) end)
   and (case @Locality when '%' then 1 when 'Local' then 1 else 0 end) = 1
  group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, C.Locality, IDt.TaxCode
  having sum(IDt.Amount)>0      
 union      
  select Distinct It.Product_Code, It.Product_Code, It.ProductName, IDt.TaxCode2
  from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax
  where       
--   It.ProductName like @ItemName and 
   IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)             
   and IA.InvoiceID = IDt.InvoiceID      
   and IDt.Product_Code = It.Product_Code      
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
   and IDt.TaxCode2 = Case When Convert(Decimal(18, 6), @Tax) = 0 Then IDt.TaxCode2 Else convert(decimal(18,6),@Tax) End
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
   and C.CustomerID = IA.CustomerID      
   and C.Locality = 2
   and (case when IDt.TaxCode2=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc
   and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode2=0 then 0 else (select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)
   and (case @Locality when '%' then 1 when 'Outstation' then 1 else 0 end) = 1
  group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, C.Locality, IDt.TaxCode2      
  having sum(IDt.Amount)>0      
      
Union      
select Distinct It.Product_Code, It.Product_Code, It.ProductName, IDt.TaxCode      
from  InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID
Inner Join Items It On IDt.Product_Code = It.Product_Code      
Right Outer Join Customer C On C.CustomerID = IA.CustomerID      
where       
-- It.ProductName like @ItemName and 
 IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)             
 and IA.InvoiceDate between @FromDate and @ToDate      
 and (IA.Status & 192) = 0      
 and IA.InvoiceType in (2)      
 and IDt.TaxCode = Case When Convert(Decimal(18, 6), @Tax) = 0 Then IDt.TaxCode Else convert(decimal(18,6),@Tax) End
 and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
 and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1
 and (case when IDt.TaxCode=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc
 and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = @TaxDesc) end)
group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode      
 order by It.ProductName, BD.TaxSuffered      
----------------------------------------------------------------------------
--select * from #VATReport
--------------------------------------------------------------------------      
 --Total Purchase amount      
 update #VATReport set [Total Purchase (%c)]  =  (      
  select SUM(BD.Amount)
  from BillDetail BD, BillAbstract BA, Vendors V, Items
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS      
   and Items.Product_Code = BD.Product_Code
   and BD.BillID = BA.BillID      
   and BA.Status = 0       
   and BA.BillDate between @FromDate and @ToDate      
   and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)
   and (	
			BD.TaxSuffered = (case V.locality when 1 then (select Tax.Percentage from tax where tax_description = @TaxDesc) else (select Tax.CST_Percentage from tax where tax_description = @TaxDesc) end)
			or (BD.TaxSuffered = 0 )
		)
   and IsNull(BD.TaxCode, 0) = Case When @TaxCode  = 0 Then IsNull(BD.TaxCode, 0) Else @TaxCode End
   and (case when BD.TaxSuffered=0 then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = @TaxDesc) end) = @TaxDesc
   and V.VendorID = BA.VendorID      
   and V.Locality like (      
         case @Locality       
         when 'Local' then '1'      
         when 'Outstation' then '2'      
         else '%' end      
        )      
 )      
      
 --Tax amount on Purchase      
 update #VATReport set [Tax on Purchase (%c)] =  (      
  select SUM(BD.TaxAmount)
  from BillDetail BD, BillAbstract BA, Vendors V, Tax, Items
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
   and Items.Product_Code = BD.Product_Code
   and BD.BillID = BA.BillID      
   and BA.Status = 0       
   and BA.BillDate between @FromDate and @ToDate      
   and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) 
   and BD.TaxSuffered = Case When Convert(Decimal(18, 6), @Tax) = 0 Then BD.TaxSuffered Else (case V.locality when 1 then Tax.Percentage else Tax.CST_Percentage end) End
   and Tax.Tax_Description = Case When @TaxDesc = 'Exempt' Then Tax.Tax_Description Else @TaxDesc End
   and IsNull(BD.TaxCode, 0) = Case When @TaxCode = 0 Then IsNull(BD.TaxCode, 0) Else @TaxCode End
   and V.VendorID = BA.VendorID      
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
  from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items
  where ARA.AdjustmentID = ARD.AdjustmentID      
   and Items.Product_Code = ARD.Product_Code
   and (isnull(ARA.Status,0) & 128) = 0      
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
   and ARA.AdjustmentDate between @FromDate and @ToDate      
   and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) 
   and V.VendorID = ARA.VendorID      
   and (
			ARD.Tax = (case V.locality when 1 then (select Tax.Percentage from tax where tax_description = @TaxDesc) else (select Tax.CST_Percentage from tax where tax_description = @TaxDesc) end)
			or (ARD.Tax=0 )
		)
   and (case when ARD.Tax=0 then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = @TaxDesc) end)= @TaxDesc
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
  from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax, Items
  where ARA.AdjustmentID = ARD.AdjustmentID      
   and Items.Product_Code = ARD.Product_Code
   and (isnull(ARA.Status,0) & 128) = 0      
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
   and ARA.AdjustmentDate between @FromDate and @ToDate      
   and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
   and ARD.Tax = Case When Convert(Decimal(18, 6), @Tax) = 0 Then ARD.Tax Else (case V.locality when 1 then Tax.Percentage else Tax.CST_Percentage end) End
   and Tax.Tax_Description = Case When @TaxDesc = 'Exempt' Then Tax.Tax_Description Else @TaxDesc End
   and ARA.VendorID = V.VendorID      
   and cast(V.Locality as nvarchar) like (case @Locality       
             when 'Local' then '1'       
             when 'Outstation' then '2'       
             else '%' end) + '%'      
 )      
      
 update #VATReport set [Net Purchase (%c)] = isnull([Total Purchase (%c)],0) - isnull([Total Purchase Return (%c)],0)      
 update #VATReport set [Net Purchase Tax (%c)] = isnull([Tax on Purchase (%c)],0) - isnull([Tax on Purchase Return (%c)],0)      
      
 --Total sales amount      
 update #VATReport set [Total Sales (%c)] = (      
  select sum(IDt.Amount) - sum(case @Locality       
     when 'Local' then isnull(IDt.STPayable,0)      
     when 'Outstation' then isnull(IDT.CSTPayable,0)      
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It
  where Idt.InvoiceID = IA.InvoiceID      
   and It.Product_Code = IDt.Product_Code
   and (IA.Status & 192) = 0      
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
and IA.InvoiceType in (1, 3)      
   and IDt.SalePrice <> 0      
   and IA.InvoiceDate between @FromDate and @ToDate      
   and ((C.Locality=1 and IDt.TaxCode = (case @TaxDesc when 'Exempt' then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end))  or
		(C.Locality=2 and IDt.TaxCode2 = (case @TaxDesc when 'Exempt' then 0 else (select CST_Percentage from Tax where Tax_Description=@TaxDesc) end)))
   and @TaxDesc = (case @TaxDesc when 'Exempt' then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case C.Locality when 1 then IDt.TaxCode else IDt.TaxCode2 end)      
   and IA.CustomerID = C.CustomerID      
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
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, Items It
  where Idt.InvoiceID = IA.InvoiceID      
   and It.Product_Code = IDt.Product_Code
   and (IA.Status & 192) = 0      
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
   and IA.InvoiceType in (1, 3)      
   and IDt.SalePrice <> 0      
   and IA.InvoiceDate between @FromDate and @ToDate      
   and ((C.Locality=1 and IDt.TaxCode = Tax.Percentage)  or
		(C.Locality=2 and IDt.TaxCode2 = CST_Percentage ))
   and @TaxDesc = Tax_Description
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS ) = (Case C.Locality when 1 then IDt.TaxCode else IDt.TaxCode2 end) 
   and IA.CustomerID = C.CustomerID      
   and cast(C.Locality as nvarchar) like (case @Locality       
             when 'Local' then '1'       
             when 'Outstation' then '2'       
             else '%' end) + '%'      
 )      
      
 -- Update Total Retail Sales       
 update #VATReport set  [Total Retail Sales (%c)] = (      
 select sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0))
 from InvoiceAbstract IA
 Inner Join  InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID
 Inner Join Items It On It.Product_Code = IDt.Product_Code
 Left Outer Join  Customer C On IA.CustomerID = C.CustomerID 
 where(IA.Status & 192) = 0      
 and IA.InvoiceType in (2)      
 and IDt.SalePrice <> 0      
 and IA.InvoiceDate between @FromDate and @ToDate      
 and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode        
 and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1
 and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end)
 and @TaxDesc = (case when IDt.TaxCode=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)
 and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
 and IDt.Amount>-1
)      
       
 -- Update Tax Retail Sales       
 update #VATReport set [Tax on Retail Sales (%c)] = (      
 select sum(isnull(IDt.STPayable,0))
 from InvoiceAbstract IA
 Inner Join  InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID
 Left Outer Join Customer C On IA.CustomerID = C.CustomerID
 Inner Join Tax On IDt.TaxCode = Tax.Percentage 
 where (IA.Status & 192) = 0      
 and IA.InvoiceType in (2)      
 and IDt.SalePrice <> 0     
 and IA.InvoiceDate between @FromDate and @ToDate      
 and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode        
 and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1
 and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
 and @TaxDesc = Tax.Tax_Description 
 and IDt.Amount>-1
)
      
 --Total Sales return saleable amount      
 update #VATReport set [Sales Return Saleable (%c)] = (      
  select sum(IDt.Amount) - sum(case @Locality       
     when 'Local' then isnull(IDt.STPayable,0)      
 when 'Outstation' then isnull(IDT.CSTPayable,0)      
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It
  where Idt.InvoiceID = IA.InvoiceID      
   and It.Product_Code = IDt.Product_Code
   and (IA.Status & 192) = 0       
   and (IA.Status & 32) = 0
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
   and IA.InvoiceType = 4       
   and IDt.SalePrice <> 0      
   and IA.InvoiceDate between @FromDate and @ToDate      
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case C.Locality when 1 then IDt.TaxCode else IDt.TaxCode2 end) 
   and IA.CustomerID = C.CustomerID      
   and ((C.Locality=1 and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end)) or 
		(C.Locality=2 and IDt.TaxCode2 = (case when IDt.TaxCode2=0 then 0 else (select CST_Percentage from Tax where Tax_Description=@TaxDesc) end)))
   and @TaxDesc = (case @TaxDesc when 'Exempt' then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
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
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, Items It
  where Idt.InvoiceID = IA.InvoiceID      
   and It.Product_Code = IDt.Product_Code
   and (IA.Status & 192) = 0       
   and (IA.Status & 32) = 0
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
   and IA.InvoiceType = 4       
   and IDt.SalePrice <> 0      
   and IA.InvoiceDate between @FromDate and @ToDate      
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case C.Locality when 1 then IDt.TaxCode else IDt.TaxCode2 end)  
   and IA.CustomerID = C.CustomerID      
   and ((C.Locality=1 and IDt.TaxCode = Percentage)  or
		(C.Locality=2 and IDt.TaxCode2 = CST_Percentage))
   and @TaxDesc = Tax_Description 
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
   and cast(C.Locality as nvarchar) like (case @Locality       
             when 'Local' then '1'       
             when 'Outstation' then '2'       
             else '%' end) + '%'      
 )      
      
 --total Sales Return Damages      
 update #VATReport set [Sales Return Damages (%c)] = (      
  select sum(IDt.Amount) - sum(case @Locality       
     when 'Local' then isnull(IDt.STPayable,0)      
     when 'Outstation' then isnull(IDT.CSTPayable,0)      
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It
  where Idt.InvoiceID = IA.InvoiceID      
   and It.Product_Code = IDt.Product_Code
   and (IA.Status & 192) = 0
   and (IA.Status & 32) <> 0       
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
   and IA.InvoiceType = 4       
   and IDt.SalePrice <> 0      
   and IA.InvoiceDate between @FromDate and @ToDate      
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case C.Locality when 1 then IDt.TaxCode else IDt.TaxCode2 end)  
   and IA.CustomerID = C.CustomerID      
   and ((C.Locality=1 and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end)) or 
		(C.Locality=2 and IDt.TaxCode2 = (case when IDt.TaxCode2=0 then 0 else (select CST_Percentage from Tax where Tax_Description=@TaxDesc) end)))
   and @TaxDesc = (case @TaxDesc when 'Exempt' then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
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
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax
  where Idt.InvoiceID = IA.InvoiceID      
   and (IA.Status & 192) = 0       
   and (IA.Status & 32) <> 0
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
   and IA.InvoiceType = 4       
   and IDt.SalePrice <> 0      
   and IA.InvoiceDate between @FromDate and @ToDate      
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case C.Locality when 1 then IDt.TaxCode else IDt.TaxCode2 end)  
   and IA.CustomerID = C.CustomerID      
   and ((C.Locality=1 and IDt.TaxCode = Percentage)  or
		(C.Locality=2 and IDt.TaxCode2 = CST_Percentage))
   and Case When @TaxDesc = 'Exempt' Then Tax_Description Else @TaxDesc End = Tax_Description 
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
   and cast(C.Locality as nvarchar) like (case @Locality       
             when 'Local' then '1'       
             when 'Outstation' then '2'       
             else '%' end) + '%'      
 )      
      
 -- Update Total Retail Sales Return
 update #VATReport set [Total Retail Sales Return (%c)] = (      
 select abs(sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0)))
 from InvoiceAbstract IA
 Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID
 Left Outer Join Customer C On IA.CustomerID = C.CustomerID 
 Inner Join Items It On It.Product_Code = IDt.Product_Code
 where (IA.Status & 192) = 0      
 and IA.InvoiceType in (5,6)      
 and IDt.SalePrice <> 0      
 and IA.InvoiceDate between @FromDate and @ToDate  
 and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS 
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode        
 and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1
 and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end)
 and @TaxDesc = (case when IDt.TaxCode=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)
 and IsNull(IDt.TaxID, 0) = @TaxCode
 --and IDt.Amount<0
)      

 -- Update Tax Retail Sales Return
 update #VATReport set [Tax on Retail Sales Return (%c)] = (      
 select Abs(sum(isnull(IDt.STPayable,0)))
 from InvoiceAbstract IA
 Inner Join InvoiceDetail IDt On  Idt.InvoiceID = IA.InvoiceID   
 Left Outer Join Customer C On IA.CustomerID = C.CustomerID, Tax
 where(IA.Status & 192) = 0  
 and IA.InvoiceType in (5,6)      
 and IDt.SalePrice <> 0      
 and IA.InvoiceDate between @FromDate and @ToDate      
 and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS       
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode        
 and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1
 and IDt.TaxCode = Percentage
 and Case When @TaxDesc = 'Exempt' Then Tax_Description Else @TaxDesc End = Tax_Description
 and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End
 --and IDt.Amount<0
)

----------------------------------------------------------------------------
--select * from #VATReport
--------------------------------------------------------------------------      

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
      
----------------------------------------------------------------------------
--select * from #VATReport
--------------------------------------------------------------------------      
      
select [ICode], [Item Code], [Item Name], [Tax %], [Total Purchase (%c)] ,      
[Tax on Purchase (%c)], [Total Purchase Return (%c)], [Tax on Purchase Return (%c)],      
[Net Purchase (%c)], [Net Purchase Tax (%c)], [Total Sales (%c)], [Tax on Sales (%c)], 
[Total Retail Sales (%c)], [Tax on Retail Sales (%c)], [Sales Return Saleable (%c)], 
[Tax on Sales Return Saleable (%c)], [Sales Return Damages (%c)], [Tax on Sales Return Damages (%c)], 
[Total Retail Sales Return (%c)], [Tax on Retail Sales Return (%c)], 
[Net Sales Return (%c)], [Net Tax on Sales Return (%c)], [Net Sales (%c)],      
[Net Tax on Sales (%c)], [Net VAT Payable (%c)] from #VATReport      
Where Convert(Decimal(18, 6), [Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = Convert(Decimal(18, 6), @Tax)

drop table #VATReport      
Drop Table  #tmpProd      
      
 end      
      
    



