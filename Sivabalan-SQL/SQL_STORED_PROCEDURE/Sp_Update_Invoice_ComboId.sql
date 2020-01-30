CREATE Procedure Sp_Update_Invoice_ComboId   
 @INVOICE_ID int,   
 @Combo_Pack_Code nvarchar(20)  
As  
 Declare @COMBO_ID Int  
  
 Select @COMBO_ID = Max(ComboId)   
 From InvoiceDetail  
 Where  InvoiceID = @Invoice_ID and   
   Product_Code = @Combo_Pack_Code and  
   isnull(ComboID,0) > 0  
   
    SET @COMBO_ID = Isnull(@COMBO_ID,0) + 1  
  
 Update InvoiceDetail Set ComboId = @COMBO_ID   
 Where  InvoiceID = @Invoice_ID and   
   Product_Code = @Combo_Pack_Code and  
   isnull(ComboID,0) = 0  
  
 SELECT @COMBO_ID  

