Create Procedure sp_Insert_Companies_To_Upload( @CompanyID Int,
												@CompanyForumCode nvarchar(50))
As
Insert Into Companies_To_Upload (ID, ForumCode) Values (@CompanyID, @CompanyForumCode)
