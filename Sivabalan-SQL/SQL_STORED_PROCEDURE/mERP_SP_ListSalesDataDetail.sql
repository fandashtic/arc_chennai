Create Procedure mERP_SP_ListSalesDataDetail(@ID nvarchar(50))
As
Declare @SCHEME_TYPE int
Declare @Type int
Declare @SchDescription nvarchar(250)
Declare @DocumentID int
Declare @DocumentType nvarchar(20)
Declare @Pos1 int
Declare @Length int

Begin
Set @Pos1 = CharIndex(N';', @ID, 1)
Set @DocumentID = cast(SubString(@ID, 1, @Pos1 - 1) as int)
Set @DocumentType = Cast(SubString(@ID,@Pos1+1,Len(@ID)) as nvarchar)

Create table #TmpSaleDetail
(
Type nvarchar(25),
ID int,
pcode nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
pname nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
Bcode int,
Batch_Number nvarchar(100)COLLATE SQL_Latin1_General_CP1_CI_AS,
Serial int,
BaseUom nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
BUOM_Quantity decimal(18,6),
SalePrice decimal(18,6),
SaleTax nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
PurTax nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
TaxValue decimal(18,6),
Volume decimal(18,6),
PTR decimal(18,6),
PTS decimal(18,6),
MRP decimal(18,6),
Bill_UOM nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
Bill_Quantity decimal(18,6),
Free_Type nvarchar(50),
Ref_ItemSeqNo nvarchar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
SchSeqNo nvarchar(4000)COLLATE SQL_Latin1_General_CP1_CI_AS,
Comp_ActivityCode nvarchar(4000)COLLATE SQL_Latin1_General_CP1_CI_AS,
Scheme_Desc nvarchar(4000)COLLATE SQL_Latin1_General_CP1_CI_AS,
DiscPerc nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
DiscountValue decimal(18,6),
SchemePerc nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS,
SchemeValue decimal(18,6),
Netvalue decimal(18,6),
GrossValue decimal(18,6),
TotDiscValue decimal(18,6),
IsCompany int,
OrderBaseUOM nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
OrderBaseUOMQTY decimal(18,6),
OrderUOM nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
OrderQTY decimal(18,6)
--, PurTaxVal Decimal(18,6)
--, PurTaxType nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS
, TaxCode int
)

If @DocumentType=N'Order'
Begin

insert into #TmpSaleDetail
select "Type"='NonScheme',
"ID"  = SD.SONumber,
"pcode" = I.Product_Code,
"pname" = productname,
"BCode" = '',
"Batch_Number" = SD.Batch_Number,
"Serial" = SD.Serial,
"BaseUom" = U.Description,
"BUOM_Quantity" = SD.Quantity,
"SalePrice" = (Case When I.UOM1=SD.UOM then (SD.SalePrice) * Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2=SD.UOM then (SD.SalePrice) * Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion
End  Else SD.SalePrice end),
--"SaleTax" =  CAST(Round((SD.SaleTax+SD.TaxCode2), 2) AS nVARCHAR) + '%',
"SaleTax" =  CAST((SD.SaleTax+SD.TaxCode2) AS nVARCHAR),
--"PurTax" = CAST(ISNULL((SD.TaxSuffered), 0) AS nVARCHAR) + '%',
"PurTax" = CAST(ISNULL((SD.TaxSuffered), 0) AS nVARCHAR),
--"TaxValue" =(SD.quantity * SD.Saleprice) * (SD.SaleTax /100) ,
"TaxValue" = Case Isnull(SD.TAXONQTY,0) When 0 then ((((SD.Quantity * SD.SalePrice) - ((SD.Quantity * SD.SalePrice) * SD.Discount / 100))
*(IsNull(SD.TaxSuffered,0) + Isnull(SD.SaleTax,0) + Isnull(SD.TaxCode2,0))/100)) Else SD.Quantity * (IsNull(SD.TaxSuffered,0) + Isnull(SD.SaleTax,0) + Isnull(SD.TaxCode2,0)) End ,
/*"Volume" = (Case When I.UOM1=SD.UOM then dbo.sp_Get_ReportingQty(SD.Quantity, Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End)  When I.UOM2=SD.UOM  then dbo.sp_Get_ReportingQty(SD.Quantity, Case When IsNull(I.UOM2_Conversion,
0) = 0 Then 1 Else I.UOM2_Conversion End)  Else SD.Quantity  End),*/
"Volume" =  Isnull(SD.Quantity,0) * IsNull(I.COnversiOnFactOr,0),
--"PTR" = case when SD.Batch_Number = '' then I.PTR else (select Max(PTR) from Batch_products where Product_code=I.product_code and Batch_number=SD.Batch_number) end,
--"PTS" = case when SD.Batch_Number = '' then I.PTS else (select Max(PTS) from Batch_products where Product_code=I.product_code and Batch_number=SD.Batch_number) end,
"PTR" = I.PTR,
"PTS" = I.PTS,
-- "MRP" = I.MRP,
--"MRP" = isnull(I.MRPPerPack,0),
"MRP" = isnull(SD.MRPPerPack,0),

