CREATE procedure Sp_View_WcpAbstract(@documentid Bigint) as      
select code, weekdate, salesmanid, docref, docseriestype, documentid, documentdate, status, Remarks      
from wcpabstract where Code=@documentid      


