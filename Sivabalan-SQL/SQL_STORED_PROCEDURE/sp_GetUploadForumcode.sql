Create Procedure sp_GetUploadForumcode(@Repid int)
As
			Select Forumcode from Companies_to_upload,Reports_to_Upload
			Where Reports_to_Upload.ReportID=@Repid
			and Reports_to_Upload.CompanyID=Companies_to_Upload.ID

