create Procedure sp_get_serviceinvoicedetail_print_BillInvoice(@Serviceid int)
As
BEGIn
Create table #tmpFinal(
Sr int identity(1,1),
[SAC] nvarchar(255),
[SACName] nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,
Amount decimal(10,2),
Net_Amount decimal(10,2)
)
insert into #tmpFinal
Select SM.ServiceAccountCode,Substring(SD.Remarks,1,50) as ServiceName,
SD.Amount,
SD.Net_Amount
from  ServiceAbstract SA
Join ServiceDetails SD on SD.Invoiceid=SA.invoiceid
Join ServiceTypeMaster SM on SM.Code=SD.serviceCodeid
where SA.ServiceInvoiceNo= @Serviceid

Select * From #tmpFinal

Drop Table #tmpFinal

END
