CREATE PROCEDURE Sp_Get_SalesPortalIPList As  
Select 'ipaddress' = IPAddress From SalesPortalIPList 
Select 'salesportalip' = SalesPortalIP From Setup  

