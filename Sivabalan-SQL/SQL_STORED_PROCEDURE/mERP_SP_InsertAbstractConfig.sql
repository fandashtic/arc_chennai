Create Procedure mERP_SP_InsertAbstractConfig (@ID int, @Flag int)
As
Update CA Set Flag = @Flag
from tbl_mERP_ConfigAbstract CA Inner join tbl_mERP_RecConfigAbstract RCA
On CA.Screenname = RCA.MenuName
Where RCA.ID = @ID

update tbl_mERP_RecConfigAbstract set Status = Status | 32 Where ID = @ID
