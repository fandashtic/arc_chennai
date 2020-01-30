CREATE procedure [dbo].[spr_list_Itemwise_VAT_Report_ITC]  
(            
@FromDate datetime,             
 @ToDate DateTime,            
 @Tax nvarchar(10),            
 @Locality nvarchar(15),            
 @ItemCode nvarchar(2550),  
-- @ItemName nvarchar(2550) --Unused           
 @TaxSplitup nVarchar(5),
 @TaxType nVarchar(20) 
)             
as  
-- Tax Componenet Handled  
Declare @SqlStat nVarchar(4000)  
Declare @TaxTypeID Int   
--select @FromDate = '18-08-2011', @ToDate = '18-08-2011 23:59:59', @Tax =  '%', @Locality = '%', @ItemCode =  '%',  @TaxSplitup  = 'No', @TaxType =  'LST'
Select @TaxTypeID = TaxID From tbl_mERP_Taxtype 
Where TaxType = @TaxType 

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)    
Create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @ItemCode='%'  
   insert into #tmpProd select product_code from items  
else  
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)  
   
--declare @temp datetime
Set DATEFormat DMY 
--set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
--if(@FROMDATE > @temp )
--begin
--select 0,'This report cannot be generated for GST period' as Reason
--goto GSTOut
-- end               
                 
--if(@TODATE > @temp )
--begin
--set @TODATE  = @temp 
----goto GSTOut
--end                 
            
begin            
 declare @TaxValue decimal(18,6)    
 If @Tax = '%'     
 set @TaxValue = 0    
 else    
 Set @TaxValue = convert(decimal(18,6),@Tax)    
             
Create table #VATReport   
(            
 [Tax Code] Int,  
 [Temp Tax Desc] nvarchar(520) COLLATE SQL_Latin1_General_CP1_CI_AS,            
 [Tax Desc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,            
 [Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,            
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
  
if Isnumeric(@Tax) = 1            
begin            
 set @Tax = convert(nvarchar,convert(decimal(18,6),@Tax))            
end            
else            
begin            
 set @Tax = '%'            
end  
  
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
Insert into #VATReport ([Tax Code], [Temp Tax Desc], [Tax Desc], [Tax %])            
-- Bills            
select IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,BD.TaxSuffered)+char(15)+     
(case when BD.TaxSuffered = 0 then 'Exempt' else max([Tax_Description]) end),     
(case when BD.TaxSuffered = 0 then 'Exempt' else max([Tax_Description]) end),      
(case when BD.TaxSuffered = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end)    
from BillAbstract BA
Inner Join BillDetail BD On BA.BillID = BD.BillID  
Inner Join Vendors V On V.VendorID = BA.VendorID            
Left Outer Join Tax On BD.TaxCode = Tax.Tax_Code  
where  
 BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
 and BA.Status = 0            
 and BA.BillDate between @FromDate and @ToDate    
 and IsNull(BA.TaxType, 1) = @TaxTypeID 
 and (    
  BD.TaxSuffered = @TaxValue    
  Or @Tax = '%'    
 )  
-- and V.Locality like (            
-- case @Locality             
-- when 'Local' then '1'            
-- when 'Outstation' then '2'            
-- else '%' end)  
group by Tax.Tax_Code, BD.TaxSuffered            
-- purchase Return            
union    
Select IsNull(min(Tax.Tax_Code), 0), convert(nVarChar, IsNull(min(Tax.Tax_Code), 0)) + char(15) + convert(nvarchar,ARD.Tax)+char(15)+     
(case when ARD.Tax = 0 then 'Exempt' else min([Tax_Description]) end),     
(case when ARD.Tax = 0 then 'Exempt' else min([Tax_Description]) end),     
(case when ARD.Tax = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end)    
from AdjustmentReturnDetail ARD
Inner Join AdjustmentReturnAbstract ARA On ARA.AdjustmentID = ARD.AdjustmentID            
Inner Join Vendors V On  ARA.VendorID = V.VendorID  
Left Outer Join ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
    union 
  select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax On ARD.Tax = Tax.Percentage    
 Inner Join Batch_Products bp  On ARD.BatchCode = bp.Batch_Code 
where   
 ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)            
 and (isnull(ARA.Status,0) & 128) = 0            
 and ARA.AdjustmentDate between @FromDate and @ToDate 
 and IsNull(bp.TaxType, 1) = @TaxTypeID 
 and (    
  ARD.Tax = @TaxValue    
  Or @Tax = '%'    
 )  
-- and cast(V.Locality as nvarchar) like             
-- (case @Locality             
-- when 'Local' then '1'             
-- when 'Outstation' then '2'             
-- else '%' end) + '%'  
 
 
 and Tax.taxtype = Case when ( IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) then 1 
					     when IsNull(bp.TaxType, 1) = 2 then 2 end 
-- and ARD.TaxSuffApplicableOn *= Tax.LSTApplicableOn   
-- and ARD.TaxSuffPartOff *= Tax.LSTPartOff         
group by  ARD.Tax            

-- Invoices  
union    
Select IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,IDt.TaxCode)+char(15)+     
(Case When IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),     
(Case When IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),     
(Case When IDt.TaxCode = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end)    
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID   
Inner Join Customer C On C.CustomerID = IA.CustomerID   
Left Outer Join tax On IDt.TaxID = Tax.Tax_Code   
Inner Join #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where   
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
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
--and IA.InvoiceDate between @FromDate and @ToDate  
and (    
  IDt.TaxCode = @TaxValue    
  or @Tax = '%'    
  )    
--and C.Locality = 1 and C.Locality = @TaxTypeID 
and #I.[taxtype] = 'LST'
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
group by Tax.Tax_Code,IDt.TaxCode
  
union    
Select IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,IDt.TaxCode2)+char(15)+     
(Case When IDt.TaxCode2 = 0 then 'Exempt' else max([Tax_Description]) end),     
(Case When IDt.TaxCode2 = 0 then 'Exempt' else max([Tax_Description]) end),     
(Case When IDt.TaxCode2 = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) end)    
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID            
Inner Join Customer C On C.CustomerID = IA.CustomerID            
Left Outer Join Tax On IDt.TaxID = Tax.Tax_Code  
Inner Join #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where             
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
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
--and IA.InvoiceDate between @FromDate and @ToDate 
and (    
  IDt.TaxCode2 = @TaxValue    
  or @Tax = '%'    
  )    
