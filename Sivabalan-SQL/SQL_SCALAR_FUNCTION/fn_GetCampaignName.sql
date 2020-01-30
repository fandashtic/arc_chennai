CREATE Function fn_GetCampaignName(@Customerid nvarchar(30)) 
Returns  nvarchar(2000)
as
Begin
	declare @PrintDet nvarchar(500)
	declare @Detail nvarchar(500)
	declare @Result nvarchar(2000)
	set @PrintDet='' -- initialize the variable
	declare DetailCursor cursor for select campaignname from campaignmaster where campaignid in(select campaignid from campaigncustomers where customerid=@Customerid)
	open  detailCursor
	fetch next from DetailCursor into @Detail
		while @@Fetch_Status=0
			Begin
				set @PrintDet=@PRintDet + @Detail +' : '
				Fetch next from DetailCursor into @Detail
			End
		close DetailCursor
		Deallocate DetailCursor
	set @PrintDet=Left(@PrintDet,(Charindex(':',@printdet,Len(@PrintDet))-1))
SELECT @RESULT = IsNull(@PRINTDET,'') -- Return the Campaign name
return @Result
End



