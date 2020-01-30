CREATE procedure sp_ser_InvoicePrefix
as

Select 
(select Prefix from VoucherPrefix where [TranID]= 'SERVICEINVOICE') 'SINVOICE',
(select Prefix from VoucherPrefix where [TranID]= 'ISSUESPARES') 'ISSUE', 
(select Prefix from VoucherPrefix where [TranID]= 'COLLECTIONS') 'COLLECTION', 
(select Prefix from VoucherPrefix where [TranID]= 'JOBCARD') 'JOBCARD', 
(select Prefix from VoucherPrefix where [TranID]= 'JOBESTIMATION') 'JOBESTIMATION'