--and C.Locality = 2 and C.Locality = @TaxTypeID   
and #I.[taxtype] = 'CST'
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
group by Tax.Tax_Code, IDt.TaxCode2  
union    
-- Retail Invoice            
Select IsNull(Tax.Tax_Code, 0), convert(nVarChar, IsNull(Tax.Tax_Code, 0)) + char(15) + convert(nvarchar,IDt.TaxCode)+char(15)+     
(Case When IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),     
(Case When IDt.TaxCode = 0 then 'Exempt' else max([Tax_Description]) end),     
(Case When IDt.TaxCode = 0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end)    
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID            
Left Outer Join Customer C On C.CustomerID = Cast(IA.CustomerID  as int)   
Left Outer Join Tax On IDt.TaxID = Tax.Tax_Code  
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
where             
--It.ProductName like @ItemName and           
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and (Isnull(IA.Status, 0) & 192) = 0            
and IA.InvoiceType in (2,5,6)            
--and IA.InvoiceDate between @FromDate and @ToDate            
--and C.Locality = @TaxTypeID 
and (    
  IDt.TaxCode = @TaxValue    
  or @Tax = '%'    
  )    
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
group by Tax.Tax_Code, IDt.TaxCode  
Delete from #VATReport where [tax desc] = 'Exempt' and [tax code] Not In  ( Select [tax_code] from tax where percentage = 0)   
---------------------------------------------------------------------------  
-- Select * from #VATReport  
---------------------------------------------------------------------------  
-- Tax Component Handle  
---------------------------------------------------------------------------  
Create Table #VATReportAbs  
(  
 [Tax Code] Int,  
 [Temp Tax Desc] nvarchar(520) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 [Tax Desc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 [Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
----------------------------------------------------------------------------------------  
If @TaxSplitup <> 'Yes'  
Begin  
 Alter Table #VATReportAbs Add [Total Purchase (%c)] Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Purchase (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Total Purchase Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Purchase Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Purchase (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Purchase Tax (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Total Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Total Retail Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Retail Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Sales Return Saleable (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Sales Return Saleable (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Sales Return Damages (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Sales Return Damages (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Total Retail Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Retail Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Tax on Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Tax on Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net VAT Payable (%c)] Decimal(18,6)  
End  
----------------------------------------------------------------------------------------  
If @TaxSplitup = 'Yes'  
 Begin  
  
Create Table #TaxComponents   
(Trans int,TaxID int,Tax Decimal(18,6),CompID int,LST int,  
CompTax Decimal(18,6),CompCalTax Decimal(18,6),CompPos int,CompDesc nVarChar(1000))  

Insert Into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Purchase LST  
select 1,IsNull(Tax.Tax_Code, 0), IsNull(BD.TaxSuffered,0) , TC.TaxComponent_Code , TC.LST_Flag , TC.Tax_Percentage , TC.Sp_Percentage  
from BillAbstract BA, BillDetail BD, Vendors V, Tax , TaxComponents TC  
where           
 BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
 and BA.Status = 0  
 and BA.BillDate between @FromDate and @ToDate  
 and IsNull(BA.TaxType, 1) = @TaxTypeID 
 and (    
  BD.TaxSuffered = @TaxValue    
  Or @Tax = '%'    
 )   
 -- From now on, A item can be sold to a local vendor with CST tax type and vice versa. So we are changing the filter 
 --And V.Locality = 1
 and ( IsNull(BA.TaxType, 1) = 1 or IsNull(BA.TaxType, 1) = 3 )
 And TC.LST_Flag = ( Case when @TaxTypeID = 2 then 0 Else 1 end )
-- and V.Locality like (            
-- case @Locality             
-- when 'Local' then '1'            
-- when 'Outstation' then '2'            
-- else '%' end)   
 and BA.BillID = BD.BillID  
 and BD.TaxCode = Tax.Tax_Code  
 And Tax.Tax_Code = TC.Tax_Code  
 and V.VendorID = BA.VendorID            
group by Tax.Tax_Code, BD.TaxSuffered,TC.TaxComponent_Code , TC.LST_Flag , TC.Tax_Percentage ,TC.Sp_Percentage  
Order By Tax.Tax_Code, BD.TaxSuffered,TC.TaxComponent_Code , TC.LST_Flag Desc , TC.Tax_Percentage,TC.Sp_Percentage  

Insert Into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Purchase CST  
select 1,IsNull(Tax.Tax_Code, 0), IsNull(BD.TaxSuffered,0) , TC.TaxComponent_Code , TC.LST_Flag , TC.Tax_Percentage , TC.Sp_Percentage  
from BillAbstract BA, BillDetail BD, Vendors V, Tax , TaxComponents TC  
where           
 BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
 and BA.Status = 0  
 and BA.BillDate between @FromDate and @ToDate  
 and IsNull(BA.TaxType, 1) = @TaxTypeID 
 and (    
  BD.TaxSuffered = @TaxValue    
  Or @Tax = '%'    
 )   
 -- From now on, A item can be sold to a local vendor with CST tax type and vice versa. So we are changing the filter 
 --And V.Locality = 2
 and IsNull(BA.TaxType, 1) = 2
 And TC.LST_Flag = ( Case when @TaxTypeID = 2 then 0 Else 1 end )
-- and V.Locality like (            
-- case @Locality             
-- when 'Local' then '1'            
-- when 'Outstation' then '2'            
-- else '%' end)   
 and BA.BillID = BD.BillID  
 and BD.TaxCode = Tax.Tax_Code  
 And Tax.Tax_Code = TC.Tax_Code  
 and V.VendorID = BA.VendorID            
group by Tax.Tax_Code, BD.TaxSuffered,TC.TaxComponent_Code , TC.LST_Flag , TC.Tax_Percentage ,TC.Sp_Percentage  
Order By Tax.Tax_Code, BD.TaxSuffered,TC.TaxComponent_Code , TC.LST_Flag Desc , TC.Tax_Percentage,TC.Sp_Percentage  

Insert Into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Purchase Return LST  
Select 2,IsNull(Tax.Tax_Code, 0), IsNull(ARD.Tax,0) , TC.TaxComponent_Code , TC.LST_Flag ,TC.Tax_Percentage ,  TC.Sp_Percentage  
from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, Tax , TaxComponents TC , Batch_products BP  
where   
 ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)            
 and (isnull(ARA.Status,0) & 128) = 0            
 and ARA.AdjustmentDate between @FromDate and @ToDate            
 and (    
  ARD.Tax = @TaxValue    
  Or @Tax = '%'    
 )    
-- From now on, A item can be sold to a local vendor with CST tax type and vice versa. So we are changing the filter 
 --And V.Locality = 1
 and ( IsNull(Bp.TaxType, 1) = 1 or IsNull(Bp.TaxType, 1) = 3 )
 And TC.LST_Flag = ( Case when @TaxTypeID = 2 then 0 Else 1 end )
-- and cast(V.Locality as nvarchar) like             
-- (case @Locality             
-- when 'Local' then '1'             
-- when 'Outstation' then '2'             
-- else '%' end) + '%'   
 And ARD.BatchCode = BP.Batch_Code  
 And IsNull(bp.TaxType, 1) =  @TaxTypeID 
 and ARA.AdjustmentID = ARD.AdjustmentID            
 and ARA.VendorID = V.VendorID   
 And BP.GRNTaxID = Tax.Tax_Code  
 And Tax.Tax_Code = TC.Tax_Code           
group by Tax.Tax_Code, ARD.Tax , TC.TaxComponent_Code , TC.LST_Flag ,TC.Tax_Percentage, TC.Sp_Percentage  
Order By Tax.Tax_Code, ARD.Tax , TC.TaxComponent_Code , TC.LST_Flag Desc,TC.Tax_Percentage, TC.Sp_Percentage  
  

Insert Into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Purchase Return CST  
Select 2,IsNull(Tax.Tax_Code, 0), IsNull(ARD.Tax,0) , TC.TaxComponent_Code , TC.LST_Flag ,TC.Tax_Percentage ,  TC.Sp_Percentage  
from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V, 
    ( select min(tax_code) tax_code, percentage, 1 taxtype, min(Tax_Description) Tax_Description from Tax group by percentage 
        union 
      select min(tax_code) tax_code, cst_percentage percentage, 2 taxtype, min(Tax_Description) Tax_Description from Tax group by cst_percentage ) tax,   
  TaxComponents TC , Batch_products BP  
where   
 ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
 and (isnull(ARA.Status,0) & 128) = 0            
 and ARA.AdjustmentDate between @FromDate and @ToDate            
 and (    
  ARD.Tax = @TaxValue    
  Or @Tax = '%'    
 )    
 -- From now on, A item can be sold to a local vendor with CST tax type and vice versa. So we are changing the filter 
  And TC.LST_Flag = ( Case when @TaxTypeID = 2 then 0 Else 1 end )
 --And V.Locality = 2  
-- and cast(V.Locality as nvarchar) like             
-- (case @Locality             
-- when 'Local' then '1'             
-- when 'Outstation' then '2'             
-- else '%' end) + '%'   
 And ARD.BatchCode = BP.Batch_Code   
 And IsNull(bp.TaxType, 1) =  @TaxTypeID 
 and ARA.AdjustmentID = ARD.AdjustmentID            
 and ARA.VendorID = V.VendorID   
 And BP.GRNTaxID = Tax.Tax_Code  
 And Tax.Tax_Code = TC.Tax_Code           
 and Tax.taxtype = Case when ( IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3) then 1 
                        when IsNull(bp.TaxType, 1) = 2 then 2 end 
group by Tax.Tax_Code, ARD.Tax , TC.TaxComponent_Code , TC.LST_Flag ,TC.Tax_Percentage, TC.Sp_Percentage  
Order By Tax.Tax_Code, ARD.Tax , TC.TaxComponent_Code , TC.LST_Flag Desc,TC.Tax_Percentage, TC.Sp_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Invoice Tax Component - LST  
Select 3,IsNull(Tax.Tax_Code, 0) , IDt.TaxCode , ITC.Tax_Component_Code, 1, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax , InvoiceTaxComponents ITC, #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
And IA.InvoiceType in (1,3)  
and IsNull(IA.Status,0) & 192 = 0  
--and IA.InvoiceDate between @FromDate and @ToDate
--and IsNull(C.Locality, 1) =  @TaxTypeID
and #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
and (    
  IDt.TaxCode = @TaxValue    
  or @Tax = '%'    
  )   
And IDt.TaxCode <> 0  
--and C.Locality = 1         
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
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
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax , InvoiceTaxComponents ITC, #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IsNull(IA.Status,0) & 32 = 0  
And IA.InvoiceType in (4)  
--and IA.InvoiceDate between @FromDate and @ToDate 
--and IsNull(C.Locality, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
and (    
  IDt.TaxCode = @TaxValue    
  or @Tax = '%'    
  )   
And IDt.TaxCode <> 0  
--and C.Locality = 1         
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
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
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax , InvoiceTaxComponents ITC, #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IsNull(IA.Status,0) & 32 <> 0  
And IA.InvoiceType in (4)  
--and IA.InvoiceDate between @FromDate and @ToDate  
--and IsNull(C.Locality, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
and (    
  IDt.TaxCode = @TaxValue    
  or @Tax = '%'    
  )    
And IDt.TaxCode <> 0  
--and C.Locality = 1         
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
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
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, InvoiceTaxComponents ITC, #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IA.InvoiceType in (1,3)  
--and IA.InvoiceDate between @FromDate and @ToDate   
--and IsNull(C.Locality, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'CST'
and (    
  IDt.TaxCode2 = @TaxValue    
  or @Tax = '%'    
  )   
And IDt.TaxCode2 <> 0  
--and C.Locality = 2    
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
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
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, InvoiceTaxComponents ITC, #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IsNull(IA.Status,0) & 32 = 0  
And IA.InvoiceType in (4)  
--and IA.InvoiceDate between @FromDate and @ToDate
--and IsNull(C.Locality, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'CST'
and (    
  IDt.TaxCode2 = @TaxValue    
  or @Tax = '%'    
  )   
And IDt.TaxCode2 <> 0  
--and C.Locality = 2    
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
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
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, Tax, InvoiceTaxComponents ITC, #InvoiceTaxType #I
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and IsNull(IA.Status,0) & 192 = 0  
And IsNull(IA.Status,0) & 32 <> 0  
And IA.InvoiceType in (4)  
and (    
  IDt.TaxCode2 = @TaxValue    
  or @Tax = '%'    
  )    
--and IA.InvoiceDate between @FromDate and @ToDate  
--and IsNull(C.Locality, 1) =  @TaxTypeID 
and #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'CST'
And IDt.TaxCode2 <> 0  
--and C.Locality = 2    
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
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
Inner Join  InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID            
Left Outer Join Customer C On C.CustomerID = Cast(IA.CustomerID  as int)          
Inner Join Tax On IDt.TaxID = Tax.Tax_Code  
Inner Join InvoiceTaxComponents ITC On ITC.InvoiceID = IA.InvoiceID  
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and (Isnull(IA.Status, 0) & 192) = 0            
and IA.InvoiceType in (2)            
--and IA.InvoiceDate between @FromDate and @ToDate  
--and IsNull(C.Locality, 1) =  @TaxTypeID 
and (    
  IDt.TaxCode = @TaxValue    
  or @Tax = '%'    
  )    
And IDt.TaxCode <> 0   
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
And ITC.Tax_Code = IDT.TaxID  
group by Tax.Tax_Code, IDt.TaxCode, ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Insert into #TaxComponents (Trans ,TaxID ,Tax ,CompID ,LST ,CompTax ,CompCalTax)  
-- Retail Sales Return Tax Component  
Select 7, IsNull(Tax.Tax_Code, 0), IDt.TaxCode , ITC.Tax_Component_Code, 1, ITC.Tax_Percentage, ITC.SP_Percentage  
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On IA.InvoiceID = IDt.InvoiceID            
Left Outer Join Customer C On C.CustomerID = Cast(IA.CustomerID  as int)          
Inner Join Tax On IDt.TaxID = Tax.Tax_Code  
Inner Join InvoiceTaxComponents ITC On ITC.InvoiceID = IA.InvoiceID  And ITC.Tax_Code = IDT.TaxID  
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
where  
IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and (Isnull(IA.Status, 0) & 192) = 0            
and IA.InvoiceType in (5,6)            
--and IA.InvoiceDate between @FromDate and @ToDate  
--and IsNull(C.Locality, 1) =  @TaxTypeID 
and (    
  IDt.TaxCode = @TaxValue    
  or @Tax = '%'    
  )    
And IDt.TaxCode <> 0   
--and C.Locality = ( Case when @Locality = 'Local' then 1 when @Locality = 'Outstation' then 2 when @Locality = '%' then C.Locality Else 0 End )
group by Tax.Tax_Code, IDt.TaxCode, ITC.Tax_Component_Code, ITC.Tax_Percentage, ITC.SP_Percentage  
  
Declare @Trans Int  
Declare @TaxID Int  
Declare @TaxSuffered Decimal(18,6)  
Declare @CompID Int  
Declare @Pos Int  
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
--+ '[' + dbo.mERP_fn_GetTaxColFormat(TaxID, CompID) + ' Tax Amount(%c)'  
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

Set @Trans = 1  
while @Trans <=7  
Begin  
  
if @Trans = 1  
Begin  
 Alter Table #VATReportAbs Add [Total Purchase (%c)] Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Purchase (%c)]  Decimal(18,6)  
 if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 1)  
 Begin  
 Alter Table #VATReportAbs Add [VAT Total Purchase (%c)] Decimal(18,6)  
 Alter Table #VATReportAbs Add [VAT Tax on Purchase (%c)]  Decimal(18,6)  
 End  
End  
Else If @Trans = 2  
Begin  
 Alter Table #VATReportAbs Add [Total Purchase Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Purchase Return (%c)]  Decimal(18,6)  
 if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 1)  
 Begin  
 Alter Table #VATReportAbs Add [VAT Total Purchase Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [VAT Tax on Purchase Return (%c)]  Decimal(18,6)  
 End  
End  
  
Declare TaxCompColl Cursor For   
Select Distinct CompDesc From #TaxComponents   
Where Trans = @Trans And LST = 1  

Open TaxCompColl   
Fetch From TaxCompColl InTo @ColName  
While @@Fetch_Status = 0  
Begin
-- print @ColName
-- print (Len(LTrim(@ColName))-CharIndex(Char(15),@ColName))
-- print Len(LTrim(@ColName))
-- print CharIndex(Char(15),@ColName)
 Set @SqlStat = 'Alter Table #VATReportAbs Add ' + Left(@ColName,CharIndex(Char(15),@ColName)-1) + ' Decimal(18,6)'  
 Exec sp_ExecuteSQL @SqlStat  
 Set @SqlStat = 'Alter Table #VATReportAbs Add ' + Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName))) + ' Decimal(18,6)'  
 Exec sp_ExecuteSQL @SqlStat  
Fetch Next From TaxCompColl InTo @ColName  
End  
--print '**2'  
Close TaxCompColl  
DeAllocate TaxCompColl  
  
if @Trans = 1  
Begin  
 if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 0)  
 Begin  
 Alter Table #VATReportAbs Add [CST Total Purchase (%c)] Decimal(18,6)  
 Alter Table #VATReportAbs Add [CST Tax on Purchase (%c)]  Decimal(18,6)  
 End  
