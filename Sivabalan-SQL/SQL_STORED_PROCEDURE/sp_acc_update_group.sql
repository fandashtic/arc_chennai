


CREATE procedure sp_acc_update_group (  @GROUPID int,
					@ACCOUNTTYPE int,
					@PARENTGROUP int,
					@ACTIVE INT)
AS
UPDATE AccountGroup SET  AccountType = @ACCOUNTTYPE,
			 ParentGroup = @PARENTGROUP,
			 Active = @ACTIVE,
			 LastModifiedDate=getdate()
WHERE GroupID = @GROUPID



