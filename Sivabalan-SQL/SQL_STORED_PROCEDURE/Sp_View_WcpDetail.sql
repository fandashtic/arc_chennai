CREATE procedure Sp_View_WcpDetail(@Salecode Bigint, @wcpdate DateTime) as  

select code, wcpdate, Customerid,serial  
from wcpdetail where code=@salecode and wcpdate = @wcpdate
order by wcpdate, serial  