End  
Else if @Trans = 2  
Begin  
 if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 0)  
 Begin  
 Alter Table #VATReportAbs Add [CST Total Purchase Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [CST Tax on Purchase Return (%c)]  Decimal(18,6)  
 End  
End  
  
Declare TaxCompColl Cursor For   
Select Distinct CompDesc From #TaxComponents   
Where Trans = @Trans And LST = 0  
--print '**3'
Open TaxCompColl   
Fetch From TaxCompColl InTo @ColName  
While @@Fetch_Status = 0  
Begin  
 Set @SqlStat = 'Alter Table #VATReportAbs Add ' + Left(@ColName,CharIndex(Char(15),@ColName)-1) + ' Decimal(18,6)'  
 Exec sp_ExecuteSQL @SqlStat  
 Set @SqlStat = 'Alter Table #VATReportAbs Add ' + Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName))) + ' Decimal(18,6)'  
 Exec sp_ExecuteSQL @SqlStat  
Fetch Next From TaxCompColl InTo @ColName  
End  
  
Close TaxCompColl  
DeAllocate TaxCompColl  
--print '**4'  
Set @Trans = @Trans + 1  
  
If @Trans = 3  
Begin  
 Alter Table #VATReportAbs Add [Net Purchase (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Purchase Tax (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Total Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Sales (%c)]  Decimal(18,6)  
End  
Else If @Trans = 4  
Begin  
 Alter Table #VATReportAbs Add [Total Retail Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Retail Sales (%c)]  Decimal(18,6)  
End  
Else If @Trans = 5  
Begin  
 Alter Table #VATReportAbs Add [Sales Return Saleable (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Sales Return Saleable (%c)]  Decimal(18,6)  
End  
Else If @Trans = 6  
Begin  
 Alter Table #VATReportAbs Add [Sales Return Damages (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Sales Return Damages (%c)]  Decimal(18,6)  
