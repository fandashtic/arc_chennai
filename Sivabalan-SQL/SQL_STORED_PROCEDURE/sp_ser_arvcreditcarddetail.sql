CREATE proc sp_ser_arvcreditcarddetail (@ArvId as int, @Type as int) 
as
if (@Type = 0)
	Select Particular, type from ARVDetail where DocumentID = @ArvId and  Type in (3,4) 
else
	Select Particular, type from ARVDetail where DocumentID = @ArvId and  Type = @Type 


