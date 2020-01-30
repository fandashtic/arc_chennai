CREATE procedure sp_update_Others_Pidilite(@InvoiceId int)    
As    
Declare @Freight Decimal(18,6)  
Declare @OctroiAmount Decimal(18,6)  
Declare @ProductDiscount  Decimal(18,6)

Select @ProductDiscount = Sum(DiscountAmount) From InvoiceDiscountReceived Where InvoiceID = @InvoiceId

Select  @Freight = Sum(Freight), @OctroiAmount = Sum(OctroiAmount) 
From InvoiceDetailReceived 
Where InvoiceID = @InvoiceId

Update InvoiceAbstractReceived Set Freight = @Freight, OctroiAmount = @OctroiAmount,  
ProductDiscount = @ProductDiscount Where InvoiceID = @InvoiceId  
    
  


