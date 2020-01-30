  
Create procedure sp_get_PointsAbstract(@DocSerial as int=Null)      
As        
Begin      
If  @docserial IS NULL 
	Select * From PointsAbstract Where Active=1
else
	select * from PointsAbstract where DocSerial=@DocSerial      
End        

