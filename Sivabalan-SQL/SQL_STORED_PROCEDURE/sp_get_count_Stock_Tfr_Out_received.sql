CREATE procedure sp_get_count_Stock_Tfr_Out_received
as
select count(*) from stocktransferoutabstractreceived where (status & 128) = 0

