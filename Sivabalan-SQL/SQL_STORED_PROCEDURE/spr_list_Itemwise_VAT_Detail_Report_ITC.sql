CREATE procedure [dbo].[spr_list_Itemwise_VAT_Detail_Report_ITC]  
(  
 @Tax nvarchar(550),        
 @FromDate datetime,         
 @ToDate DateTime,        
 @TaxUnusedParameter nvarchar(10),        
 @Locality nvarchar(15),        
 @ItemCode nvarchar(510),        
 @ItemName nvarchar(510),        
 @TaxSplitUp nVarChar(5), 
 @TaxType nVarchar(20) 
)         
as        
begin        

-- Tax Componenet Handled  
Declare @SqlStat nVarchar(4000)  
Declare @TaxTypeID Int   

Select @TaxTypeID = TaxID From tbl_mERP_Taxtype 
Where TaxType = @TaxType 
 
 Declare @Delimeter as Char(1)        
 Set @Delimeter=Char(15)        
  
 declare @TaxCode int  
 declare @TaxDesc nvarchar(510)  
 declare @Pos as int  
 declare @Pos1 as int  
 set @Pos = charindex (char(15), @Tax, 1)  
 set @TaxCode = substring(@Tax, 1, @Pos-1)  
 set @Tax = substring(@Tax, @Pos + 1, 1000)  
--  select @tax --*  
 set @Pos = charindex (char(15), @Tax, 1)  
--  select @tax --*  
 set @TaxDesc = substring(@Tax, @Pos + 1, 510)  
 set @Tax = substring(@Tax, 1, @Pos - 1)  
--  select @tax --*  
--   
--  select @TaxCode, @TaxDesc, @Tax --*  
--    
--  select @pos, @TaxCode , @Pos1 , @Tax , @TaxDesc --*  

--declare @temp datetime 
Set DATEFormat DMY
--set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
--if(@FROMDATE > @temp )
--begin
--select 0,'This report cannot be generated for GST  period' as Reason
--goto GSTOut
-- end               
                 
--if(@TODATE > @temp )
--begin
--set @TODATE  = @temp 
----goto GSTOut
--end                 
  
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
  [Tax Type] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,        

  [Total Purchase (%c)]  Decimal(18,6),        
  [Tax on Purchase (%c)]  Decimal(18,6),        

  [VAT Total Purchase (%c)]  Decimal(18,6),        
  [VAT Tax on Purchase (%c)]  Decimal(18,6),  
  [CST Total Purchase (%c)]  Decimal(18,6),        
  [CST Tax on Purchase (%c)]  Decimal(18,6),        
  
  [Total Purchase Return (%c)]  Decimal(18,6),        
  [Tax on Purchase Return (%c)]  Decimal(18,6),        
  
  [VAT Total Purchase Return (%c)]  Decimal(18,6),        
  [VAT Tax on Purchase Return (%c)]  Decimal(18,6),        
  [CST Total Purchase Return (%c)]  Decimal(18,6),        
  [CST Tax on Purchase Return (%c)]  Decimal(18,6),        
  
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
    
-- get all the Sales for the given taxtype filter
select InvoiceId, [taxtype]
Into #InvoiceTaxType from (
    select InvoiceId, ( Case when cstpayable > 0 then 'CST' Else 'LST' End) [taxtype] 
    from (
        select Ia.InvoiceId, max(Id.stpayable) stpayable, max(Id.cstpayable) cstpayable
        from Invoiceabstract Ia Join InvoiceDetail Id on Ia.InvoiceId = Id.InvoiceId
		where Ia.InvoiceDate >= @FromDate and Ia.InvoiceDate <= @ToDate and status & 128 = 0
        group by Ia.InvoiceId ) tmp 
    )Idtmp 
	where taxtype = @TaxType 

 --take distinct (products and tax percentages) from Bills, Adj Returns and Invoices        
 insert into #VATReport (ICode, [Item Code], [Item Name], [Tax %], [Tax Type])   
  select Distinct It.Product_Code, It.Product_Code, It.ProductName, BD.TaxSuffered, txzType.TaxType   
  from Items It, BillAbstract BA, BillDetail BD, Vendors V, tbl_merp_TaxType TxzType   
  where   
--   It.ProductName like @ItemName and   
   BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
   and BA.BillID = BD.BillID        
   and BD.Product_Code = It.Product_Code        
   and BA.BillDate between @FromDate and @ToDate        
   and BA.Status = 0        
   and TxzType.TaxID = IsNull(BA.TaxType, 1)
   and TxzType.TaxID = @TaxTypeID 
   and BD.TaxSuffered = convert(decimal(18,6),@Tax)  
   and (  
   Convert(Decimal(18, 6), @Tax) = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = @TaxDesc)     
   or (convert(decimal(18,6),@Tax) = convert(decimal(18,6),0) and @TaxDesc = 'Exempt' and BD.TaxSuffered = convert(decimal(18,6),0))  
  )  
   and (  
  IsNull(BD.TaxCode, 0) = (Case @TaxCode When 0 Then IsNull(BD.TaxCode, 0)   
     Else  @TaxCode End)  
 )  
   and V.VendorID = BA.VendorID        
   and (case when BD.TaxSuffered=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end)= @TaxDesc  
--   and V.Locality like (        
--     case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )        
  group by BD.TaxCode, It.Product_Code, It.ProductName, BD.TaxSuffered, txzType.TaxType        
  having SUM(BD.Amount + BD.TaxAmount)>0        
 union        
  select Distinct It.Product_Code, It.Product_Code, It.ProductName, ARD.Tax, TxzType.TaxType
  from Items It, AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V  , Batch_Products bp, tbl_mERP_TaxType TxzType
  where   
