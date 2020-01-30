
Create Procedure mERP_SP_Get_OutletGeo @CustomerID nvarchar(30)  
AS  
BEGIN  
 Select top 1 isnull(Latitude,0) as Latitude, isnull(Longitude,0) as Longitude from OutletGeo where customerId=@CustomerID  
END

