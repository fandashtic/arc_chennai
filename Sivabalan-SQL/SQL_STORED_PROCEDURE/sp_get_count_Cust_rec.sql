
create proc sp_get_count_Cust_rec
as
select count(*) from cash_customer_rec where flag = 1



