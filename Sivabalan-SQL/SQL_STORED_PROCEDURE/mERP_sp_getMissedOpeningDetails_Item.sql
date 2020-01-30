CREATE procedure mERP_sp_getMissedOpeningDetails_Item (@OPENING_DATE datetime)
As

	If Exists (Select [ID] From sysobjects Where xType ='U' and [Name] = 'Batch_Products_Copy')
		Select Product_code, ProductName from Items 
			where product_code not in 
			(select product_code from OpeningDetails where opening_Date = @OPENING_DATE)
			And product_Code in (Select distinct product_Code from Batch_Products_Copy) --Avoid Items With No opening quantity  
	Else
		Select TOP 1 Product_code, ProductName from Items Where 1 = 0

