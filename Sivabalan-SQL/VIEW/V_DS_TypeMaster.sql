Create View V_DS_TypeMaster
as
select DS.SalesManID as DSID,DSTM.DSTypeID as DSTID,DSTM.DSTypeValue 
from salesman DS ,DSType_Master DSTM,DSType_Details DSTD
where DSTM.active=1 and DSTM.DSTypeID=DSTD.DSTypeID and
DSTD.SalesManID=DS.SalesManID and  
DS.Active = 1 and
DSTD.SalesManID in 
(select SalesManID from DSType_Details where salesmanID=DSTD.SalesManID and DSTYpeID = 
(select Top 1 DSTYpeID from DSType_Master where DSTypeName='Handheld DS' and DSTypeValue='Yes' ) )
and DSTM.DSTypeName <> 'Handheld DS'