End  
Else If @Trans = 7  
Begin  
 Alter Table #VATReportAbs Add [Total Retail Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Tax on Retail Sales Return (%c)]  Decimal(18,6)  
End  
Else If @Trans = 8  
Begin  
 Alter Table #VATReportAbs Add [Net Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Tax on Sales Return (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net Tax on Sales (%c)]  Decimal(18,6)  
 Alter Table #VATReportAbs Add [Net VAT Payable (%c)] Decimal(18,6)  
End  
  
End  
  
End  
----------------------------------------------------------------------------------------  
-- Select * from #TaxComponents  
-- SElect * from #VATReportAbs  
----------------------------------------------------------------------------------------  
-- Total Purchase amount            
update #VATReport set [Total Purchase (%c)] =  (            
 select SUM(BD.Amount)            
 from BillDetail BD, BillAbstract BA, Vendors V  
 where BA.Status = 0             
 and BA.BillDate between @FromDate and @ToDate  
 and IsNull(BA.TaxType, 1) = @TaxTypeID 
 and BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
 And BD.BillID = BA.BillID  
 and (case when BD.TaxSuffered=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end) = [Tax %]    
 and V.VendorID = BA.VendorID            
 and (    
  ([Tax Desc] = 'Exempt' and BD.TaxSuffered = 0) or     
  (    
   BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = [Tax Desc])     
     and [Tax Desc] = (Case when BD.TaxSuffered=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)    
  )    
 )    
 and [Tax Code] = BD.TaxCode  
-- and V.Locality like (case @Locality             
--    when 'Local' then '1'            
--    when 'Outstation' then '2'            
--    else '%' end)            
)            
------------------------------------------------------------------------------------  
--select * from #VATReport  
------------------------------------------------------------------------------------            
--Tax amount on Purchase            
update #VATReport set [Tax on Purchase (%c)] =  (            
 select SUM(BD.TaxAmount)            
 from BillDetail BD, BillAbstract BA, Vendors V  
 where BA.Status = 0             
  and BA.BillDate between @FromDate and @ToDate    
  and IsNull(BA.TaxType, 1) = @TaxTypeID         
  and BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
  And BD.BillID = BA.BillID         
  and convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) = [Tax %]    
  and V.VendorID = BA.VendorID            
  and BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = [Tax Desc])
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])    
  and [Tax Code] = IsNull(BD.TaxCode, 0)  
--  and V.Locality like (            
--  case @Locality             
--  when 'Local' then '1'            
--  when 'Outstation' then '2'            
--  else '%' end            
-- )            
)            
------------------------------------------------------------------------------------             
if @TaxSplitup = 'Yes'  
Begin  
-- LST Purchase Amount  
update #VATReport set [VAT Total Purchase (%c)] =  (            
 select SUM(BD.Amount)            
 from BillDetail BD, BillAbstract BA, Vendors V  
 where BA.Status = 0             
 and BA.BillDate between @FromDate and @ToDate    
 and IsNull(BA.TaxType, 1) = @TaxTypeID  
 and BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
-- And V.Locality = 1  
 and ( IsNull(BA.TaxType, 1) = 1 or IsNull(BA.TaxType, 1) = 3 )
 And BD.BillID = BA.BillID  
 and (case when BD.TaxSuffered=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end) = [Tax %]    
 and V.VendorID = BA.VendorID            
 and (    
  ([Tax Desc] = 'Exempt' and BD.TaxSuffered = 0) or     
  (    
   BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = [Tax Desc])
     and [Tax Desc] = (Case when BD.TaxSuffered=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)    
  )    
 )    
 And [Tax Desc] <> 'Exempt'  
 and [Tax Code] = BD.TaxCode  
-- and V.Locality like (case @Locality             
--    when 'Local' then '1'            
--    when 'Outstation' then '2'            
--    else '%' end)            
)  
-- VAT Tax on Purchase Amount  
update #VATReport set [VAT Tax on Purchase (%c)] =  (            
 select SUM(BD.TaxAmount)            
 from BillDetail BD, BillAbstract BA, Vendors V  
 where BA.Status = 0             
  and BA.BillDate between @FromDate and @ToDate   
  and IsNull(BA.TaxType, 1) = @TaxTypeID          
  and BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
--  And V.Locality = 1  
  and ( IsNull(BA.TaxType, 1) = 1 or IsNull(BA.TaxType, 1) = 3 )
  And BD.BillID = BA.BillID
  and convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) = [Tax %]    
  and V.VendorID = BA.VendorID            
  and BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = [Tax Desc])
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])    
  and [Tax Code] = IsNull(BD.TaxCode, 0)  
--  and V.Locality like (            
--  case @Locality             
--  when 'Local' then '1'            
--  when 'Outstation' then '2'            
--  else '%' end            
-- )            
)  
-- CST Purchase Amount  
update #VATReport set [CST Total Purchase (%c)] =  (            
 select SUM(BD.Amount)            
 from BillDetail BD, BillAbstract BA, Vendors V  
 where BA.Status = 0             
 and BA.BillDate between @FromDate and @ToDate    
 and IsNull(BA.TaxType, 1) = @TaxTypeID  
 and BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
-- And V.Locality = 2  
 and IsNull(BA.TaxType, 1) = 2
 And BD.BillID = BA.BillID  
 and (case when BD.TaxSuffered=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) end) = [Tax %]    
 and V.VendorID = BA.VendorID            
 and (    
  ([Tax Desc] = 'Exempt' and BD.TaxSuffered = 0) or     
  (    
   BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = [Tax Desc])
     and [Tax Desc] = (Case when BD.TaxSuffered=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)    
  )    
 )    
 And [Tax Desc] <> 'Exempt'  
 and [Tax Code] = BD.TaxCode  
-- and V.Locality like (case @Locality             
--    when 'Local' then '1'            
--    when 'Outstation' then '2'            
--    else '%' end)            
)  
-- CST Tax on Purchase Amount  
update #VATReport set [CST Tax on Purchase (%c)] =  (            
 select SUM(BD.TaxAmount)            
 from BillDetail BD, BillAbstract BA, Vendors V  
 where BA.Status = 0             
  and BA.BillDate between @FromDate and @ToDate            
  and IsNull(BA.TaxType, 1) = @TaxTypeID 
  and BD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)           
--  And V.Locality = 2  
  and IsNull(BA.TaxType, 1) = 2
  And BD.BillID = BA.BillID         
  and convert(nvarchar,convert(decimal(18,6),BD.TaxSuffered)) = [Tax %]    
  and V.VendorID = BA.VendorID            
  and BD.TaxSuffered = (select case isNull(BA.TaxType,1) when 2 then Tax.CST_Percentage else Tax.Percentage end from tax where tax_description = [Tax Desc])
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])    
  and [Tax Code] = IsNull(BD.TaxCode, 0)  
--  and V.Locality like (            
--  case @Locality             
--  when 'Local' then '1'            
--  when 'Outstation' then '2'            
--  else '%' end            
-- )            
)  
  
End  
------------------------------------------------------------------------------------  
--Total Purchase Return amount            
update #VATReport set [Total Purchase Return (%c)] = (            
 select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))    
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V , Batch_Products bp  
 where (isnull(ARA.Status,0) & 128) = 0            
  and ARA.AdjustmentDate between @FromDate and @ToDate            
  and ARD.BatchCode = bp.Batch_Code 
  and IsNull(bp.TaxType, 1) =  @TaxTypeID 
  and ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
  And ARA.AdjustmentID = ARD.AdjustmentID            
  and (Case when ARD.Tax=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end) = [Tax %]    
  and V.VendorID = ARA.VendorID            
  and (    
  ([Tax Desc] = 'Exempt' and ARD.Tax = 0) or     
  (    
   ARD.Tax = (case when IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)     
     and [Tax Desc] = (Case when ARD.Tax=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)    
  )    
 )    
--  and V.Locality like (            
--  case @Locality             
--  when 'Local' then '1'            
--  when 'Outstation' then '2'            
--  else '%' end            
-- )            
            
)            
  