--It.ProductName like @ItemName and   
--   It.Product_Code like @ItemCode        
   ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
   and ARA.AdjustmentID = ARD.AdjustmentID        
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = It.Product_Code        
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) = @TaxTypeID 
   and TxzType.TaxID = @TaxTypeID 
   and (  
   (ARD.Tax = 0 ) or  
   ARD.Tax = (case when ( IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) then (Select Tax.Percentage from tax where Tax_Description = @TaxDesc) else (Select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)  
  )  
   and ARD.Tax = Case When Convert(Decimal(18, 6), @Tax) = 0 Then ARD.Tax Else convert(decimal(18,6),@Tax) End  
   and ARA.VendorID = V.VendorID        
   and (case when ARD.Tax=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
--   and cast(V.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
  group by It.Product_Code, It.ProductName, ARD.Tax, TxzType.TaxType
  having sum(ARD.Total_Value)>0        
 union        
  select Distinct It.Product_Code, It.Product_Code, It.ProductName, IDt.TaxCode, TxzType.TaxType
  from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
  where         
--   It.ProductName like @ItemName and   
   IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
   and IA.InvoiceID = IDt.InvoiceID        
   and IDt.Product_Code = It.Product_Code        
--   and IA.InvoiceDate between @FromDate and @ToDate        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and #I.InvoiceId = Ia.InvoiceId
   and TxzType.TaxID = @TaxTypeID 
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
--   and C.Locality = 1  
   and #I.[taxtype] = 'LST'
   and (case when IDt.TaxCode=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
   and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = @TaxDesc) end)  
--   and (case @Locality when '%' then 1 when 'Local' then 1 else 0 end) = 1  
  group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, IDt.TaxCode, TxzType.TaxType  
  having sum(IDt.Amount)>0        
 union        
  select Distinct It.Product_Code, It.Product_Code, It.ProductName, IDt.TaxCode2  , TxzType.TaxType
  from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, tbl_mERP_TaxType TxzType, #InvoiceTaxType #I
  where         
--   It.ProductName like @ItemName and   
   IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
   and IA.InvoiceID = IDt.InvoiceID        
   and IDt.Product_Code = It.Product_Code        
--   and IA.InvoiceDate between @FromDate and @ToDate        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and #I.InvoiceId = Ia.InvoiceId
   and TxzType.TaxID = @TaxTypeID 
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
--   and C.Locality = 2  
   and #I.[taxtype] = 'CST'
   and (case when IDt.TaxCode2=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
   and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode2=0 then 0 else (select Tax.CST_Percentage from tax where Tax_Description = @TaxDesc) end)  
--   and (case @Locality when '%' then 1 when 'Outstation' then 1 else 0 end) = 1  
  group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, IDt.TaxCode2, TxzType.TaxType  
  having sum(IDt.Amount)>0        
        
Union        
select Distinct It.Product_Code, It.Product_Code, It.ProductName, IDt.TaxCode, TxzType.TaxType
from Items It
Inner Join InvoiceDetail IDt On IDt.Product_Code = It.Product_Code        
Inner Join InvoiceAbstract IA On  IA.InvoiceID = IDt.InvoiceID        
Left Outer Join Customer C On C.CustomerID = IA.CustomerID         
Inner Join #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
Inner Join  tbl_mERP_TaxType TxzType On TxzType.TaxID = @TaxTypeID 
where         
-- It.ProductName like @ItemName and   
 IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
-- and IA.InvoiceDate between @FromDate and @ToDate        
-- and IsNull(C.Locality, 1) = @TaxTypeID
 and (IA.Status & 192) = 0        
 and IA.InvoiceType in (2)        
 and IDt.TaxCode = Case When Convert(Decimal(18, 6), @Tax) = 0 Then IDt.TaxCode Else convert(decimal(18,6),@Tax) End  
 and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
-- and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1  
 and (case when IDt.TaxCode=0 then 'Exempt' else (Select Tax.Tax_Description from tax where Tax_Description = @TaxDesc) end) = @TaxDesc  
 and convert(decimal(18,6),@Tax) = (case when IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = @TaxDesc) end)  
group by IDt.TaxID, It.Product_Code, It.ProductName, IDt.TaxCode, TxzType.TaxType  
        
        
 order by It.ProductName, BD.TaxSuffered        
--------------------------------------------------------------------------  
--select * from #VATReport  
--------------------------------------------------------------------------        
 Create table #VATReportDet  
 (        
  [ICode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Item Code] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Item Name] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,        
  [Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,  
  [Tax Type] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS  
 )  
  
If @TaxSplitup <> 'Yes'  
Begin  
Alter Table #VATReportDet Add [Total Purchase (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Purchase (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Total Purchase Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Purchase Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Net Purchase (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Net Purchase Tax (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Total Sales (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Sales (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Total Retail Sales (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Retail Sales (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Sales Return Saleable (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Sales Return Saleable (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Sales Return Damages (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Sales Return Damages (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Total Retail Sales Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Retail Sales Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Net Sales Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Net Tax on Sales Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Net Sales (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Net Tax on Sales (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Net VAT Payable (%c)] Decimal(18,6)        
End  
--------------------------------------------------------------------------        
-- Tax Component Handling  
--------------------------------------------------------------------------        
If @TaxSplitup = 'Yes'  
 Begin  
  
Create Table #TaxComponents   
(Trans int,TaxID int,Tax Decimal(18,6),CompID int,LST int,  
CompTax Decimal(18,6),CompCalTax Decimal(18,6),CompPos int,CompDesc nVarChar(1000))  
  
Insert Into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Purchase LST       
Select 1,IsNull(Tax.Tax_Code, 0), IsNull(BD.TaxSuffered,0) , TC.TaxComponent_Code , TC.LST_Flag , TC.Tax_Percentage , TC.Sp_Percentage  
  from BillAbstract BA, BillDetail BD, Vendors V, Tax , TaxComponents TC  
  where  
   BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
   and BA.BillID = BD.BillID        
   and BA.BillDate between @FromDate and @ToDate        
   and IsNull(BA.TaxType, 1) = @TaxTypeID 
   and BA.Status = 0        
   and BD.TaxSuffered = convert(decimal(18,6),@Tax)  
   and IsNull(BD.TaxCode, 0) = @TaxCode  
   And Tax.Tax_Code = @TaxCode  
   and BD.TaxCode = Tax.Tax_Code  
   And Tax.Tax_Code = TC.Tax_Code 
	-- From now on, A item can be sold to a local vendor with CST tax type and vice versa. So we are changing the filter  
   And TC.LST_Flag = ( Case when @TaxTypeID = 2 then 0 Else 1 end )
--   And V.Locality = 1  
   and ( IsNull(BA.TaxType, 1) = 1 or IsNull(BA.TaxType, 1) = 3 ) 
   and V.VendorID = BA.VendorID  
--   and V.Locality like (        
--     case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )        
  
group by Tax.Tax_Code, BD.TaxSuffered,TC.TaxComponent_Code , TC.LST_Flag , TC.Tax_Percentage ,TC.Sp_Percentage  
having SUM(BD.Amount + BD.TaxAmount)>0  
Order By Tax.Tax_Code, BD.TaxSuffered,TC.TaxComponent_Code , TC.LST_Flag Desc , TC.Tax_Percentage,TC.Sp_Percentage  
  
Insert Into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Purchase CST  
Select 1,IsNull(Tax.Tax_Code, 0), IsNull(BD.TaxSuffered,0) , TC.TaxComponent_Code , TC.LST_Flag , TC.Tax_Percentage , TC.Sp_Percentage  
  from BillAbstract BA, BillDetail BD, Vendors V, Tax , TaxComponents TC  
  where  
   BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
   and BA.BillID = BD.BillID        
   and BA.BillDate between @FromDate and @ToDate        
   and IsNull(BA.TaxType, 1) = @TaxTypeID 
   and BA.Status = 0        
   and BD.TaxSuffered = convert(decimal(18,6),@Tax)  
   and IsNull(BD.TaxCode, 0) = @TaxCode  
   And Tax.Tax_Code = @TaxCode  
   and BD.TaxCode = Tax.Tax_Code  
   And Tax.Tax_Code = TC.Tax_Code  
  -- From now on, A item can be sold to a local vendor with CST tax type and vice versa. So we are changing the filter 
   And TC.LST_Flag = ( Case when @TaxTypeID = 2 then 0 Else 1 end )
   --And V.Locality = 2  
   and IsNull(BA.TaxType, 1) = 2
   and V.VendorID = BA.VendorID  
--   and V.Locality like (        
--     case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )        
  
group by Tax.Tax_Code, BD.TaxSuffered,TC.TaxComponent_Code , TC.LST_Flag , TC.Tax_Percentage ,TC.Sp_Percentage  
having SUM(BD.Amount + BD.TaxAmount)>0  
Order By Tax.Tax_Code, BD.TaxSuffered,TC.TaxComponent_Code , TC.LST_Flag Desc , TC.Tax_Percentage,TC.Sp_Percentage  
  
Insert Into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Purchase Return LST  
Select 2,IsNull(Tax.Tax_Code, 0), IsNull(ARD.Tax,0) , TC.TaxComponent_Code , TC.LST_Flag ,TC.Tax_Percentage ,  TC.Sp_Percentage  
from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax , TaxComponents TC , Batch_products BP  
  where   
   ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
   and ARA.AdjustmentID = ARD.AdjustmentID        
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.Tax = Case When Convert(Decimal(18, 6), @Tax) = 0 Then ARD.Tax Else convert(decimal(18,6),@Tax) End  
   and ARA.VendorID = V.VendorID        
   And ARD.BatchCode = BP.Batch_Code   
   And IsNull(bp.TaxType, 1) =  @TaxTypeID 
   And BP.GRNTaxID = Tax.Tax_Code  
   And Tax.Tax_Code = @TaxCode  
   And Tax.Tax_Code = TC.Tax_Code    
-- From now on, A item can be sold to a local vendor with CST tax type and vice versa. So we are changing the filter        
--   And V.Locality = 1  
   and ( IsNull(Bp.TaxType, 1) = 1 or IsNull(Bp.TaxType, 1) = 3 ) 
   And TC.LST_Flag = ( Case when @TaxTypeID = 2 then 0 Else 1 end ) 
--   and cast(V.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
  group by Tax.Tax_Code, ARD.Tax , TC.TaxComponent_Code , TC.LST_Flag ,TC.Tax_Percentage, TC.Sp_Percentage  
  having sum(ARD.Total_Value)>0        
  Order By Tax.Tax_Code, ARD.Tax , TC.TaxComponent_Code , TC.LST_Flag Desc,TC.Tax_Percentage, TC.Sp_Percentage  
  
Insert Into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Purchase Return CST  
Select 2,IsNull(Tax.Tax_Code, 0), IsNull(ARD.Tax,0) , TC.TaxComponent_Code , TC.LST_Flag ,TC.Tax_Percentage ,  TC.Sp_Percentage  
from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax , TaxComponents TC , Batch_products BP  
  where   
   ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)               
   and ARA.AdjustmentID = ARD.AdjustmentID        
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.Tax = Case When Convert(Decimal(18, 6), @Tax) = 0 Then ARD.Tax Else convert(decimal(18,6),@Tax) End  
   and ARA.VendorID = V.VendorID        
   And ARD.BatchCode = BP.Batch_Code   
   And IsNull(bp.TaxType, 1) =  @TaxTypeID 
   And BP.GRNTaxID = Tax.Tax_Code  
   And Tax.Tax_Code = @TaxCode  
   And Tax.Tax_Code = TC.Tax_Code    
  -- From now on, A item can be sold to a local vendor with CST tax type and vice versa. So we are changing the filter        
   --And V.Locality = 2  
   and IsNull(Bp.TaxType, 1) = 2 
   And TC.LST_Flag = ( Case when @TaxTypeID = 2 then 0 Else 1 end )
   and cast(V.Locality as nvarchar) like (case @Locality         
             when 'Local' then '1'         
             when 'Outstation' then '2'         
             else '%' end) + '%'        
  group by Tax.Tax_Code, ARD.Tax , TC.TaxComponent_Code , TC.LST_Flag ,TC.Tax_Percentage, TC.Sp_Percentage  
  having sum(ARD.Total_Value)>0        
  Order By Tax.Tax_Code, ARD.Tax , TC.TaxComponent_Code , TC.LST_Flag Desc,TC.Tax_Percentage, TC.Sp_Percentage  
  
--------------------------------------------------------------------------  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Invoice Tax Component - LST  
Select 3,IsNull(Tax.Tax_Code, 0) , IDt.TaxCode , ITC.Tax_Component_Code, 1, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax , InvoiceTaxComponents ITC  , #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
And IA.InvoiceType in (1,3)  
and IsNull(IA.Status,0) & 192 = 0  
--and IA.InvoiceDate between @FromDate and @ToDate            
--and idt.Batch_Code = bp.Batch_Code 
--and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId
and IDt.TaxCode = @Tax  
And IDT.TaxID = @TaxCode  
And IDt.TaxCode <> 0  
--and C.Locality = 1         
--and (case @Locality when '%' then 1 when 'Local' then 1 else 0 end) = 1            
and #I.[taxtype] = 'LST'
And IA.InvoiceID = IDt.InvoiceID  
And ITC.InvoiceID = IA.InvoiceID  
and C.CustomerID = IA.CustomerID            
and IDt.TaxID = Tax.Tax_Code  
And ITC.Tax_Code = IDT.TaxID  
And ITC.Product_Code = IDT.Product_Code  
group by Tax.Tax_Code,IDt.TaxCode, ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Sales Return Saleable Tax Component - LST  
Select 5,IsNull(Tax.Tax_Code, 0) , IDt.TaxCode , ITC.Tax_Component_Code, 1, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax , InvoiceTaxComponents ITC  , #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IsNull(IA.Status,0) & 32 = 0  
And IA.InvoiceType in (4)  
--and IA.InvoiceDate between @FromDate and @ToDate            
--and idt.Batch_Code = bp.Batch_Code 
--and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId
and IDt.TaxCode = @Tax  
And IDT.TaxID = @TaxCode  
And IDt.TaxCode <> 0  
--and C.Locality = 1         
--and (case @Locality when '%' then 1 when 'Local' then 1 else 0 end) = 1   
and #I.[taxtype] = 'LST'
And IA.InvoiceID = IDt.InvoiceID  
And ITC.InvoiceID = IA.InvoiceID  
and C.CustomerID = IA.CustomerID            
and IDt.TaxID = Tax.Tax_Code  
And ITC.Tax_Code = IDT.TaxID  
And ITC.Product_Code = IDT.Product_Code  
group by Tax.Tax_Code,IDt.TaxCode, ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Sales Return Damage Tax Component - LST  
Select 6,IsNull(Tax.Tax_Code, 0) , IDt.TaxCode , ITC.Tax_Component_Code, 1, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax , InvoiceTaxComponents ITC  , #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IsNull(IA.Status,0) & 32 <> 0  
And IA.InvoiceType in (4)  
--and IA.InvoiceDate between @FromDate and @ToDate            
--and idt.Batch_Code = bp.Batch_Code 
--and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId
and IDt.TaxCode = @Tax  
And IDT.TaxID = @TaxCode  
And IDt.TaxCode <> 0  
--and C.Locality = 1         
--and (case @Locality when '%' then 1 when 'Local' then 1 else 0 end) = 1            
and #I.[taxtype] = 'LST'
And IA.InvoiceID = IDt.InvoiceID  
And ITC.InvoiceID = IA.InvoiceID  
and C.CustomerID = IA.CustomerID            
and IDt.TaxID = Tax.Tax_Code  
And ITC.Tax_Code = IDT.TaxID  
And ITC.Product_Code = IDT.Product_Code  
group by Tax.Tax_Code,IDt.TaxCode, ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Invoice Tax Component - CST  
Select 3,IsNull(Tax.Tax_Code, 0), IDt.TaxCode2, ITC.Tax_Component_Code, 0, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, InvoiceTaxComponents ITC  , #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IA.InvoiceType in (1,3)  
--and IA.InvoiceDate between @FromDate and @ToDate            
--and idt.Batch_Code = bp.Batch_Code 
--and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId
and IDt.TaxCode2 = @Tax  
And IDT.TaxID = @TaxCode  
And IDt.TaxCode2 <> 0  
--and C.Locality = 2    
--and (case @Locality when '%' then 1 when 'Outstation' then 1 else 0 end) = 1   
and #I.[taxtype] = 'CST'
and IA.InvoiceID = IDt.InvoiceID            
And ITC.InvoiceID = IA.InvoiceID  
and C.CustomerID = IA.CustomerID    
and IDt.TaxID = Tax.Tax_Code  
And ITC.Tax_Code = IDT.TaxID  
And ITC.Product_Code = IDT.Product_Code  
group by Tax.Tax_Code,  IDt.TaxCode2 ,  ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Sales Return Saleable Tax Component - CST  
Select 5,IsNull(Tax.Tax_Code, 0), IDt.TaxCode2, ITC.Tax_Component_Code, 0, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, InvoiceTaxComponents ITC  , #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IsNull(IA.Status,0) & 32 = 0  
And IA.InvoiceType in (4)  
--and IA.InvoiceDate between @FromDate and @ToDate            
--and idt.Batch_Code = bp.Batch_Code 
--and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId
and IDt.TaxCode2 = @Tax  
And IDT.TaxID = @TaxCode  
And IDt.TaxCode2 <> 0  
--and C.Locality = 2    
--and (case @Locality when '%' then 1 when 'Outstation' then 1 else 0 end) = 1                    
and #I.[taxtype] = 'CST'
and IA.InvoiceID = IDt.InvoiceID            
And ITC.InvoiceID = IA.InvoiceID  
and C.CustomerID = IA.CustomerID    
and IDt.TaxID = Tax.Tax_Code  
And ITC.Tax_Code = IDT.TaxID  
And ITC.Product_Code = IDT.Product_Code  
group by Tax.Tax_Code,  IDt.TaxCode2 ,  ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Sales Return Damage Tax Component - CST  
Select 6,IsNull(Tax.Tax_Code, 0), IDt.TaxCode2, ITC.Tax_Component_Code, 0, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, InvoiceTaxComponents ITC  , #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IsNull(IA.Status,0) & 32 <> 0  
And IA.InvoiceType in (4)  
and IDt.TaxCode2 = @Tax  
And IDT.TaxID = @TaxCode  
--and IA.InvoiceDate between @FromDate and @ToDate            
--and idt.Batch_Code = bp.Batch_Code 
--and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId
And IDt.TaxCode2 <> 0  
--and C.Locality = 2    
--and (case @Locality when '%' then 1 when 'Outstation' then 1 else 0 end) = 1                    
and #I.[taxtype] = 'CST'
and IA.InvoiceID = IDt.InvoiceID            
And ITC.InvoiceID = IA.InvoiceID  
and C.CustomerID = IA.CustomerID    
and IDt.TaxID = Tax.Tax_Code  
And ITC.Tax_Code = IDT.TaxID  
And ITC.Product_Code = IDT.Product_Code  
group by Tax.Tax_Code,  IDt.TaxCode2 ,  ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Retail Invoice Tax Component  
Select 4, IsNull(Tax.Tax_Code, 0), IDt.TaxCode , ITC.Tax_Component_Code, 1, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID            
Inner Join Tax On IDt.TaxID = Tax.Tax_Code  
Left Outer Join Customer C On C.CustomerID = Cast(IA.CustomerID  as int)          
Inner Join InvoiceTaxComponents ITC On ITC.InvoiceID = IA.InvoiceID  And ITC.Tax_Code = IDT.TaxID  
Inner Join #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and (Isnull(IA.Status, 0) & 192) = 0            
and IA.InvoiceType in (2)            
--and IA.InvoiceDate between @FromDate and @ToDate            
--and idt.Batch_Code = bp.Batch_Code 
--and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and IDt.TaxCode = @Tax  
And IDT.TaxID = @TaxCode  
And IDt.TaxCode <> 0   
--and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1            
and #I.[taxtype] = 'LST'
group by Tax.Tax_Code, IDt.TaxCode, ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Retail Sales Return Tax Component  
Select 7, IsNull(Tax.Tax_Code, 0), IDt.TaxCode , ITC.Tax_Component_Code, 1, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID            
Left Outer Join Customer C On C.CustomerID =Cast(IA.CustomerID  as int)          
Inner Join Tax On IDt.TaxID = Tax.Tax_Code  
Inner Join InvoiceTaxComponents ITC  On ITC.InvoiceID = IA.InvoiceID  And ITC.Tax_Code = IDT.TaxID  
Inner Join #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and (Isnull(IA.Status, 0) & 192) = 0            
and IA.InvoiceType in (5,6)            
--and IA.InvoiceDate between @FromDate and @ToDate            
--and idt.Batch_Code = bp.Batch_Code 
--and IsNull(bp.TaxType, 1) =  @TaxTypeID 
and IDt.TaxCode = @Tax  
And IDT.TaxID = @TaxCode  
And IDt.TaxCode <> 0   
--and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1            
and #I.[taxtype] = 'LST'
group by Tax.Tax_Code, IDt.TaxCode, ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
--------------------------------------------------------------------------  
  
Declare @Trans Int  
Declare @TaxID Int  
Declare @TaxSuffered Decimal(18,6)  
Declare @CompID Int  
--Declare @Pos Int  
Declare @PTrans Int  
Declare @PTaxID Int  
Declare @ColName nVarChar(1000)
Declare @LST Int  
  
Declare TaxComps Cursor For   
Select Trans,TaxID,CompID from #TaxComponents  
Where LST = 1  
Order By Trans,TaxID  
  
Open TaxComps   
Fetch From TaxComps Into @Trans,@TaxID,@CompID  
  
Set @Pos = 1  
  
While @@Fetch_Status = 0  
Begin  
Set @PTrans = @Trans  
Set @PTaxID = @TaxID  
Update #TaxComponents Set CompPos = @Pos  
Where Trans = @Trans And TaxID = @TaxID And CompID = @CompID  
Fetch Next From TaxComps Into @Trans,@TaxID,@CompID  
Set @Pos = @Pos + 1  
If @PTrans <> @Trans  
 Set @Pos = 1  
If @PTaxID <> @TaxID  
 Set @Pos = 1  
End  
  
Close TaxComps  
DeAllocate TaxComps  
  
Declare TaxComps Cursor For   
Select Trans,TaxID,CompID from #TaxComponents  
Where LST = 0  
Order By Trans,TaxID  
  
Open TaxComps   
Fetch From TaxComps Into @Trans,@TaxID,@CompID  
  
Set @Pos = 1  
  
While @@Fetch_Status = 0  
Begin  
Set @PTrans = @Trans  
Set @PTaxID = @TaxID  
Update #TaxComponents Set CompPos = @Pos  
Where Trans = @Trans And TaxID = @TaxID And CompID = @CompID  
Fetch Next From TaxComps Into @Trans,@TaxID,@CompID  
Set @Pos = @Pos + 1  
If @PTrans <> @Trans  
 Set @Pos = 1  
If @PTaxID <> @TaxID  
 Set @Pos = 1  
End  
  
Close TaxComps  
DeAllocate TaxComps  
  
----------------------------------------------------------------------------------------  
-- We Assume That The "Trans" coulmn have data (1 to 7) are mentioned that the follows  
-- 1 - For Purchase  
-- 2 - For Purchase Return  
-- 3 - For Sales  
-- 4 - For Retail sales  
-- 5 - For Sales Return Salable  
-- 6 - For Sales Return Damage  
-- 7 - For Retail Sales Return  
----------------------------------------------------------------------------------------  

Update #TaxComponents   

--Set CompDesc = '['+ dbo.mERP_fn_GetTaxColFormat(TaxID, CompID) + ' Tax %' +   
--(Case Trans When 1 Then '_Purchase]' When 2 Then '_PR]'   
--When 3 Then '_Sales]' When 5 Then '_SRS]' When 6 Then '_SRD]' When 4 Then '_Retail Sales]'  
--When 7 Then '_Retail SR]' Else ']' End)   
--+ Char(15)   
--+ '['+ dbo.mERP_fn_GetTaxColFormat(TaxID, CompID) + ' Tax Amount(%c)'  
--+(Case Trans When 1 Then '_Purchase]' When 2 Then '_PR]'   
--When 3 Then '_Sales]' When 5 Then '_SRS]' When 6 Then '_SRD]' When 4 Then '_Retail Sales]'  
--When 7 Then '_Retail SR]'Else ']' End)  


Set CompDesc = '['+
(Case Trans When 1 Then 'Purchase ' When 2 Then 'PR '   
When 3 Then 'Sales ' When 5 Then 'SRS ' When 6 Then 'SRD ' When 4 Then 'Retail Sales '  
When 7 Then 'Retail SR ' Else '' End)   
+'('+' '+ dbo.mERP_fn_GetTaxColFormat(TaxID, CompID) +')' + '_Tax%' + ']'  
+ Char(15)   
+ '['
+(Case Trans When 1 Then 'Purchase ' When 2 Then 'PR '   
When 3 Then 'Sales ' When 5 Then 'SRS ' When 6 Then 'SRD ' When 4 Then 'Retail '  
When 7 Then 'Retail SR 'Else '' End)  
+'(' + dbo.mERP_fn_GetTaxColFormat(TaxID, CompID) + ')' + '_Tax'+ ']'  


--------------------------------------------------------------------------  
Set @Trans = 1  
while @Trans <=7  
Begin  
  
if @Trans = 1  
Begin  
Alter Table #VATReportDet Add [Total Purchase (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Purchase (%c)]  Decimal(18,6)  
 if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 1)  
 Begin  
