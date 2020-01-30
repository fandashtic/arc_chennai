CREATE Procedure Sp_InsertCustomerGeoinfo(@CustomerCode Nvarchar(255),@Latitude Decimal(18,6),@Longitude Decimal(18,6))
As
Begin
	If Exists (select Top 1 * from customer   Where CustomerID =  @CustomerCode and Active = 1)
	Begin
		If Exists (select Top 1 * from OutletGeo   Where CustomerID =  @CustomerCode )
		Begin
			Update OutletGeo set Latitude  = @Latitude, ModifiedDate = Getdate() Where CustomerID =  @CustomerCode and Isnull(Latitude,0) = 0
			Update OutletGeo set Longitude = @Longitude, ModifiedDate = Getdate() Where CustomerID =  @CustomerCode and Isnull(Longitude,0) = 0
		End
		Else
		Begin
			Insert Into OutletGeo (CustomerID ,Latitude,Longitude ,ModifiedDate)
			Values (@CustomerCode,@Latitude,@Longitude,Getdate())
		End
	End
	
End
