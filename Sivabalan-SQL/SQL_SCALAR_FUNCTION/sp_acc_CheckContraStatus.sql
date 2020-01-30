CREATE Function sp_acc_CheckContraStatus(@ContraSerial As INT)  
Returns Int  
As  
 Begin   
  Declare @ReturnValue As Int  
  Declare @ContraID As Int  
  
  Select @ContraID = ContraID from ContraDetail Where ContraSerialCode = @ContraSerial  
  
  Select @ReturnValue = Count(*) from ContraAbstract  
  Where ContraID = @ContraID And (IsNULL(Status, 0) & 192) = 0  
  
  Return IsNULL(@ReturnValue, 0)  
 End 
