CREATE Function fn_GetBeatDescForCus
(@cuscode nvarchar(30)) Returns nvarchar(510)
as
begin
	declare @BeatDesc nvarchar(510)
	Set @BeatDesc=dbo.LookupDictionaryItem(N'No Beat',default)

	Select @BeatDesc=Description from Beat where Beatid in
	(Select Beatid from Beat_Salesman where Customerid=@cuscode)

Return(Select @beatdesc)
end