Alter Table #VATReportDet Add [VAT Total Purchase (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [VAT Tax on Purchase (%c)]  Decimal(18,6)  
 End  
End  
Else If @Trans = 2  
Begin  
Alter Table #VATReportDet Add [Total Purchase Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [Tax on Purchase Return (%c)]  Decimal(18,6)  
 if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 1)  
 Begin  
Alter Table #VATReportDet Add [VAT Total Purchase Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [VAT Tax on Purchase Return (%c)]  Decimal(18,6)  
 End  
End  
  
Declare TaxCompColl Cursor For   
Select Distinct CompDesc From #TaxComponents   
Where Trans = @Trans And LST = 1  
  
Open TaxCompColl   
Fetch From TaxCompColl InTo @ColName  
While @@Fetch_Status = 0  
Begin  
 Set @SqlStat = 'Alter Table #VATReportDet Add ' + Left(@ColName,CharIndex(Char(15),@ColName)-1) + ' Decimal(18,6)'  
 Exec sp_ExecuteSQL @SqlStat  
 Set @SqlStat = 'Alter Table #VATReportDet Add ' + Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName))) + ' Decimal(18,6)'  
 Exec sp_ExecuteSQL @SqlStat  
Fetch Next From TaxCompColl InTo @ColName  
End  
  
