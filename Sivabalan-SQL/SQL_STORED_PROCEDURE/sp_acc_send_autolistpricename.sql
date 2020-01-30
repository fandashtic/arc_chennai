CREATE procedure sp_acc_send_autolistpricename(@PriceListDate Datetime,
@KeyField nvarchar(30)=N'%',@Direction int = 0, @BookMark nvarchar(128) = N'')        
as        
IF @Direction = 1        
Begin        
	if @KeyField = N'%%' 
	Begin
		Select 0 as Documentid , dbo.LookupDictionaryItem('New Price List',Default) as 'SendPriceListName'
		Union
		Select Top 8 Documentid , ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(SendPriceListID)) as 
		'SendPriceListName' from SendPriceList where 
		PriceListDate = @PriceListDate and
		ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(SendPriceListID)) like
		@Keyfield and
		ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(SendPriceListID)) > @BookMark 
		order by Documentid
	End
	Else
	Begin
		Select Top 9 Documentid , ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(SendPriceListID)) as 
		'SendPriceListName' from SendPriceList where 
		PriceListDate = @PriceListDate and
		ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(SendPriceListID)) like
		@Keyfield and
		ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(SendPriceListID)) > @BookMark 
		order by Documentid
	End
End        
Else        
Begin        
	If @KeyField = N'%%'
	Begin
		Select 0 as Documentid , dbo.LookupDictionaryItem('New Price List',Default) as 'SendPriceListName'
		Union
		Select Top 8 Documentid , 
		ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(Cast(SendPriceListID as nvarchar(50)))) as 
		'SendPriceListName' from SendPriceList where 
		PriceListDate = @PriceListDate and
		ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(cast(SendPriceListID  as nvarchar(50)))) like
		@Keyfield 
		order by Documentid
	End
	Else
	Begin
		Select Top 9 Documentid , 
		ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(Cast(SendPriceListID as nvarchar(50)))) as 
		'SendPriceListName' from SendPriceList where 
		PriceListDate = @PriceListDate and
		ltrim(rtrim(dbo.GetVoucherPrefix('SEND PRICE LIST')))+ ltrim(rtrim(cast(SendPriceListID  as nvarchar(50)))) like
		@Keyfield 
		order by Documentid
	End
End        




