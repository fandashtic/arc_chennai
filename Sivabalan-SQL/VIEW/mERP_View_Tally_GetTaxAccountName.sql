CREATE View [dbo].[mERP_View_Tally_GetTaxAccountName]  
as 
select  case when td.TallyDesc <> '' then td.TallyDesc else tm.Tax_Description end as Name,
case when td.TallyDesc <> '' then td.TallyDesc else tm.Tax_Description end as AdditionalName,'Duties & Taxes'  as
Parent,case when isnull(Percentage,0) = 0 then
'Sales - Zero Rated' else case when Percentage in (select Percentage from Tax)
then dbo.mERP_FN_Tally_GetTaxAccountName(tm.Tax_Description)
else '' end end as TaxClassificationName,case when Percentage in
(select Percentage from Tax)  then 'GST' else '' end  as TaxType,case when
Percentage in (select Percentage from Tax)  then 'On GST Rate' else '' end  as BasicTypeOfDuty, tm.CreationDate as CreationDate,'Integrated Tax' as GSTDUTYHEAD,CST_Percentage 
as RATEOFTAXCALCULATION,
Tax_Description as GSTCLASSIFICATIONNAME ,'No' as ISUPDATINGTARGETID ,'Yes' as ASORIGINAL,case when Active=1 then 'Yes' else 'No' end as ISACTIVE,
case when tm.GSTFlag=1 then 'No' else 'Yes' end as ISNONGSTGOODS,'1000' as SORTPOSITION ,'6028'  as  ALTERID,
'Taxable' as TAXABILITY,'Not Applicable' as GSTNATUREOFTRANSACTION,'No' as ISREVERSECHARGEAPPLICABLE,'No' as ISNONGSTGOODS_Detail,
'No' as GSTINELIGIBLEITC,case when TaxComponent_desc='CGST' then 'Central Tax' END AS GSTRATEDUTYHEAD_CENTRAL,
case when TaxComponent_desc='SGST' then 'State Tax'  END AS GSTRATEDUTYHEAD_STATE,
case when TaxComponent_desc='IGST' then 'Integrated Tax'  END AS GSTRATEDUTYHEAD_INTEGRATED,
case when TaxComponent_desc='CESS' then 'Cess' end as GSTRATEDUTYHEAD_CESS,
case when TaxComponent_desc='ADDL CESS' then 'Cess on Qty' end as GSTRATEDUTYHEAD_ADDLCESS ,
(select top 1 sc.StateName  from setup s inner join statecode sc
on s.BillingStateID=sc.StateID) as STATENAME,
case when tc.Componenttype=1 then 'Based on Value'
else 'Based on Quantity' end as GSTRATEVALUATIONTYPE,cast(Tax_percentage as decimal(18,4)) as GSTRATE,
case when TaxComponent_desc='CGST' then 1
when   TaxComponent_desc='SGST' then 2
when  TaxComponent_desc='IGST' then 3
when  TaxComponent_desc='CESS' then 4
when  TaxComponent_desc='ADDL CESS' then 5 end as DescOrder,tm.EffectiveFrom as APPLICABLEFROM,tdc.TaxComponent_desc as LEDGERNAME,tdc.TaxComponent_code
from tax tm,taxcomponents tc,taxcomponentdetail tdc,TallyTaxDetails td
-- from tax tminner join taxcomponents tc on tm.tax_code =tc.tax_code
--inner join taxcomponentdetail tdc on tdc.TaxComponent_code=tc.TaxComponent_code,TallyTaxDetails td

where  tm.Tax_Description <> ''  And td.Taxtype = 'Output' And tm.Tax_Description = td.ForumDesc

and tm.tax_code=tc.Tax_Code and tc.TaxComponent_code=tdc.TaxComponent_code  and tm.GSTFlag=1

union
select  case when td.TallyDesc <> '' then td.TallyDesc else tm.Tax_Description end as Name,case when td.TallyDesc <> '' then td.TallyDesc else tm.Tax_Description end as AdditionalName,'Duties & Taxes'  as Parent





,case when isnull(Percentage,0) = 0 then
'Sales - Zero Rated' else case when Percentage in (
select Percentage from Tax)   then dbo.mERP_FN_Tally_GetTaxAccountName_Input(tm.Tax_Description)
else '' end end as TaxClassificationName,case when Percentage in (select Percentage from Tax)  then 'GST' else '' end  as TaxType,case when
Percentage in (select Percentage from Tax)  then 'On GST Rate' else '' end  as BasicTypeOfDuty,tm.CreationDate as CreationDate,'Integrated Tax' as GSTDUTYHEAD,
CST_Percentage as RATEOFTAXCALCULATION,
Tax_Description as GSTCLASSIFICATIONNAME ,'No' as ISUPDATINGTARGETID ,'Yes' as ASORIGINAL,case when Active=1 then 'Yes' else 'No' end as ISACTIVE,
case when tm.GSTFlag=1 then 'No' else 'Yes' end as ISNONGSTGOODS,'1000' as SORTPOSITION ,'6028'  as  ALTERID,
'Taxable' as TAXABILITY,'Not Applicable' as GSTNATUREOFTRANSACTION,'No' as ISREVERSECHARGEAPPLICABLE,'No' as ISNONGSTGOODS_Detail,
'No' as GSTINELIGIBLEITC,case when TaxComponent_desc='CGST' then 'Central Tax' END AS GSTRATEDUTYHEAD_CENTRAL,
case when TaxComponent_desc='SGST' then 'State Tax'  END AS GSTRATEDUTYHEAD_STATE,
case when TaxComponent_desc='IGST' then 'Integrated Tax'  END AS GSTRATEDUTYHEAD_INTEGRATED,
case when TaxComponent_desc='CESS' then 'Cess' end as GSTRATEDUTYHEAD_CESS,
case when TaxComponent_desc='ADDL CESS' then 'Cess on Qty' end as GSTRATEDUTYHEAD_ADDLCESS,
(select top 1 sc.StateName  from setup s inner join statecode sc
on s.BillingStateID=sc.StateID) as STATENAME,
case when tc.Componenttype=1 then 'Based on Value'
else 'Based on Quantity' end as GSTRATEVALUATIONTYPE,cast(Tax_percentage as decimal(18,4)) as GSTRATE,
case when TaxComponent_desc='CGST' then 1
when   TaxComponent_desc='SGST' then 2
when  TaxComponent_desc='IGST' then 3
when  TaxComponent_desc='CESS' then 4
when  TaxComponent_desc='ADDL CESS' then 5 end as DescOrder,
tm.EffectiveFrom as APPLICABLEFROM,tdc.TaxComponent_desc as LEDGERNAME,tdc.TaxComponent_code
from tax tm,taxcomponents tc
,taxcomponentdetail tdc,TallyTaxDetails td
where  tm.Tax_Description <> ''  And td.Taxtype = 'Input'  And tm.Tax_Description = td.ForumDesc
and tm.tax_code=tc.Tax_Code and tc.TaxComponent_code=tdc.TaxComponent_code
and tm.GSTFlag=1