--Tax amount on Purchase Return            
update #VATReport set [Tax on Purchase Return (%c)] = (            
 select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))    
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V , Batch_Products bp  
 where (isnull(ARA.Status,0) & 128) = 0            
  and ARA.AdjustmentDate between @FromDate and @ToDate            
  and ARD.BatchCode = bp.Batch_Code 
  and IsNull(bp.TaxType, 1) =  @TaxTypeID 
  and ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd) 
  And ARA.AdjustmentID = ARD.AdjustmentID            
  and convert(nvarchar,convert(decimal(18,6),ARD.Tax)) = [Tax %]    
  and ARA.VendorID = V.VendorID            
  and ARD.Tax = (case when IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)     
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])    
--  and cast(V.Locality as nvarchar) like (case @Locality             
--  when 'Local' then '1'             
--  when 'Outstation' then '2'             
--  else '%' end) + '%'            
)  
------------------------------------------------------------------------------------  
if @TaxSplitup = 'Yes'  
Begin  
-- VAT Purchase Return Amount  
update #VATReport set [VAT Total Purchase Return (%c)] = (            
 select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))    
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V  , Batch_Products bp  
 where (isnull(ARA.Status,0) & 128) = 0            
  and ARA.AdjustmentDate between @FromDate and @ToDate            
  and ARD.BatchCode = bp.Batch_Code 
  and IsNull(bp.TaxType, 1) =  @TaxTypeID 
  and ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
--  And V.Locality = 1
  and ( IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3 )
  And ARA.AdjustmentID = ARD.AdjustmentID            
  and (Case when ARD.Tax=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end) = [Tax %]    
  and V.VendorID = ARA.VendorID            
  and (    
  ([Tax Desc] = 'Exempt' and ARD.Tax = 0) or     
  (    
   ARD.Tax = (case when IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)     
     and [Tax Desc] = (Case when ARD.Tax=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)    
  )    
 )    
  And [Tax Desc] <> 'Exempt'  
--  and V.Locality like (            
--  case @Locality             
--  when 'Local' then '1'            
--  when 'Outstation' then '2'            
--  else '%' end            
-- )  
)  
-- VAT Tax on Purchase Return Amount  
update #VATReport set [VAT Tax on Purchase Return (%c)] = (            
 select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))    
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V  , Batch_Products bp  
 where (isnull(ARA.Status,0) & 128) = 0            
  and ARA.AdjustmentDate between @FromDate and @ToDate            
  and ARD.BatchCode = bp.Batch_Code 
  and IsNull(bp.TaxType, 1) =  @TaxTypeID 
  and ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)            
--  And V.Locality = 1
  and ( IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3 )
  And ARA.AdjustmentID = ARD.AdjustmentID            
  and convert(nvarchar,convert(decimal(18,6),ARD.Tax)) = [Tax %]    
  and ARA.VendorID = V.VendorID            
  and ARD.Tax = (case when IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)     
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])    
--  and cast(V.Locality as nvarchar) like (case @Locality             
--  when 'Local' then '1'             
--  when 'Outstation' then '2'             
--  else '%' end) + '%'            
)  
  
-- CST Purchase Return Amount  
update #VATReport set [CST Total Purchase Return (%c)] = (            
 select sum(ARD.Total_Value) - sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))    
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V  , Batch_Products bp  
 where (isnull(ARA.Status,0) & 128) = 0            
  and ARA.AdjustmentDate between @FromDate and @ToDate            
  and ARD.BatchCode = bp.Batch_Code 
  and IsNull(bp.TaxType, 1) =  @TaxTypeID 
  and ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
--  And V.Locality = 2
  and IsNull(bp.TaxType, 1) = 2
  And ARA.AdjustmentID = ARD.AdjustmentID            
  and (Case when ARD.Tax=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),ARD.Tax)) end) = [Tax %]    
  and V.VendorID = ARA.VendorID            
  and (    
  ([Tax Desc] = 'Exempt' and ARD.Tax = 0) or     
  (    
   ARD.Tax = (case when IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)     
     and [Tax Desc] = (Case when ARD.Tax=0 then 'Exempt' else (select Tax_Description from Tax where Tax_Description = [Tax Desc]) end)    
  )    
 )    
  And [Tax Desc] <> 'Exempt'  
--  and V.Locality like (            
--  case @Locality             
--  when 'Local' then '1'            
--  when 'Outstation' then '2'            
--  else '%' end            
-- )            
)  
-- CST Tax on Purchase Return Amount  
update #VATReport set [CST Tax on Purchase Return (%c)] = (            
 select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate))    
 from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V  , Batch_Products bp  
 where (isnull(ARA.Status,0) & 128) = 0            
  and ARA.AdjustmentDate between @FromDate and @ToDate            
  and ARD.BatchCode = bp.Batch_Code 
  and IsNull(bp.TaxType, 1) =  @TaxTypeID 
  and ARD.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)            
--  And V.Locality = 2
  and IsNull(bp.TaxType, 1) = 2
  And ARA.AdjustmentID = ARD.AdjustmentID            
  and convert(nvarchar,convert(decimal(18,6),ARD.Tax)) = [Tax %]    
  and ARA.VendorID = V.VendorID            
  and ARD.Tax = (case when IsNull(bp.TaxType, 1) = 1 or IsNull(bp.TaxType, 1) = 3 then (select Tax.Percentage from tax where tax_description = [Tax Desc]) else (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]) end)     
  and [Tax Desc] = (select Tax_Description from Tax where Tax_Description = [Tax Desc])    
--  and cast(V.Locality as nvarchar) like (case @Locality             
--  when 'Local' then '1'             
--  when 'Outstation' then '2'             
--  else '%' end) + '%'            
)  
  
End  
------------------------------------------------------------------------------------  
update #VATReport set [Net Purchase (%c)] = isnull([Total Purchase (%c)],0) - isnull([Total Purchase Return (%c)],0)  
update #VATReport set [Net Purchase Tax (%c)] = isnull([Tax on Purchase (%c)],0) - isnull([Tax on Purchase Return (%c)],0)  
------------------------------------------------------------------------------------  
-- select * from #VATReport  
------------------------------------------------------------------------------------  
--Total sales amount            
update #VATReport set [Total Sales (%c)] = (            
            
select sum(IDt.Amount) - sum(case #I.[taxtype] 
when 'LST' then isnull(IDt.STPayable,0)            
when 'CST' then isnull(IDT.CSTPayable,0)            
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)    
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, #InvoiceTaxType #I
where (IA.Status & 192) = 0            
and IA.InvoiceType in (1, 3)            
and IDt.SalePrice <> 0            
--and IA.InvoiceDate between @FromDate and @ToDate            
--and IsNull(C.Locality, 1) = @TaxTypeID
and #I.InvoiceId = Ia.InvoiceId
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
And Idt.InvoiceID = IA.InvoiceID            
and [Tax %] = (case when #I.[taxtype] = 'LST' then    
     (case when IDt.TaxCode=0 then 'Exempt'     
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)    
else     
     (case when IDt.TaxCode2=0 then 'Exempt'     
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)     
    End)    
and [Tax Code] = IsNull(IDt.TaxID, 0)  
and IA.CustomerID = C.CustomerID            
and (( #I.[taxtype] = 'LST' and ([Tax Desc] = 'Exempt' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or    
 ( #I.[taxtype] = 'CST' and ([Tax Desc] = 'Exempt' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))    
and [Tax Desc] = (Case [Tax Desc] when 'Exempt' then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end)    
--and cast(C.Locality as nvarchar) like (case @Locality             
--when 'Local' then '1'             
--when 'Outstation' then '2'             
--else '%' end) + '%'            
)            
            
--Tax on sales            
Update #VATReport set [Tax on Sales (%c)] = (            
select sum(case #I.[taxtype] 
when 'LST' then isnull(IDt.STPayable,0)            
when 'CST' then isnull(IDT.CSTPayable,0)            
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)             
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, #InvoiceTaxType #I
where (IA.Status & 192) = 0            
and IA.InvoiceType in (1, 3)            
and IDt.SalePrice <> 0            
--and IA.InvoiceDate between @FromDate and @ToDate            
--and IsNull(C.Locality, 1) = @TaxTypeID
and #I.InvoiceId = Ia.InvoiceId 
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
And Idt.InvoiceID = IA.InvoiceID            
and [Tax %] = (case #I.[taxtype] when 'LST' then    
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode))     
      else     
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2))     
    End)    
and [Tax Code] = IsNull(IDt.TaxID, 0)  
and IA.CustomerID = C.CustomerID            
and ((#I.[taxtype] = 'LST' and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or    
 (#I.[taxtype] = 'CST' and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))    
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc])    
--and cast(C.Locality as nvarchar) like (case @Locality             
-- when 'Local' then '1'             
-- when 'Outstation' then '2'             
-- else '%' end) + '%'            
)            
            