"Bill_UOM" = '', --(Select Description From UOM Where UOM = SD.UOM),
-- --"Bill_Quantity" = SD.UOMQty,
"Bill_Quantity" = 0, -- (Case When I.UOM1 = SD.UOM then (SD.Quantity)/Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2 = SD.UOM then (SD.Quantity)/Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1
--  Else I.UOM2_Conversion
-- End  Else SD.Quantity  End),

"Free_Type" = '',
"Ref_ItemSeqNo" = '',
"SchSeqNo" = 0,
"Comp_ActivityCode" = 0,
"Scheme_Desc" = '',
--"DiscPerc" = CAST(Round(SD.Discount, 2) AS nVARCHAR) + '%',
"DiscPerc" = CAST(Round(SD.Discount, 2) AS nVARCHAR),
"DiscountValue" = (SD.Quantity * SD.SalePrice) * (SD.Discount / 100),
--"SchemePerc" = CAST(Round(cast(0 as decimal), 2) AS nVARCHAR) + '%',
"SchemePerc" = CAST(Round(cast(0 as decimal), 2) AS nVARCHAR),
"SchemeValue" = 0,
"Netvalue" =  Case Isnull(SD.TAXONQTY,0) When 0 then (SD.Quantity * SD.SalePrice) - ((SD.Quantity * SD.SalePrice) * SD.Discount / 100) + ((SD.Quantity * SD.SalePrice) * (IsNull(SD.TaxSuffered,0) + Isnull(SD.SaleTax,0) + Isnull(SD.TaxCode2,0))/100) Else
(SD.Quantity * SD.SalePrice) - ((SD.Quantity * SD.SalePrice) * SD.Discount / 100) + (SD.Quantity  * (IsNull(SD.TaxSuffered,0) + Isnull(SD.SaleTax,0) + Isnull(SD.TaxCode2,0))) End ,
-- - (SD.Quantity * SD.SalePrice) - ((SD.Quantity * SD.SalePrice) * SD.Discount / 100)
"GrossValue"= (SD.Quantity * SD.saleprice),
"TotDiscValue" = 0,
"IsCompany" = 0,
U.Description,
SD.Quantity,
(Select Description From UOM Where UOM = SD.UOM),
(Case When I.UOM1 = SD.UOM then (SD.Quantity)/Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2 = SD.UOM then (SD.Quantity)/Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End  Else SD.
Quantity  End)
--,0,''
, isnull(SD.GSTCSTaxCode,0)
from SODetail SD,Items I ,UOM U
where SD.SONumber in (@DocumentID)
and I.product_code=SD.product_code
and I.UOM=U.UOM
End
Else
Begin

--Select ID.*,"BP_PTS"=IsNull(BP.PTS,0),"BP_TOQ"=BP.TOQ,"BP_PurTax"=IsNull(BP.TaxSuffered,0),"BP_TaxType" = IsNull(TT.TaxType ,'')
--Into #tmpInvoicedetail From Invoicedetail ID
--Left Join Batch_products BP On Bp.Batch_Code = ID.Batch_Code
--Left Join tbl_mERP_Taxtype TT On TT.TaxID = BP.TaxType
--Where ID.Invoiceid=@DocumentID

