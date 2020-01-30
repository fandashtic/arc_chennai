Create Procedure mERP_sp_InsertRecdDSTDetail
(@RecdID int=0, @DSTCode nVArchar(255)= NULL, @DSTName nVarchar(2000)= NULL, @Active int, @DSTID int)
As
Insert into tbl_mERP_RecdDSTrainingDetails ( RecdID, DSTraining_Code, DSTraining_Name, DSTraining_Active, DST_ID) 
Values (@RecdID, @DSTCode, @DSTName, @Active, @DSTID)