-- Update Total Retail Sales             
update #VATReport set  [Total Retail Sales (%c)] = (            
select sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0))    
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID            
Left Outer Join Customer C On IA.CustomerID = C.CustomerID            
Inner Join  #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
where (IA.Status & 192) = 0            
and IA.InvoiceType in (2)            
and IDt.SalePrice <> 0            
--and IA.InvoiceDate between @FromDate and @ToDate          
--and IsNull(C.Locality, 1) = @TaxTypeID
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and (case when IDt.TaxCode=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end) = [Tax %]    
--and cast(C.Locality as nvarchar) like (case @Locality
--             when 'Local' then '1'
--             when 'Outstation' then '2'
--             else '%' end) + '%'
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
Inner Join Tax On IDt.TaxCode = Tax.Percentage     
Inner Join #InvoiceTaxType #I On  #I.InvoiceId = Ia.InvoiceId and #I.[taxtype] = 'LST'
where (IA.Status & 192) = 0            
and IA.InvoiceType in (2)            
and IDt.SalePrice <> 0            
--and IA.InvoiceDate between @FromDate and @ToDate            
--and IsNull(C.Locality, 1) = @TaxTypeID

and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  

and convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) = [Tax %]    

--and cast(C.Locality as nvarchar) like (case @Locality
--             when 'Local' then '1'
--             when 'Outstation' then '2'
--             else '%' end) + '%'

and Tax.Tax_Description = [Tax Desc]    
and [Tax Code] = IsNull(IDt.TaxID, 0)  
and IDt.Amount>-1    
)    

--Total Sales return saleable amount            
update #VATReport set [Sales Return Saleable (%c)] = (            
select sum(isnull(IDt.Amount, 0)) - sum(case #I.[taxtype]
when 'LST' then isnull(IDt.STPayable,0)            
when 'CST' then isnull(IDT.CSTPayable,0)            
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)    
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, #InvoiceTaxType #I
where (IA.Status & 192) = 0             
 and (IA.Status & 32) = 0    
 and IA.InvoiceType = 4             
 and IDt.SalePrice <> 0            
-- and IA.InvoiceDate between @FromDate and @ToDate  
-- and IsNull(C.Locality, 1) = @TaxTypeID
 and #I.InvoiceId = Ia.InvoiceId
 and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
 And Idt.InvoiceID = IA.InvoiceID            
 and [Tax %] = (case #I.taxtype when 'LST' then    
     (case when IDt.TaxCode=0 then 'Exempt'     
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)    
      else     
     (case when IDt.TaxCode2=0 then 'Exempt'     
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)     
    End)    
 and [Tax Code] = IsNull(IDt.TaxID, 0)  
 and IA.CustomerID = C.CustomerID            
 and ((#I.taxtype = 'LST' and ([Tax Desc] = 'Exempt' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or    
 (#I.taxtype = 'CST' and ([Tax Desc] = 'Exempt' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))    
 and [Tax Desc] = (Case [Tax Desc] when 'Exempt' then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end)    
-- and cast(C.Locality as nvarchar) like (case @Locality             
--     when 'Local' then '1'             
--     when 'Outstation' then '2'             
--     else '%' end) + '%'            
)            
            
--tax amount on sales return saleable            
update #VATReport set [Tax on Sales Return Saleable (%c)] = (            
select sum(case #I.[taxtype]
when 'LST' then isnull(IDt.STPayable,0)            
when 'CST' then isnull(IDT.CSTPayable,0)            
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)             
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, #InvoiceTaxType #I
where (IA.Status & 192) = 0             
and (IA.Status & 32) = 0             
and IA.InvoiceType = 4             
and IDt.SalePrice <> 0            
--and IA.InvoiceDate between @FromDate and @ToDate            
--and IsNull(C.Locality, 1) = @TaxTypeID
and #I.InvoiceId = Ia.InvoiceId
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
And Idt.InvoiceID = IA.InvoiceID            
and [Tax %] = (case #I.[taxtype] when 'LST' then    
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode))    
      else     
     convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2))    
    End)    
and [Tax Code] = IsNull(IDt.TaxID, 0)  
and IA.CustomerID = C.CustomerID            
and ((#I.[taxtype] = 'LST' and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or    
 ( #I.[taxtype] = 'CST' and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))    
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc])    
--and cast(C.Locality as nvarchar) like (case @Locality             
--     when 'Local' then '1'             
--     when 'Outstation' then '2'             
--     else '%' end) + '%'            
)            
            
--total Sales Return Damages            
update #VATReport set [Sales Return Damages (%c)] = (            
select sum(IDt.Amount)  - sum(case #I.[taxtype] 
when 'LST' then isnull(IDt.STPayable,0)            
when 'CST' then isnull(IDT.CSTPayable,0)            
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)    
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, #InvoiceTaxType #I
where (IA.Status & 192) = 0             
and (IA.Status & 32) <> 0             
and IA.InvoiceType = 4             
and IDt.SalePrice <> 0            
--and IA.InvoiceDate between @FromDate and @ToDate 
--and IsNull(C.Locality, 1) = @TaxTypeID
and #I.InvoiceId = Ia.InvoiceId
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
And Idt.InvoiceID = IA.InvoiceID   
and [Tax %] = (case #I.[taxtype] when 'LST' then    
     (case when IDt.TaxCode=0 then 'Exempt'     
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)    
      else     
     (case when IDt.TaxCode2=0 then 'Exempt'     
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)     
    End)    
and [Tax Code] = IsNull(IDt.TaxID, 0)  
and IA.CustomerID = C.CustomerID            
and (( #I.[taxtype] = 'LST' and ([Tax Desc] = 'Exempt' or IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc]))) or    
 ( #I.[taxtype] = 'CST' and ([Tax Desc] = 'Exempt' or IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc]))))    
and [Tax Desc] = (Case [Tax Desc] when 'Exempt' then 'Exempt' else (select Tax.Tax_Description from tax where tax_description = [Tax Desc]) end)    
--and cast(C.Locality as nvarchar) like (case @Locality             
--     when 'Local' then '1'             
--     when 'Outstation' then '2'             
--     else '%' end) + '%'            
)            

--Tax amount on sales return damages            
update #VATReport set [Tax on Sales Return Damages (%c)] = (            
select sum(case #I.[taxtype] 
when 'LST' then isnull(IDt.STPayable,0)            
when 'CST' then isnull(IDT.CSTPayable,0)            
else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end)             
from InvoiceAbstract IA, InvoiceDetail IDt, Customer C, #InvoiceTaxType #I
where (IA.Status & 192) = 0             
and (IA.Status & 32) <> 0             
and IA.InvoiceType = 4             
and IDt.SalePrice <> 0            
--and IA.InvoiceDate between @FromDate and @ToDate            
--and IsNull(C.Locality, 1) = @TaxTypeID
and #I.InvoiceId = Ia.InvoiceId
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
And Idt.InvoiceID = IA.InvoiceID            
and [Tax %] = (case #I.[taxtype] when 'LST' then    
     (case when IDt.TaxCode=0 then 'Exempt'     
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) End)    
      else     
     (case when IDt.TaxCode2=0 then 'Exempt'     
     else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode2)) End)     
    End)    