Close TaxCompColl  
DeAllocate TaxCompColl  
  
if @Trans = 1  
Begin  
 if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 0)  
 Begin  
Alter Table #VATReportDet Add [CST Total Purchase (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [CST Tax on Purchase (%c)]  Decimal(18,6)  
 End  
End  
Else if @Trans = 2  
Begin  
 if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 0)  
 Begin  
Alter Table #VATReportDet Add [CST Total Purchase Return (%c)]  Decimal(18,6)  
Alter Table #VATReportDet Add [CST Tax on Purchase Return (%c)]  Decimal(18,6)  
 End  
End  
  
Declare TaxCompColl Cursor For   
Select Distinct CompDesc From #TaxComponents   
Where Trans = @Trans And LST = 0  
  
Open TaxCompColl   
Fetch From TaxCompColl InTo @ColName  
While @@Fetch_Status = 0  
Begin  
 Set @SqlStat = 'Alter Table #VATReportDet Add ' + Left(@ColName,CharIndex(Char(15),@ColName)-1) + ' Decimal(18,6)'  
 Exec sp_ExecuteSQL @SqlStat  
 Set @SqlStat = 'Alter Table #VATReportDet Add ' + Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName))) + ' Decimal(18,6)'  
 Exec sp_ExecuteSQL @SqlStat  
Fetch Next From TaxCompColl InTo @ColName  
End  
  
Close TaxCompColl  
DeAllocate TaxCompColl  
  
Set @Trans = @Trans + 1  
  
If @Trans = 3  
Begin  
 Alter Table #VATReportDet Add [Net Purchase (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Net Purchase Tax (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Total Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Tax on Sales (%c)]  Decimal(18,6)  
End  
Else If @Trans = 4  
Begin  
 Alter Table #VATReportDet Add [Total Retail Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Tax on Retail Sales (%c)]  Decimal(18,6)  
End  
Else If @Trans = 5  
Begin  
 Alter Table #VATReportDet Add [Sales Return Saleable (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Tax on Sales Return Saleable (%c)]  Decimal(18,6)  
End  
Else If @Trans = 6  
Begin  
 Alter Table #VATReportDet Add [Sales Return Damages (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Tax on Sales Return Damages (%c)]  Decimal(18,6)  
End  
Else If @Trans = 7  
Begin  
 Alter Table #VATReportDet Add [Total Retail Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Tax on Retail Sales Return (%c)]  Decimal(18,6)  
End  
Else If @Trans = 8  
Begin  
 Alter Table #VATReportDet Add [Net Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Net Tax on Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Net Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Net Tax on Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportDet Add [Net VAT Payable (%c)] Decimal(18,6)        
End  
  
End  
--------------------------------------------------------------------------        
-- SElect * from #TaxComponents   
--------------------------------------------------------------------------        
 End  
--------------------------------------------------------------------------        
 --Total Purchase amount        
 update #VATReport set [Total Purchase (%c)]  =  (        
  select SUM(BD.Amount)  
  from BillDetail BD, BillAbstract BA, Vendors V, Items, tbl_merp_TaxType TxzType  
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS        
   and Items.Product_Code = BD.Product_Code  
   and BD.BillID = BA.BillID        
   and BA.Status = 0         
   and TxzType.TaxID = IsNull(BA.taxType,1)
   and TxzType.TaxID= @TaxTypeID 
   and TxzType.TaxType = [Tax Type]
   and BA.BillDate between @FromDate and @ToDate        
   and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
   and (   
   BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = @TaxDesc)
   or (BD.TaxSuffered = 0 )  
  )  
   and IsNull(BD.TaxCode, 0) = Case When @TaxCode  = 0 Then IsNull(BD.TaxCode, 0) Else @TaxCode End  
   and (case when BD.TaxSuffered=0 then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = @TaxDesc) end) = @TaxDesc  
   and IsNull([Tax Type],'') <> N'' 
   and V.VendorID = BA.VendorID        
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )        
 )        
        
 --Tax amount on Purchase        
 update #VATReport set [Tax on Purchase (%c)] =  (        
  select SUM(BD.TaxAmount)  
  from BillDetail BD, BillAbstract BA, Vendors V, Tax, Items, tbl_merp_TaxType TxzType  
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and Items.Product_Code = BD.Product_Code  
   and BD.BillID = BA.BillID        
   and BA.Status = 0         
   and TxzType.TaxID = IsNull(BA.taxType,1)
   and TxzType.TaxID = @TaxTypeID 
   and TxzType.TaxType = [Tax Type]
   and BA.BillDate between @FromDate and @ToDate        
   and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
   and BD.TaxSuffered = Case When Convert(Decimal(18, 6), @Tax) = 0 Then BD.TaxSuffered Else (case isnull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end) End  
   and Tax.Tax_Description = Case When @TaxDesc = 'Exempt' Then Tax.Tax_Description Else @TaxDesc End  
   and IsNull(BD.TaxCode, 0) = Case When @TaxCode = 0 Then IsNull(BD.TaxCode, 0) Else @TaxCode End  
   and IsNull([Tax Type],'') <> N'' 
   and V.VendorID = BA.VendorID        
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--  else '%' end        
--        )        
 )        
--------------------------------------------------------------------------               
if @TaxSplitup = 'Yes'  
Begin  
 --VAT Total Purchase amount        
 update #VATReport set [VAT Total Purchase (%c)]  =  (        
  select SUM(BD.Amount)  
  from BillDetail BD, BillAbstract BA, Vendors V, Items, tbl_merp_TaxType TxzType  
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS        
   and Items.Product_Code = BD.Product_Code  
   and BD.BillID = BA.BillID        
   and BA.Status = 0         
   and TxzType.TaxID = IsNull(BA.taxType,1)
   and TxzType.TaxID = @TaxTypeID 
   and TxzType.TaxType = [Tax Type]
   and BA.BillDate between @FromDate and @ToDate        
   and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
   and (   
   BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = @TaxDesc)  
   or (BD.TaxSuffered = 0 )  
  )  
   and IsNull(BD.TaxCode, 0) = Case When @TaxCode  = 0 Then IsNull(BD.TaxCode, 0) Else @TaxCode End  
   and (case when BD.TaxSuffered=0 then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = @TaxDesc) end) = @TaxDesc  
   and V.VendorID = BA.VendorID        
