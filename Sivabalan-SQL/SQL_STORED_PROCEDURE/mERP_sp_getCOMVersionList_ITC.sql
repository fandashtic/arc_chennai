CREATE Procedure mERP_sp_getCOMVersionList_ITC(@Recoverable int=1)
AS
Select * from ComVersion Where Recoverable = @Recoverable
