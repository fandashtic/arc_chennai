
create proc sp_get_count_Stock_Tfr_Out
as
select count(*) from stocktransferoutabstract where status = 0

