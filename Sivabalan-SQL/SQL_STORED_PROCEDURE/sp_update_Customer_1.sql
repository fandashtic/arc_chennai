
CREATE PROCEDURE [sp_update_Customer_1]
	(@CustomerID_1 	[nvarchar],
	 @CustomerID_2 	[nvarchar](15),
	 @Company_Name_3 	[nvarchar](128),
	 @ContactPerson_4 	[nvarchar](255),
	 @BillingAddress_5 	[nvarchar](255),
	 @ShippingAddress_6 	[nvarchar](255),
	 @CityID_7 	[int],
	 @CountryID_8 	[int],
	 @AreaID_9 	[int],
	 @StateID_10 	[int],
	 @Phone_11 	[nvarchar](50),
	 @Email_12 	[nvarchar](50),
	 @CreationDate_13 	[datetime],
	 @Active_14 	[int])

AS UPDATE [Customer] 

SET  [CustomerID]	 = @CustomerID_2,
	 [Company_Name]	 = @Company_Name_3,
	 [ContactPerson]	 = @ContactPerson_4,
	 [BillingAddress]	 = @BillingAddress_5,
	 [ShippingAddress]	 = @ShippingAddress_6,
	 [CityID]	 = @CityID_7,
	 [CountryID]	 = @CountryID_8,
	 [AreaID]	 = @AreaID_9,
	 [StateID]	 = @StateID_10,
	 [Phone]	 = @Phone_11,
	 [Email]	 = @Email_12,
	 [CreationDate]	 = @CreationDate_13,
	 [Active]	 = @Active_14 

WHERE 
	( [CustomerID]	 = @CustomerID_1)




