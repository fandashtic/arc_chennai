create proc mERPFYCP_get_count_Cust_rec ( @yearenddate datetime )
as
select count(*) from cash_customer_rec where flag = 1 and CreationDate <= @yearenddate