--  And V.Locality = 1  
   and ( isNull(BA.TaxType,1) = 1 or isNull(BA.TaxType,1) = 3 )
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )        
 )        
        
 --VAT Tax amount on Purchase        
 update #VATReport set [VAT Tax on Purchase (%c)] =  (        
  select SUM(BD.TaxAmount)  
  from BillDetail BD, BillAbstract BA, Vendors V, Tax, Items, tbl_merp_TaxType TxzType  
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and Items.Product_Code = BD.Product_Code  
   and BD.BillID = BA.BillID        
   and BA.Status = 0         
   and TxzType.TaxID = IsNull(BA.taxType,1)
   and TxzType.TaxID = @TaxTypeID 
   and TxzType.TaxType = [Tax Type]
   and BA.BillDate between @FromDate and @ToDate        
   and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
   and BD.TaxSuffered = Case When Convert(Decimal(18, 6), @Tax) = 0 Then BD.TaxSuffered Else (case isnull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end) End  
   and Tax.Tax_Description = Case When @TaxDesc = 'Exempt' Then Tax.Tax_Description Else @TaxDesc End  
   and IsNull(BD.TaxCode, 0) = Case When @TaxCode = 0 Then IsNull(BD.TaxCode, 0) Else @TaxCode End  
   and V.VendorID = BA.VendorID        
--  And V.Locality = 1  
   and ( isNull(BA.TaxType,1) = 1 or isNull(BA.TaxType,1) = 3 )
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--  else '%' end        
--        )        
 )        
 --CST Total Purchase amount        
 update #VATReport set [CST Total Purchase (%c)]  =  (        
  select SUM(BD.Amount)  
  from BillDetail BD, BillAbstract BA, Vendors V, Items, tbl_merp_TaxType TxzType  
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS        
   and Items.Product_Code = BD.Product_Code  
   and BD.BillID = BA.BillID        
   and BA.Status = 0         
   and TxzType.TaxID = IsNull(BA.taxType,1)
   and TxzType.TaxID = @TaxTypeID 
   and TxzType.TaxType = [Tax Type]
   and BA.BillDate between @FromDate and @ToDate        
   and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)  
   and (   
   BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = @TaxDesc)
   or (BD.TaxSuffered = 0 )  
  )  
   and IsNull(BD.TaxCode, 0) = Case When @TaxCode  = 0 Then IsNull(BD.TaxCode, 0) Else @TaxCode End  
   and (case when BD.TaxSuffered=0 then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = @TaxDesc) end) = @TaxDesc  
   and V.VendorID = BA.VendorID        
--  And V.Locality = 2  
   and isNull(BA.TaxType,1) = 2
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )        
 )        
        
 --CST Tax amount on Purchase        
 update #VATReport set [CST Tax on Purchase (%c)] =  (        
  select SUM(BD.TaxAmount)  
  from BillDetail BD, BillAbstract BA, Vendors V, Tax, Items, tbl_merp_TaxType TxzType  
  where BD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and Items.Product_Code = BD.Product_Code  
   and BD.BillID = BA.BillID        
   and BA.Status = 0    
   and TxzType.TaxID = IsNull(BA.taxType,1)
   and TxzType.TaxID = @TaxTypeID 
   and TxzType.TaxType = [Tax Type]     
   and BA.BillDate between @FromDate and @ToDate        
   and BD.TaxSuffered = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
   and BD.TaxSuffered = Case When Convert(Decimal(18, 6), @Tax) = 0 Then BD.TaxSuffered Else (case Isnull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end) End  
   and Tax.Tax_Description = Case When @TaxDesc = 'Exempt' Then Tax.Tax_Description Else @TaxDesc End  
   and IsNull(BD.TaxCode, 0) = Case When @TaxCode = 0 Then IsNull(BD.TaxCode, 0) Else @TaxCode End  
   and V.VendorID = BA.VendorID        
--  And V.Locality = 2  
   and isNull(BA.TaxType,1) = 2
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--  else '%' end        
--        )        
 )        
  
End  
--------------------------------------------------------------------------        
 --Total Purchase Return amount        
 update #VATReport set [Total Purchase Return (%c)] = (        
  select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
  from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items  , Batch_Products bp  
  where ARA.AdjustmentID = ARD.AdjustmentID        
   and Items.Product_Code = ARD.Product_Code  
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  @TaxTypeID 
   and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
   and V.VendorID = ARA.VendorID        
   and (  
   ARD.Tax = (case when ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 ) then (select Tax.Percentage from tax where tax_description = @TaxDesc) else (select Tax.CST_Percentage from tax where tax_description = @TaxDesc) end)  
   or (ARD.Tax=0 )  
  )  
   and (case when ARD.Tax=0 then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = @TaxDesc) end)= @TaxDesc  
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )              
 )        
        
 --Tax amount on Purchase Return    
 update #VATReport set [Tax on Purchase Return (%c)] = (        
  select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
  from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax, Items  , Batch_Products bp  
  where ARA.AdjustmentID = ARD.AdjustmentID        
   and Items.Product_Code = ARD.Product_Code  
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  @TaxTypeID 
   and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)    
   and ARD.Tax = Case When Convert(Decimal(18, 6), @Tax) = 0 Then ARD.Tax Else (case when ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 ) then Tax.Percentage else Tax.CST_Percentage end) End  
   and Tax.Tax_Description = Case When @TaxDesc = 'Exempt' Then Tax.Tax_Description Else @TaxDesc End  
   and ARA.VendorID = V.VendorID        
--   and cast(V.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
    
  
--------------------------------------------------------------------------               
if @TaxSplitup = 'Yes'  
Begin  
 --VAT Total Purchase Return amount        
 update #VATReport set [VAT Total Purchase Return (%c)] = (        
  select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
  from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items  , Batch_Products bp  
  where ARA.AdjustmentID = ARD.AdjustmentID        
   and Items.Product_Code = ARD.Product_Code  
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  @TaxTypeID 
   and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
   and V.VendorID = ARA.VendorID        
   and (  
   ARD.Tax = (case when ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 ) then (select Tax.Percentage from tax where tax_description = @TaxDesc) else (select Tax.CST_Percentage from tax where tax_description = @TaxDesc) end)  
   or (ARD.Tax=0 )  
  )  
   and (case when ARD.Tax=0 then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = @TaxDesc) end)= @TaxDesc  
--   and V.Locality = 1  
   and ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 )
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )              
 )        
        
 --VAT Tax amount on Purchase Return    
 update #VATReport set [VAT Tax on Purchase Return (%c)] = (        
  select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
  from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax, Items  , Batch_Products bp  
  where ARA.AdjustmentID = ARD.AdjustmentID        
   and Items.Product_Code = ARD.Product_Code  
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  @TaxTypeID 
   and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)    
   and ARD.Tax = Case When Convert(Decimal(18, 6), @Tax) = 0 Then ARD.Tax Else (case when ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 ) then Tax.Percentage else Tax.CST_Percentage end) End  
   and Tax.Tax_Description = Case When @TaxDesc = 'Exempt' Then Tax.Tax_Description Else @TaxDesc End  
--   and V.Locality = 1  
   and ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 )
   and ARA.VendorID = V.VendorID        
--   and cast(V.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
        
 --CST Total Purchase Return amount        
 update #VATReport set [CST Total Purchase Return (%c)] = (        
  select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
  from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Items  , Batch_Products bp  
  where ARA.AdjustmentID = ARD.AdjustmentID        
   and Items.Product_Code = ARD.Product_Code  
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  @TaxTypeID 
   and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)   
   and V.VendorID = ARA.VendorID        
   and (  
   ARD.Tax = (case when ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 ) then (select Tax.Percentage from tax where tax_description = @TaxDesc) else (select Tax.CST_Percentage from tax where tax_description = @TaxDesc) end)  
   or (ARD.Tax=0 )  
  )  
   and (case when ARD.Tax=0 then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = @TaxDesc) end)= @TaxDesc  
--   and V.Locality = 2  
   and ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 )
--   and V.Locality like (        
--         case @Locality         
--         when 'Local' then '1'        
--         when 'Outstation' then '2'        
--         else '%' end        
--        )              
 )        
        
 --CST Tax amount on Purchase Return    
 update #VATReport set [CST Tax on Purchase Return (%c)] = (        
  select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))  
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax, Items  , Batch_Products bp  
  where ARA.AdjustmentID = ARD.AdjustmentID        
   and Items.Product_Code = ARD.Product_Code  
   and (isnull(ARA.Status,0) & 128) = 0        
   and ARD.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and ARA.AdjustmentDate between @FromDate and @ToDate        
   and ARD.BatchCode = bp.Batch_Code 
   and IsNull(bp.TaxType, 1) =  @TaxTypeID 
   and ARD.Tax = convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS)    
   and ARD.Tax = Case When Convert(Decimal(18, 6), @Tax) = 0 Then ARD.Tax Else (case when ( isNull(Bp.TaxType,1) = 1 or isNull(Bp.TaxType,1) = 3 ) then Tax.Percentage else Tax.CST_Percentage end) End  
   and Tax.Tax_Description = Case When @TaxDesc = 'Exempt' Then Tax.Tax_Description Else @TaxDesc End  
--   and V.Locality = 2  
   and isNull(Bp.TaxType,1) = 2
   and ARA.VendorID = V.VendorID        
