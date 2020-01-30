CREATE PROCEDURE [dbo].[Sp_Tally_Purchase_Return_GetTaxWiseComponent]  
(
  @AdjustmentId int
)
As
Begin
Select --ITC.Tax_Component_Code  , 
case when TCD.TaxComponent_desc ='ADDL CESS' then 'CESS' 
when TCD.TaxComponent_desc ='UTGST' then 'SGST' 
else TCD.TaxComponent_desc end as  TaxComponent_desc , --cast(itc.Tax_Percentage as decimal(18,4)) as Tax_Percentage ,
cast( Sum(itc.Tax_Value) as decimal(18,4))as NetAmt
into #tmpData
From prtaxcomponents ITC Join TaxComponentDetail TCD On TCD.TaxComponent_code  = ITC.Tax_Component_Code
Where AdjustmentID = @AdjustmentId
Group By TCD.TaxComponent_desc --, itc.Tax_Percentage,ITC.Tax_Component_Code , 

select TaxComponent_desc,sum(NetAmt) as NetAmt from #tmpData group by TaxComponent_desc
End
