CREATE Function sp_Invoice_Implicit_Explicit_Collections (@InvoiceID nvarchar(255))
Returns Int
As
begin
declare @Invoice_Type nvarchar(10)
declare @Invoice_ID int
declare @final_value int
declare @collect_count int
-- retriving the invoice type
Select @Invoice_Type =  Isnull(PaymentDetails,0) 
			from InvoiceAbstract 
			where InvoiceID = @InvoiceID
--  if the payment detail is not null, then the collection for invoice is checked
If @Invoice_Type <> 0 
begin
	set @final_value = 0
	DECLARE explicit_collections CURSOR FOR     
	Select count(*), CollectionDetail.DocumentID from Collectiondetail, Collections
	where Collections.DocumentID <> @Invoice_Type 
	And CollectionDetail.DocumentID = @InvoiceID 
	And Collections.DocumentID = CollectionDetail.CollectionID 
	And IsNull(Collections.Status,0) & 128 = 0 
	And CollectionDetail.DocumentType in (1, 4) 
	And Collections.CustomerID IS Not Null
	group by CollectionDetail.DocumentID
	
	OPEN explicit_collections
	FETCH FROM explicit_collections INTO @collect_count, @Invoice_ID
	If @collect_count > 0
	begin		
		set @final_value = 1
	end
	Close explicit_collections
	DeAllocate explicit_collections
end
-- if the payment detail is null, then whether the collection for invoice is checked
-- if made the return value is '1' else '0'
else
begin
    Select @Invoice_ID = CollectionDetail.DocumentID 
	from CollectionDetail, Collections
	where CollectionDetail.DocumentID = @InvoiceID 
	And Collections.DocumentID = CollectionDetail.CollectionID 
	And IsNull(Collections.Status,0) & 128 = 0 
	And CollectionDetail.DocumentType in (1, 4) 
	And Collections.CustomerID IS Not Null
    
	Set @Invoice_ID = Isnull(@Invoice_ID ,0)
    If @Invoice_ID = 0
    begin
        set @final_value = 0
    end
    else
    begin	    
	set @final_value = 1
    end
end
return @final_value
end



