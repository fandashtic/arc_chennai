
Create Procedure mERP_SP_getLastbackupDate
AS
BEGIN
	SET DATEFORMAT DMY
	--As per ITC's requirement, Last backup alert should also show if  Last_Backup_date is null
	if (select top 1 isnull(Last_Backup_date,0) from Setup) = 0
	Begin  
		select 0
	end
	else
	begin
		Select dbo.stripdatefromtime(Last_Backup_date) from Setup  
	end
END

