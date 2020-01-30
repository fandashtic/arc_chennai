CREATE procedure sp_insert_BillDiscount_Pidilite(@DiscDescription nVarchar(20))  
As  
If Not Exists (Select DiscountID From BillDiscountMaster Where DiscDescription=@DiscDescription) 
Begin
	Insert Into BillDiscountMaster (DiscDescription) Values (@DiscDescription)  
    Select @@IDENTITY
End  
  

