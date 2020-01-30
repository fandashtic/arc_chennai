create Procedure sp_get_serviceinvoicedetail_print_TaxInvoice(@Serviceid int)
As
BEGIn
Create table #tmpFinal(
Sr int identity(1,1),[SACName] nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,Amount decimal(10,2),
[CGST%] decimal(10,2),
[SGST%] decimal(10,2),
[IGST%] decimal(10,2),
[CGSTAmt] decimal(10,2),
[SGSTAmt] decimal(10,2),
[IGSTAmt] decimal(10,2),
--[TaxableVal] decimal(10,2),
[Tax_Amount] decimal(10,2),
Net_Amount decimal(10,2)
)
insert into #tmpFinal
--Select Substring(SM.ServiceAccountCode+' & '+ SM.ServiceName,0,25) as [SACName],
Select (SM.ServiceAccountCode+' & '+ Substring(SD.Remarks,1,50)) as [SACName],
SD.Amount,
isnull(dbo.fn_GetServiceInvoiceTaxSplit(SA.invoiceid,SD.ServiceNameAndCode,SD.SerialNo,'SGST','Per'),0) as [SGST%],
isnull(dbo.fn_GetServiceInvoiceTaxSplit(SA.invoiceid,SD.ServiceNameAndCode,SD.SerialNo,'SGST','Amt'),0) as [SGSTAmt],
isnull(dbo.fn_GetServiceInvoiceTaxSplit(SA.invoiceid,SD.ServiceNameAndCode,SD.SerialNo,'CGST','Per'),0) as [CGST%],
isnull(dbo.fn_GetServiceInvoiceTaxSplit(SA.invoiceid,SD.ServiceNameAndCode,SD.SerialNo,'CGST','Amt'),0) as [CGSTAmt],
isnull(dbo.fn_GetServiceInvoiceTaxSplit(SA.invoiceid,SD.ServiceNameAndCode,SD.SerialNo,'IGST','Per'),0) as [IGST%],
isnull(dbo.fn_GetServiceInvoiceTaxSplit(SA.invoiceid,SD.ServiceNameAndCode,SD.SerialNo,'IGST','Amt'),0) as [IGSTAmt],
--SD.Amount as TaxableVal,
SD.Tax_Amount,
SD.Net_Amount
from  ServiceAbstract SA
Join ServiceDetails SD on SD.Invoiceid=SA.invoiceid
Join ServiceTypeMaster SM on SM.Code=SD.serviceCodeid
where SA.ServiceInvoiceNo= @Serviceid

Select * From #tmpFinal

Drop Table #tmpFinal

END
