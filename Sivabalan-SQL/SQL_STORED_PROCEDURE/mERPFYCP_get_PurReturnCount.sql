CREATE proc mERPFYCP_get_PurReturnCount ( @yearenddate datetime )
as 
Select count(*) from AdjustmentReturnAbstract_received where status = 0 and AdjustmentDate <= @yearenddate
