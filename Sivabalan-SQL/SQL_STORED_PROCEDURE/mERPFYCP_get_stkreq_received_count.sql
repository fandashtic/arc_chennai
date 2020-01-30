create procedure mERPFYCP_get_stkreq_received_count ( @yearenddate datetime )
as    
Select count(*) from SRAbstractReceived where (status & 128) = 0 and DocumentDate <= @yearenddate
