
Create Function fn_GetWriteOff(@CollectionID int)  
Returns Decimal(18,6)   
As   
Begin  
 Declare @InvProportion as Decimal(18,6)  
 Declare @ColProportion as Decimal(18,6)  
  
 Select @InvProportion=(Sum(InvD.Amount)/Max(InvA.NetValue)) From InvoiceAbstract InvA, InvoiceDetail InvD   
 Where Inva.InvoiceID in (Select DocumentID From CollectionDetail Where CollectionID = @CollectionID   
 And DocumentType = 4) And InvA.Balance = 0 And InvA.InvoiceID=InvD.InvoiceID  
  
 Select @ColProportion = (Case Sum(Cld.Adjustment) When 0 Then Sum(Cld.Adjustment)   
 Else (Sum(Cld.Adjustment) - Sum((Cld.Discount/100) * Cld.DocumentValue)) End)   
 From CollectionDetail Cld Where Cld.CollectionID=@CollectionID And Cld.DocumentType=4  
  
 Return (Select IsNull((@InvProportion * @ColProportion),0))    
End  

