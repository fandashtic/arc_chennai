CREATE procedure sp_get_PointsDetail @DocSerial int  
as  
begin  
 select * from PointsDetail where DocSerial = @DocSerial and Active=1  
end  
  

