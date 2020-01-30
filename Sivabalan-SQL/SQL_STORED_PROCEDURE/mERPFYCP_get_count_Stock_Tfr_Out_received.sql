CREATE procedure mERPFYCP_get_count_Stock_Tfr_Out_received ( @yearenddate datetime )
as
Select count(*) from stocktransferoutabstractreceived where (status & 128) = 0 and DocumentDate <= @yearenddate
