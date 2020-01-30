CREATE procedure Sp_get_AdjustedDocValue(@InvoiceId int,@customerid nvarchar(30))
as
begin
	Declare @PaymentDetails nvarchar(100)
	select @PaymentDetails = paymentdetails from invoiceabstract where invoiceid = @InvoiceId
	create table #TempPaymentDetails (PaymentId int)
	insert into #TempPaymentDetails select *  from dbo.sp_splitin2rows(@PaymentDetails,',') 

	select collectiondetail.AdjustedAmount,DocumentType,collectiondetail.DocumentID, 
	CollectionDetail.OriginalID,
    collectiondetail.DocumentDate , collectiondetail.DocumentValue 
    from retailpaymentdetails, collectiondetail,invoiceabstract,#TempPaymentDetails where 
    retailpaymentdetails.collectionID = collectiondetail.CollectionID and 
    retailpaymentdetails.retailinvoiceID = invoiceabstract.invoiceid and 
    collectiondetail.collectionID =  #TempPaymentDetails.PaymentId and 
	collectiondetail.DocumentType in( 2, 3,7, 9) and 
    invoiceabstract.customerid = @customerid 
	drop table #TempPaymentDetails
end