and [Tax Code] = IsNull(IDt.TaxID, 0)  
and IA.CustomerID = C.CustomerID            
and (( #I.[taxtype] = 'LST' and IDt.TaxCode  = (Select Tax.Percentage from Tax where Tax_Description = [Tax Desc])) or    
 ( #I.[taxtype] = 'CST' and IDt.TaxCode2 = (select Tax.CST_Percentage from tax where tax_description = [Tax Desc])))    
and [Tax Desc] = (select Tax.Tax_Description from tax where tax_description = [Tax Desc])    
--and cast(C.Locality as nvarchar) like (case @Locality             
--     when 'Local' then '1'             
--     when 'Outstation' then '2'             
--     else '%' end) + '%'            
)            
-- Update Total Retail Sales Return    
update #VATReport set  [Total Retail Sales Return (%c)] = (            
select abs(sum(isnull(IDt.Amount,0)) - sum(isnull(IDt.STPayable,0)))    
from InvoiceAbstract IA
Inner Join InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID            
Left Outer Join Customer C On IA.CustomerID = C.CustomerID            
Inner Join #InvoiceTaxType #I On #I.InvoiceId = Ia.InvoiceId
where (IA.Status & 192) = 0            
and IA.InvoiceType in (5,6)            
and IDt.SalePrice <> 0            
--and IA.InvoiceDate between @FromDate and @ToDate          
--and IsNull(C.Locality, 1) = @TaxTypeID
and IDt.Product_Code In (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and (case when IDt.TaxCode=0 then 'Exempt' else convert(nvarchar,convert(decimal(18,6),IDt.TaxCode)) end) = [Tax %]    
--and (Case @Locality When 'Outstation' Then 0 Else 1 End) = 1    
and IDt.TaxCode = (case when IDt.TaxCode=0 then 0 else (select Tax.Percentage from tax where Tax_Description = [Tax Desc]) end)    
and [Tax Desc] = (case when IDt.TaxCode=0 then 'Exempt' else (select Tax.Tax_Description from tax where Tax_Description = [Tax Desc]) end)    
and [Tax Code] = IsNull(IDt.TaxID, 0)  
--and IDt.Amount<0    
)    
-- Update Tax Retail Sales Return    
update #VATReport set [Tax on Retail Sales Return (%c)] = (            
select abs(sum(isnull(IDt.STPayable,0)))    
from InvoiceAbstract IA
Inner Join  InvoiceDetail IDt On Idt.InvoiceID = IA.InvoiceID            
Left Outer Join Customer C On IA.CustomerID = C.CustomerID            
Inner Join  Tax On  IDt.TaxCode = Tax.Percentage     
where (IA.Status & 192) = 0            
and IA.InvoiceType in (5,6)            
and IDt.SalePrice <> 0            
and IA.InvoiceDate between @FromDate and @ToDate  
and IsNull(C.Locality, 1) = @TaxTypeID
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
  
Update #VATReport set [VAT Total Purchase (%c)] = (case [VAT Total Purchase (%c)] when 0 then null else [VAT Total Purchase (%c)] end)            
Update #VATReport set [VAT Tax on Purchase (%c)] = (case [VAT Tax on Purchase (%c)] when 0 then null else [VAT Tax on Purchase (%c)] end)    
Update #VATReport set [CST Total Purchase (%c)] = (case [CST Total Purchase (%c)] when 0 then null else [CST Total Purchase (%c)] end)            
Update #VATReport set [CST Tax on Purchase (%c)] = (case [CST Tax on Purchase (%c)] when 0 then null else [CST Tax on Purchase (%c)] end)    
  
Update #VATReport set [Total Purchase Return (%c)] = (case [Total Purchase Return (%c)] when 0 then null else [Total Purchase Return (%c)] end)            
Update #VATReport set [Tax on Purchase Return (%c)] = (case [Tax on Purchase Return (%c)] when 0 then null else [Tax on Purchase Return (%c)] end)            
  
Update #VATReport set [VAT Total Purchase Return (%c)] = (case [VAT Total Purchase Return (%c)] when 0 then null else [VAT Total Purchase Return (%c)] end)            
Update #VATReport set [VAT Tax on Purchase Return (%c)] = (case [VAT Tax on Purchase Return (%c)] when 0 then null else [VAT Tax on Purchase Return (%c)] end)            
Update #VATReport set [CST Total Purchase Return (%c)] = (case [CST Total Purchase Return (%c)] when 0 then null else [CST Total Purchase Return (%c)] end)            
Update #VATReport set [CST Tax on Purchase Return (%c)] = (case [CST Tax on Purchase Return (%c)] when 0 then null else [CST Tax on Purchase Return (%c)] end)            
  
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
  
select [Tax Code],[Temp Tax Desc], [Tax Desc], [Tax %],   
[Total Purchase (%c)] = Sum(IsNull([Total Purchase (%c)], 0)),            
[Tax on Purchase (%c)] = Sum(IsNull([Tax on Purchase (%c)], 0)),   
  
[VAT Total Purchase (%c)] = Sum(IsNull([VAT Total Purchase (%c)], 0)),            
[VAT Tax on Purchase (%c)] = Sum(IsNull([VAT Tax on Purchase (%c)], 0)),   
[CST Total Purchase (%c)] = Sum(IsNull([CST Total Purchase (%c)], 0)),            
[CST Tax on Purchase (%c)] = Sum(IsNull([CST Tax on Purchase (%c)], 0)),   
  
[Total Purchase Return (%c)] = Sum(IsNull([Total Purchase Return (%c)], 0)),   
[Tax on Purchase Return (%c)] = Sum(IsNull([Tax on Purchase Return (%c)], 0)),  
  
[VAT Total Purchase Return (%c)] = Sum(IsNull([VAT Total Purchase Return (%c)], 0)),   
[VAT Tax on Purchase Return (%c)] = Sum(IsNull([VAT Tax on Purchase Return (%c)], 0)),  
[CST Total Purchase Return (%c)] = Sum(IsNull([CST Total Purchase Return (%c)], 0)),   
[CST Tax on Purchase Return (%c)] = Sum(IsNull([CST Tax on Purchase Return (%c)], 0)),  
  
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
[Net VAT Payable (%c)] = Sum(IsNull([Net VAT Payable (%c)], 0)) InTo #ResultVatReport  
From (  
select [Tax Code] = Case [Tax Desc] When 'Exempt' Then 0 Else [Tax Code] End,  
[Temp Tax Desc] = Case [Tax Desc] When 'Exempt' Then   
Convert(nVarChar, 0) + char(15) + Convert(nVarChar, 0) + char(15) + 'Exempt' Else   
[Temp Tax Desc] End  
, [Tax Desc], [Tax %],  
[Total Purchase (%c)] = Sum(IsNull([Total Purchase (%c)], 0)),            
[Tax on Purchase (%c)] = Sum(IsNull([Tax on Purchase (%c)], 0)),   
  
[VAT Total Purchase (%c)] = Sum(IsNull([VAT Total Purchase (%c)], 0)),            
[VAT Tax on Purchase (%c)] = Sum(IsNull([VAT Tax on Purchase (%c)], 0)),   
[CST Total Purchase (%c)] = Sum(IsNull([CST Total Purchase (%c)], 0)),            
[CST Tax on Purchase (%c)] = Sum(IsNull([CST Tax on Purchase (%c)], 0)),   
  
[Total Purchase Return (%c)] = Sum(IsNull([Total Purchase Return (%c)], 0)),   
[Tax on Purchase Return (%c)] = Sum(IsNull([Tax on Purchase Return (%c)], 0)),  
  
[VAT Total Purchase Return (%c)] = Sum(IsNull([VAT Total Purchase Return (%c)], 0)),   
[VAT Tax on Purchase Return (%c)] = Sum(IsNull([VAT Tax on Purchase Return (%c)], 0)),  
[CST Total Purchase Return (%c)] = Sum(IsNull([CST Total Purchase Return (%c)], 0)),   
[CST Tax on Purchase Return (%c)] = Sum(IsNull([CST Tax on Purchase Return (%c)], 0)),  
  
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
From #VATReport  Group By [Tax Code],[Temp Tax Desc], [Tax Desc], [Tax %]  
) vtr  
Group By [Tax Code],[Temp Tax Desc], [Tax Desc], [Tax %]  
  
----------------------------------------------------------------------------------------  
--Select * from #ResultVatReport  

If @TaxSplitup <> 'Yes'  
 Begin  
Set @SqlStat = 'Insert Into #VATReportAbs (  
[Tax Code],[Temp Tax Desc], [Tax Desc], [Tax %],  
[Total Purchase (%c)],[Tax on Purchase (%c)],  
[Total Purchase Return (%c)],[Tax on Purchase Return (%c)],  
[Net Purchase (%c)],[Net Purchase Tax (%c)],[Total Sales (%c)],[Tax on Sales (%c)],  
[Total Retail Sales (%c)],[Tax on Retail Sales (%c)],  
[Sales Return Saleable (%c)],[Tax on Sales Return Saleable (%c)],  
[Sales Return Damages (%c)],[Tax on Sales Return Damages (%c)],  
[Total Retail Sales Return (%c)],[Tax on Retail Sales Return (%c)],  
[Net Sales Return (%c)],[Net Tax on Sales Return (%c)],[Net Sales (%c)],[Net Tax on Sales (%c)],[Net VAT Payable (%c)])  
Select [Tax Code],[Temp Tax Desc], [Tax Desc], [Tax %],  
[Total Purchase (%c)],[Tax on Purchase (%c)],  
[Total Purchase Return (%c)],[Tax on Purchase Return (%c)],  
[Net Purchase (%c)],[Net Purchase Tax (%c)],[Total Sales (%c)],[Tax on Sales (%c)],  
[Total Retail Sales (%c)],[Tax on Retail Sales (%c)],  
[Sales Return Saleable (%c)],[Tax on Sales Return Saleable (%c)],  
[Sales Return Damages (%c)],[Tax on Sales Return Damages (%c)],  
[Total Retail Sales Return (%c)],[Tax on Retail Sales Return (%c)],  
[Net Sales Return (%c)],[Net Tax on Sales Return (%c)],[Net Sales (%c)],[Net Tax on Sales (%c)],[Net VAT Payable (%c)]   
From #ResultVatReport'  
Exec SP_ExecuteSQL @SqlStat  
End  
----------------------------------------------------------------------------------------  
If @TaxSplitup = 'Yes'  
 Begin  
  
Set @SqlStat =   
'Insert Into #VATReportAbs (  
[Tax Code],[Temp Tax Desc], [Tax Desc], [Tax %],  
[Total Purchase (%c)],[Tax on Purchase (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 1)  
 Set @SqlStat = @SqlStat + '[VAT Total Purchase (%c)],[VAT Tax on Purchase (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 0)  
 Set @SqlStat = @SqlStat + '[CST Total Purchase (%c)],[CST Tax on Purchase (%c)],'  
Set @SqlStat = @SqlStat + '[Total Purchase Return (%c)],[Tax on Purchase Return (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 1)  
 Set @SqlStat = @SqlStat + '[VAT Total Purchase Return (%c)],[VAT Tax on Purchase Return (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 0)  
 Set @SqlStat = @SqlStat + '[CST Total Purchase Return (%c)],[CST Tax on Purchase Return (%c)],'  
Set @SqlStat = @SqlStat + '[Net Purchase (%c)],[Net Purchase Tax (%c)],[Total Sales (%c)],[Tax on Sales (%c)],  
[Total Retail Sales (%c)],[Tax on Retail Sales (%c)],  
[Sales Return Saleable (%c)],[Tax on Sales Return Saleable (%c)],  
[Sales Return Damages (%c)],[Tax on Sales Return Damages (%c)],  
[Total Retail Sales Return (%c)],[Tax on Retail Sales Return (%c)],  
[Net Sales Return (%c)],[Net Tax on Sales Return (%c)],[Net Sales (%c)],[Net Tax on Sales (%c)],[Net VAT Payable (%c)])  
Select [Tax Code],[Temp Tax Desc], [Tax Desc], [Tax %],  
[Total Purchase (%c)],[Tax on Purchase (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 1)  
 Set @SqlStat = @SqlStat + '[VAT Total Purchase (%c)],[VAT Tax on Purchase (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 1 And LST = 0)  
 Set @SqlStat = @SqlStat + '[CST Total Purchase (%c)],[CST Tax on Purchase (%c)],'  
Set @SqlStat = @SqlStat + '[Total Purchase Return (%c)],[Tax on Purchase Return (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 1)  
 Set @SqlStat = @SqlStat + '[VAT Total Purchase Return (%c)],[VAT Tax on Purchase Return (%c)],'  
if Exists (Select LST from #TaxComponents Where Trans = 2 And LST = 0)  
 Set @SqlStat = @SqlStat + '[CST Total Purchase Return (%c)],[CST Tax on Purchase Return (%c)],'  
Set @SqlStat = @SqlStat + '[Net Purchase (%c)],[Net Purchase Tax (%c)],[Total Sales (%c)],[Tax on Sales (%c)],  
[Total Retail Sales (%c)],[Tax on Retail Sales (%c)],  
[Sales Return Saleable (%c)],[Tax on Sales Return Saleable (%c)],  
[Sales Return Damages (%c)],[Tax on Sales Return Damages (%c)],  
[Total Retail Sales Return (%c)],[Tax on Retail Sales Return (%c)],  
[Net Sales Return (%c)],[Net Tax on Sales Return (%c)],[Net Sales (%c)],[Net Tax on Sales (%c)],[Net VAT Payable (%c)]   
From #ResultVatReport'  
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
Set @SQLStat = 'Update #VatReportAbs Set '+  Left(@ColName,CharIndex(Char(15),@ColName)-1)  + ' = ' + Cast(@TaxPercentage AS NVArChar)  
+' Where [Tax Code] = ' + Cast(@TaxID as nVArChar)  
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
Set @SQLStat = 'Update #VatReportAbs Set '+  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))  + ' = (IsNull([VAT Tax on Purchase (%c)],0) * ' + Cast(@TaxPercentage AS nVArChar)  
+'/' + Cast(@TaxSuffered as nVarChar) + ') Where [Tax Code] = ' + Cast(@TaxID as nVArChar) + ' And [Tax Desc] <> ''Exempt'''  
Else IF @LST = 0  
Set @SQLStat = 'Update #VatReportAbs Set '+  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))  + ' = (IsNull([CST Tax on Purchase (%c)],0) * ' + Cast(@TaxPercentage AS nVArChar)  
+'/' + Cast(@TaxSuffered as nVarChar) + ') Where [Tax Code] = ' + Cast(@TaxID as nVArChar) + ' And [Tax Desc] <> ''Exempt'''  
If @Trans = 2  
If @LST = 1  
Set @SQLStat = 'Update #VatReportAbs Set '+  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))  + ' = (IsNull([VAT Tax on Purchase Return (%c)],0) * ' + Cast(@TaxPercentage AS nVArChar)  
+'/' + Cast(@TaxSuffered as nVarChar) + ') Where [Tax Code] = ' + Cast(@TaxID as nVArChar) + ' And [Tax Desc] <> ''Exempt'''  
Else If @LST = 0  
Set @SQLStat = 'Update #VatReportAbs Set '+  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))  + ' = (IsNull([CST Tax on Purchase Return (%c)],0) * ' + Cast(@TaxPercentage AS nVArChar)  
+'/' + Cast(@TaxSuffered as nVarChar) + ') Where [Tax Code] = ' + Cast(@TaxID as nVArChar) + ' And [Tax Desc] <> ''Exempt'''  
  
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
  
