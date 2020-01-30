Create PROCEDURE sp_ser_cancelinvoicecollection(@InvoiceID int)
as 
Declare @CollectionID as int , @retVal Int 

Select @CollectionID = isnull(Paymentdetails, 0) from ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceID 

If isnull(@CollectionID,0) > 0 
begin
	update collections set status = (isnull(status,0) | 192), Balance = 0 
	where collections.documentid = @collectionid and (isnull(collections.status,0) & 192) = 0
	set @retVal = @@RowCount

	exec SP_Ser_Cancel_ServiceCollections @CollectionID
		
	if exists(Select ReferenceID From Service_AdjustmentReference Where ServiceInvoiceID = @InvoiceID)  
	begin  
		Update DebitNote Set Status = (isnull(status,0) | 192), Balance = 0  
			Where DebitID In (Select ReferenceID From Service_AdjustmentReference  
				Where ServiceInvoiceID = @InvoiceID And DocumentType = 5)     
		Update CreditNote Set Status = (isnull(status,0) | 192), Balance = 0  
			Where CreditID In (Select ReferenceID From Service_AdjustmentReference  
				Where ServiceInvoiceID = @InvoiceID And DocumentType = 2)  
		Update Service_AdjustmentReference Set Status = (isnull(status,0) | 128) 
				Where ServiceInvoiceID = @InvoiceID 
	end  
end

Select isnull(@CollectionID,0), @retVal
/*   
	Colletion will be updated with status 192, if Any Collection is raised
*/

