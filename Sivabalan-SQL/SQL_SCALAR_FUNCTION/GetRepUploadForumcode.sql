Create FUNCTION GetRepUploadForumcode(@Repid int)
RETURNS nvarchar(100)
AS

BEGIN
	Declare @FString nvarchar(100)
	Declare @TempString nvarchar(100)

	Set @Fstring=N''

	if exists(Select Forumcode from Companies_to_upload,Reports_to_Upload
		Where Reports_to_Upload.ReportID=@Repid
		and Reports_to_Upload.CompanyID=Companies_to_Upload.ID)
	Begin
		Declare CurForum Cursor for
			Select Forumcode from Companies_to_upload,Reports_to_Upload
			Where Reports_to_Upload.ReportID=@Repid
			and Reports_to_Upload.CompanyID=Companies_to_Upload.ID

			Open CurForum
			Fetch next From CurForum into @Tempstring
				While @@Fetch_status=0
				Begin
					Set @FString=@FString + @TempString + N','
					Fetch next From CurForum into @Tempstring
				End

			Select @Fstring=Substring(@Fstring,1,Len(@Fstring)-1)
			Close CurForum
			Deallocate CurForum
	End

	RETURN @Fstring
END


