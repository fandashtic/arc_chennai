create proc mERPFYCP_get_count_Schemes_rec ( @yearenddate datetime )
as
Select count(*) from Schemes_rec where flag = 1 and CreationDate <= @yearenddate
