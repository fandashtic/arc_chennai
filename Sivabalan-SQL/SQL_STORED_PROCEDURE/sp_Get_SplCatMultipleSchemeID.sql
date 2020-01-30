CREATE Procedure sp_Get_SplCatMultipleSchemeID (@InvoiceID int,@ItemCode Nvarchar(30),@Serial Int)    
as    
Begin   
Select Type,SchemeType,Cost/Free as Cost from SchemeSale   
Inner Join Schemes On SchemeSale.Type = Schemes.SchemeID  
Where Isnull(SpecialCategory,0)= 1 And InvoiceID = @InvoiceID   
And Product_Code = @ItemCode And Isnull(Serial,0) = @Serial  
End
