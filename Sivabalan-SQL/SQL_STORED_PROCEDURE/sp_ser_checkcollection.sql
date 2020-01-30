CREATE Procedure sp_ser_checkcollection(@CollectionID as int ) 
as 
Declare @Result as int 
Set @Result = 0

/* checks for Deposited collection */
If Exists(Select * from Collections Where documentID = @CollectionID and OtherDepositID > 0) 		
begin	Set @Result = 1 end 

Select @Result

