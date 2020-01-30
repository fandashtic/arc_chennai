Create Procedure mERP_SP_updateOutletGeo
AS
BEGIN
Declare @ID int
Declare @customerID nvarchar(30)
Declare Allcustomer cursor For
Select max(ID),CustomerID from OutletGeo_staging where isnull(status,0) = 0 group by CustomerID
Open Allcustomer
Fetch from Allcustomer into @ID,@customerID
While @@fetch_status = 0
BEGIN
	If not exists(Select * from OutletGeo where customerID=@customerID)
	BEGIN
		if ((Select isnull(Latitude,0) from OutletGeo_staging where ID=@ID) = 0) or ((Select isnull(Longitude,0) from OutletGeo_staging where ID=@ID) = 0)
		BEGIN
			insert into syncerror(TRANSACTIONID,TRANSACTIONTYPE,SALESMANID,MSGTYPE,MSGACTION,MSGDESCRIPTION,CREATIONDATE)
			Select 'MARKETINFO',4,0,'Information','Failed','Either Latitude or Longitude column is having incorrect value for the customer :'
			+ cast(@customerID as varchar)+ cast(@ID as varchar),getdate()
			update OutletGeo_staging set status = 2,modifieddate=getdate() where ID=@ID
		END	
		ELSE
		BEGIN
			insert into OutletGeo (CustomerID,Latitude,Longitude,modifieddate)
			Select CustomerID,Latitude,Longitude,getdate() from OutletGeo_staging where ID=@ID
		END
	END
	ELSE
	BEGIN
		if ((Select isnull(Latitude,0) from OutletGeo_staging where ID=@ID) = 0) or ((Select isnull(Longitude,0) from OutletGeo_staging where ID=@ID) = 0)
		BEGIN
			insert into syncerror(TRANSACTIONID,TRANSACTIONTYPE,SALESMANID,MSGTYPE,MSGACTION,MSGDESCRIPTION,CREATIONDATE)
			Select 'MARKETINFO',4,0,'Information','Failed','Either Latitude or Longitude column is having incorrect value for the customer :'
			+ cast(@customerID as varchar)+ cast(@ID as varchar),getdate()
			update OutletGeo_staging set status = 2,modifieddate=getdate() where ID=@ID
		END
		ELSE
		BEGIN
			update OutletGeo set Latitude=o.Latitude,Longitude=O.Longitude,modifieddate=getdate() from OutletGeo_staging o 
			Where OutletGeo.CustomerID=@customerID and o.ID=@ID
			And OutletGeo.CustomerID=o.CustomerID
		END
	END
	update OutletGeo_staging set status = 1 where customerID=@customerID and isnull(status,0) <> 2
	Fetch Next from Allcustomer into @ID,@customerID
END
Close Allcustomer
Deallocate Allcustomer
END
