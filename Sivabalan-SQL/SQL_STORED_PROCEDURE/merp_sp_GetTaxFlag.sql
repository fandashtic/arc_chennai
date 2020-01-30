Create Procedure merp_sp_GetTaxFlag(@InvoiceId as int, @Mode as int)  
As  
Declare @TaxDiscountFlag int  
  
If IsNull(@Mode,0) = 1  
Begin  
 Select @TaxDiscountFlag = IsNull(TaxDiscountFlag,0) from InvoiceAbstract where InvoiceID = @InvoiceId  
 Select @TaxDiscountFlag   
End  
Else if IsNull(@Mode,0) = 2  
Begin  
 Select @TaxDiscountFlag = IsNull(TaxDiscountFlag,0) from BillAbstract where BillID = @InvoiceId  
 Select @TaxDiscountFlag   
End  
