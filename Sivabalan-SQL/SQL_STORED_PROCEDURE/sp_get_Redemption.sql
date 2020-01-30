CREATE procedure sp_get_Redemption (@DocSerial int, @Active Int)
as  
begin  
	If @Active = 1 
		select * from Redemption where DocSerial=@DocSerial and Active =1
	Else
		select * from Redemption where DocSerial=@DocSerial 
end  
  


