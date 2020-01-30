

CREATE procedure sp_acc_insert_group (  @GROUPNAME nvarchar(255),
					@ACCOUNTTYPE int,
					@PARENTGROUP int)
					
AS
INSERT INTO AccountGroup(GroupName,
			 AccountType,
			 ParentGroup,
			 Active,
			 Fixed)
			 
Values (@GROUPNAME,
	@ACCOUNTTYPE,
	@PARENTGROUP,
	1,
	0)













