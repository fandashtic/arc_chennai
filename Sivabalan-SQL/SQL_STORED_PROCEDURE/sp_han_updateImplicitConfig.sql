
CREATE Procedure sp_han_updateImplicitConfig              
(@InProgress int)           
As              
 Update ImplicitConfig  Set InProgress=@InProgress   
 Select "Rows" =  @@ROWCOUNT  