--   and cast(V.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
  
End  
--------------------------------------------------------------------------               
 update #VATReport set [Net Purchase (%c)] = isnull([Total Purchase (%c)],0) - isnull([Total Purchase Return (%c)],0)        
 update #VATReport set [Net Purchase Tax (%c)] = isnull([Tax on Purchase (%c)],0) - isnull([Tax on Purchase Return (%c)],0)        
--------------------------------------------------------------------------  
 -- Total sales amount        
 update #VATReport set [Total Sales (%c)] = (        
  select sum(IDt.Amount) - sum(case #I.[taxtype] 
     when 'LST' then isnull(IDt.STPayable,0)        
     when 'CST' then isnull(IDT.CSTPayable,0)        
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It, #InvoiceTaxType #I
  where Idt.InvoiceID = IA.InvoiceID        
   and It.Product_Code = IDt.Product_Code  
   and (IA.Status & 192) = 0        
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and IA.InvoiceType in (1, 3)   
   and IDt.SalePrice <> 0   
--   and IA.InvoiceDate between @FromDate and @ToDate   
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and #I.InvoiceId = Ia.InvoiceId
   and ((( #I.[taxtype] = 'LST' or #I.[taxtype] = 'FLST') and IDt.TaxCode = (case @TaxDesc when 'Exempt' then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end))  or  
  (#I.[taxtype] = 'CST' and IDt.TaxCode2 = (case @TaxDesc when 'Exempt' then 0 else (select CST_Percentage from Tax where Tax_Description=@TaxDesc) end)))  
   and @TaxDesc = (case @TaxDesc when 'Exempt' then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)  
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case when ( #I.[taxtype] = 'LST' or #I.[taxtype] = 'FLST' )then IDt.TaxCode else IDt.TaxCode2 end)    
--   and IsNull([Tax Type],'') = N''
   and IA.CustomerID = C.CustomerID        
--   and cast(C.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
        
 --Tax on sales        
  
 update #VATReport set [Tax on Sales (%c)] = (        
  select sum(case #I.[taxtype] 
     when 'LST' then isnull(IDt.STPayable,0)        
     when 'CST' then isnull(IDT.CSTPayable,0)        
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)         
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, Items It, #InvoiceTaxType #I
  where Idt.InvoiceID = IA.InvoiceID        
   and It.Product_Code = IDt.Product_Code  
   and (IA.Status & 192) = 0        
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and IA.InvoiceType in (1, 3)        
   and IDt.SalePrice <> 0        
--   and IA.InvoiceDate between @FromDate and @ToDate        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and #I.InvoiceId = Ia.InvoiceId
   and ((( #I.[taxtype] = 'LST' or #I.[taxtype] = 'FLST' ) and IDt.TaxCode = Tax.Percentage)  or  
  (#I.[taxtype] = 'CST' and IDt.TaxCode2 = CST_Percentage ))  
   and @TaxDesc = Tax_Description  
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS ) = (Case when ( #I.[taxtype] = 'LST' or #I.[taxtype] = 'FLST' ) then IDt.TaxCode else IDt.TaxCode2 end)   
--   and IsNull([Tax Type],'') = N''
   and IA.CustomerID = C.CustomerID        
--   and cast(C.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
        
 -- Update Total Retail Sales         
 update #VATReport set  [Total Retail Sales (%c)] = (        
 select sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0))  
 from InvoiceAbstract IA
 Inner Join  InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID        
 Left Outer Join Customer C On IA.CustomerID = C.CustomerID        
 Inner Join Items It On It.Product_Code = IDt.Product_Code  
 Inner Join #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
 where(IA.Status & 192) = 0        
 and IA.InvoiceType in (2)        
 and IDt.SalePrice <> 0        
-- and IA.InvoiceDate between @FromDate and @ToDate        
-- and IsNull(C.Locality, 1) = @TaxTypeID
 and #I.[taxtype] = 'LST'
 and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode          
-- and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1  
 and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end)  
 and @TaxDesc = (case when IDt.TaxCode=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)  
 and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
 and IDt.Amount>-1  
)        
         
 -- Update Tax Retail Sales         
 update #VATReport set [Tax on Retail Sales (%c)] = (        
 select sum(isnull(IDt.STPayable,0))  
 from InvoiceAbstract IA
 Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID        
 Left Outer Join Customer C On IA.CustomerID = C.CustomerID        
 Inner Join Tax On IDt.TaxCode = Tax.Percentage   
 Inner Join #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
 where (IA.Status & 192) = 0        
 and IA.InvoiceType in (2)        
 and IDt.SalePrice <> 0        
-- and IA.InvoiceDate between @FromDate and @ToDate        
-- and IsNull(C.Locality, 1) = @TaxTypeID
 and #I.[taxtype] = 'LST'
 and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
 and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = IDt.TaxCode          
 -- and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1  
  and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
 and @TaxDesc = Tax.Tax_Description   
 and IDt.Amount>-1  
)  
        
 --Total Sales return saleable amount        
 update #VATReport set [Sales Return Saleable (%c)] = (        
  select sum(IDt.Amount) - sum(case #I.[taxtype] 
     when 'LST' then isnull(IDt.STPayable,0)        
 when 'CST' then isnull(IDT.CSTPayable,0)        
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It, #InvoiceTaxType #I
  where Idt.InvoiceID = IA.InvoiceID        
   and It.Product_Code = IDt.Product_Code  
   and (IA.Status & 192) = 0         
   and (IA.Status & 32) = 0  
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and IA.InvoiceType = 4         
   and IDt.SalePrice <> 0        
--   and IA.InvoiceDate between @FromDate and @ToDate        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and #I.InvoiceId = Ia.InvoiceId
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case #I.[taxtype] when 'LST' then IDt.TaxCode else IDt.TaxCode2 end)   
   and IA.CustomerID = C.CustomerID        
   and ((#I.[taxtype] = 'LST' and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end)) or   
  ( #I.[taxtype] = 'CST' and IDt.TaxCode2 = (case when IDt.TaxCode2=0 then 0 else (select CST_Percentage from Tax where Tax_Description=@TaxDesc) end)))  
   and @TaxDesc = (case @TaxDesc when 'Exempt' then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)  
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
--   and cast(C.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
        
 --tax amount on sales return saleable        
 update #VATReport set [Tax on Sales Return Saleable (%c)] = (        
  select sum(case #I.[taxtype] 
     when 'LST' then isnull(IDt.STPayable,0)        
 when 'CST' then isnull(IDT.CSTPayable,0)        
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)         
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, Items It, #InvoiceTaxType #I
  where Idt.InvoiceID = IA.InvoiceID        
   and It.Product_Code = IDt.Product_Code  
   and (IA.Status & 192) = 0         
   and (IA.Status & 32) = 0  
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and IA.InvoiceType = 4         
   and IDt.SalePrice <> 0        
--   and IA.InvoiceDate between @FromDate and @ToDate        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and #I.InvoiceId = Ia.InvoiceId
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case #I.[taxtype] when 'LST' then IDt.TaxCode else IDt.TaxCode2 end)    
   and IA.CustomerID = C.CustomerID        
   and ((#I.[taxtype] = 'LST' and IDt.TaxCode = Percentage)  or  
  (#I.[taxtype] = 'CST' and IDt.TaxCode2 = CST_Percentage))  
   and @TaxDesc = Tax_Description   
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
--   and cast(C.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
        
 --total Sales Return Damages        
 update #VATReport set [Sales Return Damages (%c)] = (        
  select sum(IDt.Amount) - sum(case #I.[taxtype] 
     when 'LST' then isnull(IDt.STPayable,0)        
     when 'CST' then isnull(IDT.CSTPayable,0)        
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)  
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Items It, #InvoiceTaxType #I
  where Idt.InvoiceID = IA.InvoiceID        
   and It.Product_Code = IDt.Product_Code  
   and (IA.Status & 192) = 0  
   and (IA.Status & 32) <> 0         
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and IA.InvoiceType = 4         
   and IDt.SalePrice <> 0        
--   and IA.InvoiceDate between @FromDate and @ToDate        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and #I.InvoiceId = Ia.InvoiceId
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case #I.[taxtype] when 'LST' then IDt.TaxCode else IDt.TaxCode2 end)    
   and IA.CustomerID = C.CustomerID        
   and ((#I.[taxtype] = 'LST' and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Percentage from Tax where Tax_Description=@TaxDesc) end)) or   
  (#I.[taxtype] = 'CST' and IDt.TaxCode2 = (case when IDt.TaxCode2=0 then 0 else (select CST_Percentage from Tax where Tax_Description=@TaxDesc) end)))  
   and @TaxDesc = (case @TaxDesc when 'Exempt' then 'Exempt' else (select Tax_Description from Tax where Tax_Description=@TaxDesc) end)  
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
--   and cast(C.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
        
 --Tax amount on sales return damages        
 update #VATReport set [Tax on Sales Return Damages (%c)] = (        
  select sum(case #I.[taxtype] 
     when 'LST' then isnull(IDt.STPayable,0)        
     when 'CST' then isnull(IDT.CSTPayable,0)        
     else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)         
  from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, #InvoiceTaxType #I
  where Idt.InvoiceID = IA.InvoiceID        
   and (IA.Status & 192) = 0         
   and (IA.Status & 32) <> 0  
   and IDt.Product_Code = ICode collate SQL_Latin1_General_Cp1_CI_AS   
   and IA.InvoiceType = 4         
   and IDt.SalePrice <> 0        
--   and IA.InvoiceDate between @FromDate and @ToDate        
--   and IsNull(C.Locality, 1) = @TaxTypeID
   and #I.InvoiceId = Ia.InvoiceId
   and convert(decimal(18,6),[Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = (Case #I.[taxtype] when 'LST' then IDt.TaxCode else IDt.TaxCode2 end)    
   and IA.CustomerID = C.CustomerID        
   and ((#I.[taxtype] = 'LST' and IDt.TaxCode = Percentage)  or  
  (#I.[taxtype] = 'CST' and IDt.TaxCode2 = CST_Percentage))  
   and Case When @TaxDesc = 'Exempt' Then Tax_Description Else @TaxDesc End = Tax_Description   
   and IsNull(IDt.TaxID, 0) = Case When @TaxCode = 0 Then IsNull(IDt.TaxID, 0) Else @TaxCode End  
--   and cast(C.Locality as nvarchar) like (case @Locality         
--             when 'Local' then '1'         
--             when 'Outstation' then '2'         
--             else '%' end) + '%'        
 )        
        
 -- Update Total Retail Sales Return  
 update #VATReport set [Total Retail Sales Return (%c)] = (        
 select abs(sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0)))  
 from InvoiceAbstract IA
 Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID        
 Left Outer Join  Customer C On IA.CustomerID = C.CustomerID        
 Inner Join Items It On It.Product_Code = IDt.Product_Code  
 where (IA.Status & 192) = 0        
 and IA.InvoiceType in (5,6)        
 and IDt.SalePrice <> 0        
 and IA.InvoiceDate between @FromDate and @ToDate    
 and IsNull(C.Locality, 1) = @TaxTypeID
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
 Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID        
 Left Outer Join Customer C On IA.CustomerID = C.CustomerID        
 Inner Join Tax On IsNull(C.Locality, 1) = @TaxTypeID 
 where (IA.Status & 192) = 0    
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
-- Select * from #VATReport  
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
        
select [ICode], [Item Code], [Item Name], [Tax %], [Tax Type],  
[Total Purchase (%c)],[Tax on Purchase (%c)],  
[VAT Total Purchase (%c)],[VAT Tax on Purchase (%c)],  
[CST Total Purchase (%c)],[CST Tax on Purchase (%c)],  
[Total Purchase Return (%c)], [Tax on Purchase Return (%c)],  
[VAT Total Purchase Return (%c)],[VAT Tax on Purchase Return (%c)],  
[CST Total Purchase Return (%c)],[CST Tax on Purchase Return (%c)],  
[Net Purchase (%c)], [Net Purchase Tax (%c)], [Total Sales (%c)], [Tax on Sales (%c)],   
[Total Retail Sales (%c)], [Tax on Retail Sales (%c)], [Sales Return Saleable (%c)],   
[Tax on Sales Return Saleable (%c)], [Sales Return Damages (%c)], [Tax on Sales Return Damages (%c)],   
[Total Retail Sales Return (%c)], [Tax on Retail Sales Return (%c)],   
[Net Sales Return (%c)], [Net Tax on Sales Return (%c)], [Net Sales (%c)],        
[Net Tax on Sales (%c)], [Net VAT Payable (%c)] Into #ResultVatReportDet  
from #VATReport        
Where Convert(Decimal(18, 6), [Tax %] collate SQL_Latin1_General_Cp1_CI_AS) = Convert(Decimal(18, 6), @Tax)  
  
If @TaxSplitup <> 'Yes'  
 Begin  
Set @SqlStat = 'Insert InTo #VATReportDet   
([ICode], [Item Code], [Item Name], [Tax %], [Tax Type],  [Total Purchase (%c)] ,        
[Tax on Purchase (%c)], [Total Purchase Return (%c)], [Tax on Purchase Return (%c)],        
[Net Purchase (%c)], [Net Purchase Tax (%c)], [Total Sales (%c)], [Tax on Sales (%c)],   
[Total Retail Sales (%c)], [Tax on Retail Sales (%c)], [Sales Return Saleable (%c)],   
[Tax on Sales Return Saleable (%c)], [Sales Return Damages (%c)], [Tax on Sales Return Damages (%c)],   
[Total Retail Sales Return (%c)], [Tax on Retail Sales Return (%c)],   
[Net Sales Return (%c)], [Net Tax on Sales Return (%c)], [Net Sales (%c)],        
[Net Tax on Sales (%c)], [Net VAT Payable (%c)])  
Select [ICode], [Item Code], [Item Name], [Tax %], [Tax Type], [Total Purchase (%c)] ,        
[Tax on Purchase (%c)], [Total Purchase Return (%c)], [Tax on Purchase Return (%c)],        
[Net Purchase (%c)], [Net Purchase Tax (%c)], [Total Sales (%c)], [Tax on Sales (%c)],   
[Total Retail Sales (%c)], [Tax on Retail Sales (%c)], [Sales Return Saleable (%c)],   
[Tax on Sales Return Saleable (%c)], [Sales Return Damages (%c)], [Tax on Sales Return Damages (%c)],   
[Total Retail Sales Return (%c)], [Tax on Retail Sales Return (%c)],   
[Net Sales Return (%c)], [Net Tax on Sales Return (%c)], [Net Sales (%c)],        
[Net Tax on Sales (%c)], [Net VAT Payable (%c)] From #ResultVatReportDet'  
Exec SP_ExecuteSQL @SqlStat  
 End  
  
--------------------------------------------------------------------------        
If @TaxSplitup = 'Yes'  
 Begin  
  
Set @SqlStat =   
'Insert InTo #VATReportDet   
([ICode], [Item Code], [Item Name], [Tax %], [Tax Type],  
[Total Purchase (%c)],[Tax on Purchase (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 1)  
 Set @SqlStat = @SqlStat + '[VAT Total Purchase (%c)],[VAT Tax on Purchase (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 0)  
 Set @SqlStat = @SqlStat + '[CST Total Purchase (%c)],[CST Tax on Purchase (%c)],'  
Set @SqlStat = @SqlStat + '[Total Purchase Return (%c)], [Tax on Purchase Return (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 1)  
 Set @SqlStat = @SqlStat + '[VAT Total Purchase Return (%c)], [VAT Tax on Purchase Return (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 0)  
 Set @SqlStat = @SqlStat + '[CST Total Purchase Return (%c)], [CST Tax on Purchase Return (%c)],'  
Set @SqlStat = @SqlStat + '[Net Purchase (%c)], [Net Purchase Tax (%c)],   
[Total Sales (%c)], [Tax on Sales (%c)],   
[Total Retail Sales (%c)], [Tax on Retail Sales (%c)],  
[Sales Return Saleable (%c)],[Tax on Sales Return Saleable (%c)],  
[Sales Return Damages (%c)], [Tax on Sales Return Damages (%c)],   
[Total Retail Sales Return (%c)], [Tax on Retail Sales Return (%c)],   
[Net Sales Return (%c)], [Net Tax on Sales Return (%c)], [Net Sales (%c)],        
[Net Tax on Sales (%c)], [Net VAT Payable (%c)])   
Select [ICode], [Item Code], [Item Name], [Tax %], [Tax Type],  
[Total Purchase (%c)],[Tax on Purchase (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 1)  
 Set @SqlStat = @SqlStat + '[VAT Total Purchase (%c)],[VAT Tax on Purchase (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 0)  
 Set @SqlStat = @SqlStat + '[CST Total Purchase (%c)],[CST Tax on Purchase (%c)],'  
Set @SqlStat = @SqlStat + '[Total Purchase Return (%c)], [Tax on Purchase Return (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 1)  
 Set @SqlStat = @SqlStat + '[VAT Total Purchase Return (%c)], [VAT Tax on Purchase Return (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 0)  
 Set @SqlStat = @SqlStat + '[CST Total Purchase Return (%c)], [CST Tax on Purchase Return (%c)],'  
Set @SqlStat = @SqlStat + '[Net Purchase (%c)], [Net Purchase Tax (%c)],  
[Total Sales (%c)], [Tax on Sales (%c)],   
[Total Retail Sales (%c)], [Tax on Retail Sales (%c)],   
[Sales Return Saleable (%c)],[Tax on Sales Return Saleable (%c)],   
[Sales Return Damages (%c)], [Tax on Sales Return Damages (%c)],   
[Total Retail Sales Return (%c)], [Tax on Retail Sales Return (%c)],   
[Net Sales Return (%c)], [Net Tax on Sales Return (%c)], [Net Sales (%c)],   
[Net Tax on Sales (%c)], [Net VAT Payable (%c)] From #ResultVatReportDet'  
Exec SP_ExecuteSQL @SqlStat  

Declare @TaxPercentage Decimal(18,6)  
  
Declare TaxCompColl Cursor For   
Select Trans,TaxID,CompID, LST, CompPos, CompDesc, CompTax  
From #TaxComponents   
Order By Trans,TaxID,LST Desc,CompPos  

Open TaxCompColl   
Fetch From TaxCompColl InTo @Trans, @TaxID, @CompID, @LST, @Pos, @ColName ,@TaxPercentage  
While @@Fetch_Status = 0  
Begin  
If @Trans =1 
  Begin
  Set @SQLStat = 'Update #VATReportDet Set '+  Left(@ColName,CharIndex(Char(15),@ColName)-1)  + ' = Case When IsNull([Tax Type],'''') <> '''' Then ' + Cast(@TaxPercentage AS NVArChar) + ' End'
  End
Else If @Trans =3 
  Begin
  --Set @SQLStat = 'Update #VATReportDet Set '+  Left(@ColName,CharIndex(Char(15),@ColName)-1)  + ' = Case When IsNull([Tax Type],'''') = '''' Then ' + Cast(@TaxPercentage AS NVArChar) + ' End'
Set @SQLStat = 'Update #VATReportDet Set '+  Left(@ColName,CharIndex(Char(15),@ColName)-1)  + ' = Case When IsNull([Tax Type],'''') <> '''' Then ' + Cast(@TaxPercentage AS NVArChar) + ' End'
  End
Else
  Begin
  Set @SQLStat = 'Update #VATReportDet Set '+  Left(@ColName,CharIndex(Char(15),@ColName)-1)  + ' = ' + Cast(@TaxPercentage AS NVArChar)  
  --+' Where [Tax Code] = ' + Cast(@TaxID as nVArChar)  
  End
Exec SP_ExecuteSQL @SqlStat  
Fetch Next From TaxCompColl InTo @Trans, @TaxID, @CompID, @LST, @Pos, @ColName ,@TaxPercentage  
End  
  
Close TaxCompColl  
DeAllocate TaxCompColl  
  
Declare TaxCompColl Cursor For   
Select Trans,TaxID,Tax,CompID, LST, CompPos, CompDesc, CompCalTax  
From #TaxComponents   
Where Trans in (1,2)  
Order By Trans,TaxID,LST Desc,CompPos  
  
Open TaxCompColl   
Fetch From TaxCompColl InTo @Trans, @TaxID,@TaxSuffered, @CompID, @LST, @Pos, @ColName ,@TaxPercentage  
While @@Fetch_Status = 0  
Begin  
If @Trans = 1   
  IF @LST = 1  
     Set @SQLStat = 'Update #VATReportDet Set '+  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))  + ' = Case When IsNull([Tax Type],'''') <> '''' Then (IsNull([VAT Tax on Purchase (%c)],0) * ' + Cast(@TaxPercentage AS nVArChar)  
     +'/' + Cast(@TaxSuffered as nVarChar) + ') End'-- Where [Tax Code] = ' + Cast(@TaxID as nVArChar) + ' And [Tax Desc] <> ''Exempt'''  
  Else IF @LST = 0  
     Set @SQLStat = 'Update #VATReportDet Set '+  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))  + ' = Case When IsNull([Tax Type],'''') <> '''' Then (IsNull([CST Tax on Purchase (%c)],0) * ' + Cast(@TaxPercentage AS nVArChar) 
     +'/' + Cast(@TaxSuffered as nVarChar) + ') End'-- Where [Tax Code] = ' + Cast(@TaxID as nVArChar) + ' And [Tax Desc] <> ''Exempt'''  
If @Trans = 2  
  If @LST = 1  
     Set @SQLStat = 'Update #VATReportDet Set '+  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))  + ' = (IsNull([VAT Tax on Purchase Return (%c)],0) * ' + Cast(@TaxPercentage AS nVArChar)  
     +'/' + Cast(@TaxSuffered as nVarChar) + ')'-- Where [Tax Code] = ' + Cast(@TaxID as nVArChar) + ' And [Tax Desc] <> ''Exempt'''  
  Else If @LST = 0  
     Set @SQLStat = 'Update #VATReportDet Set '+  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))  + ' = (IsNull([CST Tax on Purchase Return (%c)],0) * ' + Cast(@TaxPercentage AS nVArChar)  
     +'/' + Cast(@TaxSuffered as nVarChar) + ')'-- Where [Tax Code] = ' + Cast(@TaxID as nVArChar) + ' And [Tax Desc] <> ''Exempt'''  
Exec SP_ExecuteSQL @SqlStat  
  
Fetch Next From TaxCompColl InTo @Trans, @TaxID,@TaxSuffered, @CompID, @LST, @Pos, @ColName ,@TaxPercentage  
End  
  
Close TaxCompColl  
DeAllocate TaxCompColl  
  
Declare TaxCompColl Cursor For   
Select Trans,TaxID,CompID, LST, CompPos, CompDesc, CompCalTax  
From #TaxComponents   
Where Trans in (3,4,5,6,7)  
Order By Trans,TaxID,LST Desc,CompPos 
  
Open TaxCompColl   
Fetch From TaxCompColl InTo @Trans, @TaxID, @CompID, @LST, @Pos, @ColName ,@TaxPercentage  
While @@Fetch_Status = 0  
Begin  
IF @Trans = 3 
Begin
  Set @SQLStat = 'Update #VATReportDet Set ' +  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))    
  + ' = IsNull(' + Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName))) + ',0) + ' +  
  ' (Select Sum(ITC.Tax_Value)    
  From InvoiceAbstract IA,  
  (Select Distinct InvoiceDetail.InvoiceID , Product_Code , TaxID from InvoiceDetail, #InvoiceTaxType #I  
  Where ' + (Case @LST When 0 then 'TaxCode2' Else 'TaxCode' End) + ' <> 0 and #I.InvoiceId = InvoiceDetail.InvoiceId And '  
  + (Case @LST When 0 then 'TaxCode2' Else 'TaxCode' End) + ' = ' + Cast(@Tax as nVarchar)  
  +' And SalePrice <> 0 And Product_Code in (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
  ) IDT , Customer C , InvoiceTaxComponents ITC Where IA.Status & 192 = 0 '+  
  (Case @Trans When 5 Then ' And (IA.Status & 32) = 0 ' When 6 Then ' And (IA.Status & 32) <> 0 ' Else '' End) +    
  'And IA.InvoiceType in ' + (Case @Trans When 3 Then '(1,3)' When 5 Then '(4)' When 6 Then '(4)' When 4 Then '(2)' When 7 Then '(5,6)' End) + '  
  And IA.InvoiceDate Between '''+ Cast(@FromDate as nVarChar)+ ''' and ''' + Cast(@ToDate as nVarChar)  
  +''' And ITC.Tax_Code = ' + Cast(@TaxID as nVarChar)  
  +' And ITC.Tax_Component_Code = ' + Cast(@CompID as nVarChar)  
  +' And IDT.TaxID = ' + Cast(@TaxCode as nVArChar)  
  +' And IA.InvoiceID = IDT.InvoiceID   
  And ITC.InvoiceID = IA.InvoiceID   
  And IDT.Product_Code = ICode Collate SQL_Latin1_General_Cp1_CI_AS   
  And ITC.Product_Code = IDT.Product_Code   
  And ITC.Tax_Code = IDT.TaxID  
  And IA.CustomerID '+ (Case When @Trans in (4,7) Then '*'Else '' End) +'= C.CustomerID ' +   
--  ' and IsNull(C.Locality, 1) = ' + convert (varchar, @TaxTypeID) + 

--  ' And cast(C.Locality as nvarchar) like (case '''+ @Locality +  
--  ''' when ''Local'' then ''1''   
--  when ''Outstation'' then ''2''   
--  else ''%'' end) + ''%''' + 
  ') Where IsNull([Tax Type],'''') <> '''''
print @SQLStat
End
Else
Begin  
  Set @SQLStat = 'Update #VATReportDet Set ' +  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))    
  + ' = IsNull(' + Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName))) + ',0) + ' +  
  ' (Select Sum(ITC.Tax_Value)    
  From InvoiceAbstract IA,  
  (Select Distinct InvoiceDetail.InvoiceID , Product_Code , TaxID from InvoiceDetail, #InvoiceTaxType #I  
  Where ' + (Case @LST When 0 then 'TaxCode2' Else 'TaxCode' End) + ' <> 0 and #I.InvoiceId = InvoiceDetail.InvoiceId And '  
  + (Case @LST When 0 then 'TaxCode2' Else 'TaxCode' End) + ' = ' + Cast(@Tax as nVarchar)  
  +' And SalePrice <> 0 And Product_Code in (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
  ) IDT , Customer C , InvoiceTaxComponents ITC Where IA.Status & 192 = 0 '+  
  (Case @Trans When 5 Then ' And (IA.Status & 32) = 0 ' When 6 Then ' And (IA.Status & 32) <> 0 ' Else '' End) +    
  'And IA.InvoiceType in ' + (Case @Trans When 3 Then '(1,3)' When 5 Then '(4)' When 6 Then '(4)' When 4 Then '(2)' When 7 Then '(5,6)' End) + '  
  And IA.InvoiceDate Between '''+ Cast(@FromDate as nVarChar)+ ''' and ''' + Cast(@ToDate as nVarChar)  
  +''' And ITC.Tax_Code = ' + Cast(@TaxID as nVarChar)  
  +' And ITC.Tax_Component_Code = ' + Cast(@CompID as nVarChar)  
  +' And IDT.TaxID = ' + Cast(@TaxCode as nVArChar)  
  +' And IA.InvoiceID = IDT.InvoiceID   
  And ITC.InvoiceID = IA.InvoiceID   
  And IDT.Product_Code = ICode Collate SQL_Latin1_General_Cp1_CI_AS   
  And ITC.Product_Code = IDT.Product_Code   
  And ITC.Tax_Code = IDT.TaxID  
  And IA.CustomerID '+ (Case When @Trans in (4,7) Then '*' Else '' End) + '= C.CustomerID ' +   
--  ' and IsNull(C.Locality, 1) = ' + convert (varchar, @TaxTypeID) + '
--  And cast(C.Locality as nvarchar) like (case '''+ @Locality +  
--  ''' when ''Local'' then ''1''   
--  when ''Outstation'' then ''2''   
--  else ''%'' end) + ''%'')'  
  + ')'  
End
--Where [Tax Code] = ' + Cast(@TaxID as nVarChar)  
Exec SP_ExecuteSQL @SqlStat  
  
Fetch Next From TaxCompColl InTo @Trans, @TaxID, @CompID, @LST, @Pos, @ColName ,@TaxPercentage  
End  
  
Close TaxCompColl  
DeAllocate TaxCompColl  
  
 End  
--------------------------------------------------------------------------        
  
Select * from #VATReportDet  
  
--Drop Table #TaxComponents   
Drop Table #VATReportDet  
Drop Table #ResultVatReportDet  
Drop Table #VATReport        
Drop Table  #tmpProd        
   --GSTOut:     
end  