Insert into #TmpSaleDetail
select case when ID.Flagword=0 then 'NonScheme' else 'Scheme' end,
"ID"  = ID.Invoiceid,
"pcode" = ID.Product_Code,
"pname" = productname,
"BCode" = Batch_Code,
"Batch_Number" = Batch_Number,
"Serial" = serial,
"BaseUom" = U.Description,
"BUOM_Quantity" = ID.Quantity,
"SalePrice" = (  Case When I.UOM1=ID.UOM then (ID.SalePrice) * Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2=ID.UOM then (ID.SalePrice) * Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion
End  Else (ID.SalePrice)  End),
--"SaleTax" =  CAST(Round((ID.TaxCode+ID.TaxCode2), 2) AS nVARCHAR) + '%',
"SaleTax" =  CAST((ID.TaxCode+ID.TaxCode2) AS nVARCHAR),
--"PurTax" = CAST(ISNULL((ID.TaxSuffered), 0) AS nVARCHAR) + '%',
"PurTax" = CAST(ISNULL((ID.TaxSuffered), 0) AS nVARCHAR),
--"Tax Value" = ID.TaxAmount,
"TaxValue" = (Isnull(STPayable,0) + IsNull(CSTPayable,0)),
/* "Volume" = (Case When I.UOM1=ID.UOM then dbo.sp_Get_ReportingQty(ID.Quantity, Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End)  When I.UOM2=ID.UOM  then dbo.sp_Get_ReportingQty(ID.Quantity, Case When IsNull(I.UOM2_Conversion,
0) = 0 Then 1 Else I.UOM2_Conversion End)  Else ID.Quantity  End),*/
--"Volume" =  dbo.sp_Get_ReportingQty(ID.Quantity,I.Reportingunit),
"Volume" =  Isnull(ID.Quantity,0) * IsNull(I.COnversiOnFactOr,0),
--"PTR" = ID.PTR,
--"PTS" = ID.PTS,
--"MRP" = ID.MRP,

"PTR" = I.PTR,
"PTS" = I.PTS,
-- "MRP" = I.MRP,
--"MRP" = isnull(I.MRPPerPack,0),
"MRP" = isnull(ID.MRPPerPack,0),


"Bill_UOM" = (Select Description From UOM Where UOM = ID.UOM),
--"Bill_Quantity" = ID.UOMQty,
"Bill_Quantity" = (Case When I.UOM1 = ID.UOM then (ID.Quantity)/Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2 = ID.UOM then (ID.Quantity)/Case When IsNull(I.UOM2_Conversion, 0) =
0 Then 1 Else I.UOM2_Conversion End  Else ID.Quantity  End),

"Free_Type" = case when ID.SalePrice=0 and ID.Flagword=0 and (ID.MultipleSchemeID='' or ID.MultipleSchemeID='0') and ID.MultipleSPLCATSCHEMEID='' then
'MANUALFREE'
when ID.SalePrice=0 and ID.Flagword=1 and (ID.MultipleSchemeID<>'' or ID.MultipleSPLCATSCHEMEID <> '') Then
case when (select 1 from tbl_merp_schemeabstract where schemeID=ID.SchemeID and ApplicableOn=1) > 0 Then
'ITEMBASED'
when (select 1 from tbl_merp_schemeabstract where schemeID=ID.SchemeID and ApplicableOn=2) > 0 Then
'INVOICEBASED'
else
''
end
else
''
End,

"Ref_ItemSeqNo" = case when ID.Flagword=0 then '' when ID.Flagword=1 and ID.MultipleSchemeID='' then ID.SPLCatSerial else ID.FreeSerial end,
"SchSeqNo" =  dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSchemeid,char(44),'|'),1) + case when ID.MultipleSPLCatSchemeID='' then '' when ID.MultipleSchemeid='' or ID.MultipleSchemeid='0' or ID.MultipleSchemeid is null then dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),1) else '|'+ dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),1) end ,
"Comp_ActivityCode" = dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSchemeid,char(44),'|'),2) + case when ID.MultipleSPLCatSchemeID='' then '' when ID.MultipleSchemeid='' or ID.MultipleSchemeid='0' or ID.MultipleSchemeid is null then dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),2) else '|' + dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),2) end ,
"Scheme_Desc" = dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSchemeid,char(44),'|'),3) + case when ID.MultipleSPLCatSchemeID='' then '' when ID.MultipleSchemeid='' or ID.MultipleSchemeid='0' or ID.MultipleSchemeid is null then dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),3) else '|' + dbo.mERP_Fn_ConcateSchemeDetail(Replace(ID.MultipleSPLCATSchemeID,char(44),'|'),3) end ,
--"DiscPerc" = CAST(Round(case when (ID.DiscountPercentage - ID.SchemeDiscPercent - ID.SplCatDiscPercent) < 0 then 0 else (ID.DiscountPercentage - ID.SchemeDiscPercent - ID.SplCatDiscPercent)  end , 2) AS nVARCHAR) + '%',
"DiscPerc" = CAST((case when (ID.DiscountPercentage - ID.SchemeDiscPercent - ID.SplCatDiscPercent) < 0 then 0 else (ID.DiscountPercentage - ID.SchemeDiscPercent - ID.SplCatDiscPercent)  end) AS nVARCHAR),
--"DiscPerc" = CAST(Round((0), 2) AS nVARCHAR) + '%',
"DiscountValue" = DiscountValue - SchemeDiscAmount - SplCatDiscAmount,
--"SchemePerc" = CAST(Round((ID.SchemeDiscPercent+ID.SplCatDiscPercent), 2) AS nVARCHAR) + '%',
"SchemePerc" = CAST((ID.SchemeDiscPercent+ID.SplCatDiscPercent) AS nVARCHAR),
"SchemeValue" =  SchemeDiscAmount+SplCatDiscAmount +
Case When ID.Flagword=1 Then
isnull(ID.PTR,0) * ID.Quantity
--	Case When isnull(ID.PTR,0) = 0 Then 0
--	Else
--		IsNull((select Sum(SchemeValue) from tbl_merp_SchemeSale SS, tbl_merp_SchemeSlabDetail SD Where SS.Product_Code = ID.Product_Code
--		And SS.InvoiceID = ID.InvoiceID
--		And SS.SlabID = SD.SlabID
--		And SD.SlabType = 3 And SS.Serial = ID.Serial)
--		--+ (select((ID.Quantity * I.PTR) * (TX.Percentage / 100)) from Tax TX where TX.Tax_Code = I.Sale_Tax)
--		,0)
--	End
Else 0 End,

"Netvalue" =  ISNULL((ID.Amount), 0),
"GrossValue"= (ID.Quantity * ID.saleprice),
"TotDiscValue" = ID.DiscountValue,
--"IsCompany" = (case when (select count(*) from schemes_rec where schemename in (select schemes.schemename from schemes where SchemeID=ID.SchemeID)) > 0 then 1 else 0 end),
"IsCompany" = 1,
(select Top 1 U.description from SODetail S,UOM U,Items I where S.SONumber in (select top 1 case when IA.InvoiceType=1 then IA.SONUmber else (select Top 1 SONumber from InvoiceAbstract where DocumentID=IA.DocumentID and InvoiceType=1)
end from InvoiceAbstract IA where IA.InvoiceID=@DocumentID)
and S.Product_Code=ID.Product_Code  and U.UOM=I.UOM and I.Product_Code=S.Product_Code),

(select sum(S.Quantity) from SODetail S,UOM U,Items I where S.SONumber in (select top 1 case when IA.InvoiceType=1 then IA.SONUmber else (select Top 1 SONumber from InvoiceAbstract where DocumentID=IA.DocumentID and InvoiceType=1)
end from InvoiceAbstract IA where IA.InvoiceID=@DocumentID)
and S.Product_Code=ID.Product_Code  and U.UOM=I.UOM and I.Product_Code=S.Product_Code),

(select Top 1 U.description from SODetail S,UOM U where S.SONumber in (select top 1 case when IA.InvoiceType=1 then IA.SONUmber else (select Top 1 SONumber from InvoiceAbstract where DocumentID=IA.DocumentID and InvoiceType=1)
end from InvoiceAbstract IA where IA.InvoiceID=@DocumentID)
and S.Product_Code=ID.Product_Code and U.UOM=S.UOM),

(select SUM((Case When I.UOM1 = S.UOM then ((S.Quantity))/Case When IsNull(I.UOM1_Conversion, 0) = 0 Then 1 Else I.UOM1_Conversion End  When I.UOM2 = S.UOM then ((S.Quantity))/Case When IsNull(I.UOM2_Conversion, 0) = 0 Then 1 Else I.UOM2_Conversion End  Else
(S.Quantity)  End))
from SODetail S,Items I where S.SONumber in (select top 1 case when IA.InvoiceType=1 then IA.SONUmber else (select Top 1 SONumber from InvoiceAbstract where DocumentID=IA.DocumentID and InvoiceType=1)
end from InvoiceAbstract IA where IA.InvoiceID=@DocumentID)
and I.Product_Code=S.Product_Code and S.Product_Code=ID.Product_Code)
-- , PurTaxVal=Case IsNull(ID.BP_TOQ,0) When 0 Then ID.Quantity * BP_PTS * BP_PurTax / 100.00 Else ID.Quantity * BP_PurTax End
-- , PurTaxType=BP_TaxType
, TaxCode = isnull(ID.GSTCSTaxCode ,0)
from invoicedetail ID,Items I,UOM U where invoiceid=@DocumentID
-- from #tmpInvoicedetail ID,Items I,UOM U where invoiceid=@DocumentID
and ID.product_code=I.Product_Code
and I.UOM=U.UOM

--Drop Table #tmpInvoicedetail

End

select "Type1" = Type,"Type" = Type,
"ID" = ID,
"SysSKUCode" = pcode,
"SKUName" = pname,
"BatchCode" = Bcode,
"BatchNumber" = Batch_Number,
"ItemSeqNo" = Serial,
"BaseUOM" = Baseuom,
"BUOMQty" =BUOM_Quantity,
"Volume" = Volume,
"BillUOM" = Bill_UOM,
"BillQty" = Bill_Quantity,
"OrderBaseUOM" = CASE when Type='Scheme' then '' else OrderBaseUOM end,
"OrderBaseUOMQTY" =Case when Type='Scheme' then 0 else OrderBaseUOMQTY end,
"OrderUOM" =Case when Type='Scheme' then '' else OrderUOM end,
"OrderQTY" = Case when Type='Scheme' then 0 else OrderQTY end,
"SalePrice" = SalePrice,
"SalesTax" = SaleTax,
"PurchaseTax" = PurTax,
"GrossValue" = GrossValue,
"TotDiscValue" = TotDiscValue,
"TaxValue" = TaxValue,
"NetValue" = Netvalue,
"PTR" = PTR,
"PTS" = PTS,
--"MRP"= MRP,
"MRP Per Pack"= MRP,
"FreeType"= Free_Type,
"RefItemSeqNo" = Ref_ItemSeqNo,
"SchSeqNo" = SchSeqNo,
"Comp ActivityCode" =Comp_ActivityCode,
"Scheme Desc" = Scheme_Desc,
"Disc%" = Isnull(Discperc,0),
"DiscValue" =  DiscountValue,
"Scheme%" = Isnull(SchemePerc,0),
"SchemeValue" = SchemeValue,
"ISCompany" = IsCompany
--,"PurTaxVal" = PurTaxVal,"PurTaxType"=PurTaxType
,"TaxCode" = TaxCode
--"Status" = 0
from #TmpSaleDetail
order by type,pcode
drop table #TmpSaleDetail
End
