CREATE procedure [dbo].[spr_ser_list_Invoicewise_Collection_Detail](@InvID nvarchar(25))    
As    

Declare @TYPE int
Declare @InvoiceID Int
Declare @ParamSep nvarchar(10)
Declare @ParamSepcounter Int
Declare @TempString nVarchar(20)

Set @ParamSep = Char(2)                
Set @TempString = @InvID

Set @ParamSepcounter = CHARINDEX(@ParamSep,@TempString,1)   
set @InvoiceID = Substring(@TempString, 1, @ParamSepcounter-1)
                    
Set @TempString = Substring(@TempString, @ParamSepcounter + 1, len(@InvID))             
set @Type = Cast(@TempString as int)

If @Type = 1 

	Begin 

	Select Collections.DocumentID, "Collection ID" = Collections.FullDocID, "Document Ref" =   
	DocReference, "Date" = Collections.DocumentDate, "Salesman" = Salesman.Salesman_Name,    
	"Value" = CollectionDetail.AdjustedAmount, "Payment Mode" = Case PaymentMode   
	When 0 Then 'Cash'    
	When 1 Then 'Cheque'    
	When 2 Then 'DD'    
	When 3 Then 'Credit Card'    
	When 4 Then 'Bank Transfer'    	   
	When 5 Then 'Coupon'     
	When 6 Then 'Credit Note'
	When 7 Then 'Gift Voucher'
	End    
	From Collections, CollectionDetail, Salesman    
	Where Collections.DocumentID = CollectionDetail.CollectionID And    
	Collections.SalesmanID *= Salesman.SalesmanID And   
	IsNull(Collections.Status, 0) & 128 = 0 And    
	CollectionDetail.DocumentID = @InvoiceID And    
	CollectionDetail.DocumentType In (1, 2, 4, 6, 7) And     
	Collections.CustomerID Is Not Null      
	
	End 

Else

	Begin

	Select Collections.DocumentID, "Collection ID" = Collections.FullDocID, "Document Ref" =   
	DocReference, "Date" = Collections.DocumentDate, "Salesman" = Salesman.Salesman_Name,    
	"Value" = CollectionDetail.AdjustedAmount, "Payment Mode" = Case PaymentMode   
	When 0 Then 'Cash'    
	When 1 Then 'Cheque'    
	When 2 Then 'DD'    
	When 3 Then 'Credit Card'    
	When 4 Then 'Bank Transfer'    	   
	When 5 Then 'Coupon'     
	When 6 Then 'Credit Note'
	When 7 Then 'Gift Voucher'
	End    
	From Collections, CollectionDetail, Salesman    
	Where Collections.DocumentID = CollectionDetail.CollectionID And    
	Collections.SalesmanID *= Salesman.SalesmanID And   
	IsNull(Collections.Status, 0) & 128 = 0 And    
	CollectionDetail.DocumentID = @InvoiceID And    
	CollectionDetail.DocumentType = 12 And     
	Collections.CustomerID Is Not Null      

	End
