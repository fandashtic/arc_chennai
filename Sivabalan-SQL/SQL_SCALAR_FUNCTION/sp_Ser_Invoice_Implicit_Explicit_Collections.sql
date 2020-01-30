Create Function sp_Ser_Invoice_Implicit_Explicit_Collections (@InvoiceID nvarchar(255))
Returns Int
As
Begin
Declare @Invoice_Type nvarchar(10)
Declare @Invoice_ID int
Declare @final_value int
Declare @collect_count int
-- retriving the invoice type
Select @Invoice_Type =  Isnull(PaymentDetails,0) 
			From ServiceInvoiceAbstract 
			Where ServiceInvoiceID = @InvoiceID
--  if the payment detail is not null, then the collection for invoice is checked
If @Invoice_Type <> 0 
Begin
	Set @final_value = 0
	Declare explicit_collections CURSOR FOR     
	Select count(*), CollectionDetail.DocumentID 
	From Collectiondetail, Collections
	Where Collections.DocumentID <> @Invoice_Type 
	And CollectionDetail.DocumentID = @InvoiceID 
	And Collections.DocumentID = CollectionDetail.CollectionID 
	And IsNull(Collections.Status,0) & 128 = 0 
	And CollectionDetail.DocumentType in (12) 
	And Collections.CustomerID Is Not Null
	group by CollectionDetail.DocumentID
	
	OPEN explicit_collections
	FETCH From explicit_collections INTO @collect_count, @Invoice_ID
	If @collect_count > 0
	Begin		
		Set @final_value = 1
	End
	Close explicit_collections
	DeAllocate explicit_collections
End
-- if the payment detail is null, then whether the collection for invoice is checked
-- if made the return value is '1' else '0'
Else
Begin
	Select @Invoice_ID = CollectionDetail.DocumentID 
	From CollectionDetail, Collections
	Where CollectionDetail.DocumentID = @InvoiceID 
	And Collections.DocumentID = CollectionDetail.CollectionID 
	And IsNull(Collections.Status,0) & 128 = 0 
	And CollectionDetail.DocumentType in (12) 
	And Collections.CustomerID Is Not Null
    
	Set @Invoice_ID = Isnull(@Invoice_ID ,0)
	If @Invoice_ID = 0
	Begin
		Set @final_value = 0
	End
	Else
	Begin	    
		Set @final_value = 1
	End
End
Return @final_value
End

