CREATE PROCEDURE [dbo].[Sp_Tally_Bill_GetTaxWiseComponent]  
(
  @BillId int
)
As
Begin
Select --ITC.Tax_Component_Code  ,
case when TCD.TaxComponent_desc ='ADDL CESS' then 'CESS' 
when TCD.TaxComponent_desc ='UTGST' then 'SGST'

else TCD.TaxComponent_desc end as  TaxComponent_desc , 
cast(Sum(itc.Tax_Value
)as decimal(18,4))as NetAmt --cast(itc.Tax_Percentage as decimal(18,4)) as Tax_Percentage  ,
into #tmpData
From GstBillTaxComponents ITC Join TaxComponentDetail TCD On TCD.TaxComponent_code  = ITC.Tax_Component_Code
Where BillID = @BillId
Group By  TCD.TaxComponent_desc --, itc.Tax_Percentage  ,ITC.Tax_Component_Code ,

select TaxComponent_desc,sum(NetAmt) as NetAmt from #tmpData group by TaxComponent_desc
End
