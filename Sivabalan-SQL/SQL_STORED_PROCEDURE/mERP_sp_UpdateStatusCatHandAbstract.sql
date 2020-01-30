Create Procedure mERP_sp_UpdateStatusCatHandAbstract( @Docserial int)
As
Update tbl_mERP_RecdCatHandAbstract Set status=32 where ID = @Docserial
