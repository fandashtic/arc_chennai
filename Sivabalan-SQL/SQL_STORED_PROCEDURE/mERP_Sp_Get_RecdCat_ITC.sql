Create procedure mERP_Sp_Get_RecdCat_ITC
AS
Select C.ID,R.Division,isnull(R.CategoryGroup,'') as categorygroup From tbl_mERP_RecdCatDetail R,tbl_mERP_RecdCatAbstract C        
Where R.ID = C.ID And        
isnull(C.Status,0) = 0 and isnull(R.Status,0) = 0        

