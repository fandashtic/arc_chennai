CREATE procedure sp_ser_customerdetail(@CustomerID as nVarchar(15))  
as   
Select IsNull(BillingAddress,'') BillingAddress, IsNull(ShippingAddress,'') ShippingAddress, 
IsNull(Discount,0) Discount, PayMent_Mode, IsNull(CreditTerm, 0) CreditTerm from Customer   
where CustomerID = @CustomerID   



