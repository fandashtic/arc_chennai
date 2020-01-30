Create Procedure mERP_Sp_get_Recd_WDSKUListCount
As  
Begin  
 Select count(distinct DocumentId) From Recd_WDSKUList Where isnull(Status,0) = 0  
End  
