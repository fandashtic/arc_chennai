
CREATE proc sp_get_PurReturnCount
as 
select count(*) from AdjustmentReturnAbstract_received where status = 0


