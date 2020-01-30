CREATE PROCEDURE sp_Update_PointsAbstract(@DocSerial int,@DefinitionType int,
 @Points int,@Value decimal(18,6), @Active int,@DefName nvarchar(25),@Customer int)    
As  
If (Select count(*) from PointsAbstract Where DocSerial=@DocSerial) > 0 
Begin
	Update  PointsAbstract  Set   
	DefinitionType=@DefinitionType,  
	Points=@Points,  
	Value=@Value,  
	Active=@Active,  
	DefinitionName=@DefName,  
	Customer=@Customer  
	Where DocSerial = @DocSerial  
End
