
create procedure sp_get_stkreq_received_count  
as    
select count(*) from SRAbstractReceived where (status & 128) = 0  

 
