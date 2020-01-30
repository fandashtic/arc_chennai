Create Procedure mERP_sp_InsertRecdAEDetail
( @RecdID int, @SAleslevel nVArchar(255), @UserID nVarchar(510), @Username nVarchar(255), @Password nVArchar(510),  @Category nVarchar(255), @Active int)
As
Insert into tbl_mERP_RecdAELoginDetail (RecdID, Saleslevel, UserID, Username, Password, Category,  Active ) 
Values (@RecdID, @SAleslevel, @UserID, @Username, @Password, @Category, @Active)
