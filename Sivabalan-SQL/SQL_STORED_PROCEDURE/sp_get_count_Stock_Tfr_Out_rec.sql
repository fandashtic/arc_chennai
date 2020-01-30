
create proc sp_get_count_Stock_Tfr_Out_rec
as
select count(*) from stocktransferoutabstractreceived where status = 0

