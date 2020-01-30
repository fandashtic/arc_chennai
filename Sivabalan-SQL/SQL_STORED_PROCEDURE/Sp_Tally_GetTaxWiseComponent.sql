CREATE PROCEDURE [dbo].[Sp_Tally_GetTaxWiseComponent]  
(
  @invoiceId int
)
As
Begin
Select --ITC.Tax_Component_Code  , 
case when TCD.TaxComponent_desc ='ADDL CESS' then 'CESS' 
when TCD.TaxComponent_desc ='UTGST' then 'SGST' else TCD.TaxComponent_desc
 end as  TaxComponent_desc ,cast( Sum(itc.NetTaxAmount)as decimal(18,4)) as NetAmt--cast(itc.Tax_Percentage as decimal(18,4)) as Tax_Percentage
into #tmpData
From GSTInvoiceTaxComponents ITC Join TaxComponentDetail TCD On TCD.TaxComponent_code  = ITC.Tax_Component_Code
Where InvoiceId = @invoiceId
Group By TCD.TaxComponent_desc --, itc.Tax_Percentage

select TaxComponent_desc,sum(NetAmt) as NetAmt from #tmpData group by TaxComponent_desc
End
