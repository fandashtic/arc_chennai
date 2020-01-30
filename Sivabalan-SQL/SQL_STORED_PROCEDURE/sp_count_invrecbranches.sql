CREATE procedure sp_count_invrecbranches  
as  
select count(*)  
from invoiceabstract  
where   
status & 512 <> 0 AND  
ISNULL(netvalue,0)+ISNULL(roundoffamount,0)+ISNULL(adjustedamount,0) +ISNULL(adjustmentvalue,0) = ISNULL(balance,0)  
  