Set @SQLStat = 'Update #VatReportAbs Set ' +  Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName)))    
+ ' = IsNull(' + Right(@ColName,(Len(LTrim(@ColName))-CharIndex(Char(15),@ColName))) + ',0) + ' +  
' (Select Sum(ITC.Tax_Value)   
From InvoiceAbstract IA,  
(Select Distinct InvoiceDetail.InvoiceID , InvoiceDetail.Product_Code , TaxID from InvoiceDetail, #InvoiceTaxType #I
Where ' + (Case @LST When 0 then 'InvoiceDetail.TaxCode2' Else 'InvoiceDetail.TaxCode' End) + ' <> 0 And InvoiceDetail.SalePrice <> 0 And InvoiceDetail.Product_Code in (select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
and InvoiceDetail.InvoiceId = #I.InvoiceId
) IDT , Customer C , InvoiceTaxComponents ITC Where IA.Status & 192 = 0 '+  
(Case @Trans When 5 Then ' And (IA.Status & 32) = 0 ' When 6 Then ' And (IA.Status & 32) <> 0 ' Else '' End) +  
' And IA.InvoiceType in ' + (Case @Trans When 3 Then '(1,3)' When 5 Then '(4)' When 6 Then '(4)' When 4 Then '(2)' When 7 Then '(5,6)' End) + '  
 And IA.InvoiceDate Between '''+ Cast(@FromDate as nVarChar)+ ''' and ''' + Cast(@ToDate as nVarChar)  
+''' And ITC.Tax_Code = ' + Cast(@TaxID as nVarChar)  
+' And ITC.Tax_Component_Code = ' + Cast(@CompID as nVarChar)  
+' And IA.InvoiceID = IDT.InvoiceID   
And ITC.InvoiceID = IA.InvoiceID   
And ITC.Product_Code = IDT.Product_Code   
And ITC.Tax_Code = IDT.TaxID  
And IA.CustomerID '+ (Case When @Trans in (4,7) Then '*'Else '' End) +'= C.CustomerID '  +
--'and cast(C.Locality as nvarchar) like (case '''+ @Locality +  
--''' when ''Local'' then ''1''   
--when ''Outstation'' then ''2''   
--else ''%'' end) + ''%''
' ) Where [Tax Code] = ' + Cast(@TaxID as nVarChar)  
Exec SP_ExecuteSQL @SqlStat  

Fetch Next From TaxCompColl InTo @Trans, @TaxID, @CompID, @LST, @Pos, @ColName ,@TaxPercentage  
End  
  
Close TaxCompColl  
DeAllocate TaxCompColl  
  
 End  
----------------------------------------------------------------------------------------  
Set @SqlStat = 'Alter Table #VatReportAbs DROP COLUMN [Tax Code]'  
  
Exec SP_ExecuteSQL @SqlStat  
  
Select * from #VatReportAbs  
  
--Drop Table #TaxComponents   
Drop Table #ResultVatReport  
Drop Table #VatReportAbs  
Drop table #VATReport            
Drop table #tmpProd  

end  
  --GSTOut:
