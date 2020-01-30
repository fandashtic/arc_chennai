Create Procedure [dbo].[sp_print_DandDInvItems_RespectiveUOM_CG_Inter](@DnDID INT,@MODE INT=0)
AS
Begin

Declare @DandDID Int

/*GST_Changes starts here*/
Create Table #tmpSnoDup1(Sno_dup1 Int Identity(1,1),id_dup1	int)
Create Table #tmpDuplicate(Duplicate Int)
Insert into #tmpDuplicate Values (1)
Insert into #tmpDuplicate Values (2)

-------------------------Temp Tax Details
--select @DandDID = DandDID  from DandDInvAbstract where DandDInvID = @DnDINVNO


Select  DandDID , Product_Code, Batch_Code,Tax_Code  ,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value  Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End),
MRPPerPack=0 Into #TempTaxDet
From DandDTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where ITC.DandDID  = @DnDID
Group By DandDID, Product_Code,Batch_Code , Tax_Code

--Temp Invoice Detail
--Select ID = ID,Batch_Code=ID.Batch_code  , TaxID=ID.TaxID , TaxableValue = ID.BatchTaxableAmount ,
--SGSTPer= (Select SGSTPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
--SGSTAmt= (Select Sum(SGSTAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code = ID.Batch_code ),
--CGSTPer=(Select CGSTPer From #TempTaxDet Where DandDID = ID.ID  And Product_Code = ID.Product_Code  And Batch_Code= ID.Batch_code ) ,
--CGSTAmt=(Select Sum(CGSTAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
--IGSTPer=(Select IGSTPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code) ,
--IGSTAmt=(Select Sum(IGSTAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
--UTGSTPer=(Select UTGSTPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
--UTGSTAmt=(Select Sum(UTGSTAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
--CESSPer=(Select CESSPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
--CESSAmt=(Select Sum(CESSAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ),
--ADDLCESSPer=(Select ADDLCESSPer From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code ) ,
--ADDLCESSAmt=(Select Sum(ADDLCESSAmt) From #TempTaxDet Where DandDID = ID.ID And Product_Code = ID.Product_Code And Batch_code= ID.Batch_code )
--into #TempInvDet2
--from DandDDetail ID
--Where ID = @DnDID
--select * from #TempInvDet2
/*GST_Changes ends here*/

Update TTD Set ttd.MRPPerPack = IsNull(BP.MRPPerPack,0) From #TempTaxDet TTD Join Batch_Products BP On BP.Batch_Code = TTD.Batch_Code

SELECT Identity(Int, 1,1) as "id1",
"SNo" = cast('' as nvarchar(25)),
"Description" = Case When Duplicate = 1 then I.ProductName Else cast( isnull(I.Product_Code,'') +'-'+ isnull(I.HSNNumber,'') as nvarchar) End,
"TaxableValue" = Case When Duplicate = 1 then cast(isnull(U.Description ,'') as nvarchar)
Else  Cast(cast(Sum(DD.BatchTaxableAmount)as Decimal(18,2)) as nvarchar)  End,

"MRP" =  Cast(Case When Duplicate = 1 then Cast((Case When #TempTaxDet.MRPPerPack = 0 Then I.MRPPerPack Else #TempTaxDet.MRPPerPack End) as Decimal(18,2))  Else  Cast(Max(IGSTPer) as decimal(18,2)) End As nVarchar),
"Sale Price" = Isnull(Case When Duplicate=1
Then Cast(cast(DD.UOMPTS As Decimal(18,2)) as nvarchar)
Else cast(Cast(Sum(#TempTaxDet.IGSTAmt ) as decimal(18,2))as nVarchar)
End,''),
"Quantity" =Isnull(cast(Case When Duplicate=1
then Cast(Sum(DD.UOMRFAQty ) as decimal(18,2)) Else Cast(Sum(DD.RFAQuantity ) as decimal(18,2))
End as nVarchar),''),

"Gross Amount" = Case When Duplicate = 1 then isnull(cast(cast(Case Sum(DD.UOMRFAQty  * DD.UOMPTS )
When 0 then	NULL
Else	cast(Cast(Sum(DD.UOMRFAQty  * DD.UOMPTS ) As decimal(18,2)) as nvarchar)
End As Decimal(18,2) )as nvarchar),'')
Else  Cast(Cast(Max(CESSPer ) as decimal(18,2))as nVarchar) End,
"Addl.CessRate" = 	Case When Duplicate = 1 then ''
Else  Cast(Cast(Max(#TempTaxDet.ADDLCESSPer )as Decimal(18,2))  as nvarchar)  End,
"Addl.CessAmt" = 	Case When Duplicate = 1 then ''
Else  Cast(Cast(Sum(#TempTaxDet.ADDLCESSAmt )as Decimal(18,2))  as nvarchar)  End,

"Salvage Value" = Isnull(cast(Case When Duplicate=1
then Cast(cast(Sum(Isnull(DD.BatchSalvageValue,0) )AS decimal(18,2)) as nvarchar)
Else Cast(Cast(sum(CESSAmt ) as decimal(18,2))as nVarchar)
End as nVarchar),0.00),

"Total Amount" = Isnull(cast(Case When Duplicate=1
then Cast(cast(Sum(DD.BatchRFAValue)as decimal(18,2)) as nvarchar)
End as nVarchar),''),

"Total Tax" = Isnull(cast(Case When Duplicate=1
then Cast(cast(Sum(DD.TaxAmount )as Decimal(18,2)) as nvarchar)
End as nVarchar),''),
Duplicate
Into
#TmpInvDet
FROM
DandDDetail DD, #TempTaxDet ,Items I, UOM U,#tmpDuplicate
WHERE DD.ID = #TempTaxDet.DandDID
AND DD.Product_Code  = I.Product_Code
AND DD.Batch_code = #TempTaxDet.Batch_Code
And DD.UOM  = U.UOM
and dd.RFAQuantity > 0
Group By I.HSNNumber, DD.Product_code, I.ProductName,#TempTaxDet.MRPPerPack,I.MRPPerPack , U.Description , DD.UOMPTS ,Duplicate,I.Product_Code
Order by I.ProductName
--Order By serial,Duplicate

insert into  #tmpSnoDup1(id_dup1) select id1 from #TmpInvDet Where Duplicate = 1
Update #TmpInvDet Set SNo = Sno_dup1 from #tmpSnoDup1,#TmpInvDet where id1 = id_dup1 and Duplicate = 1

--Update #TmpInvDet Set [SNo]='',[Item MRP]='',[Item Gross Value]='',[Quantity]='', [Sale Price]='',[Total Tax] = '' Where Duplicate = 2


IF @MODE=0
select * from #tmpInvdet Order By id1--Serial
else
select count(*) from #tmpInvdet where Duplicate = 1

Drop Table #TmpInvDet
Drop Table #tmpSnoDup1
Drop Table #TmpDuplicate
Drop Table #TempTaxDet
--Drop Table #TempInvDet2

End
