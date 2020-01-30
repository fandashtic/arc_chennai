Create procedure mERP_SP_checkforLastbackupdate
AS
BEGIN
	 SET DATEFORMAT DMY  
	 Declare @lastbackupdate as datetime  
	 Declare @gracedays as int  
	 --As per ITC's requirement, Last backup alert should also show if Last_Backup_date is null
	 if (select top 1 isnull(Last_Backup_date,0) from Setup) = 0
	 Begin
		select 1 
	 end 
	 else
	 begin
		 Select top 1 @lastbackupdate = dbo.stripdatefromtime(Last_Backup_date) from Setup  
		 IF (select top 1 isnull(flag,0) from tbl_mERP_ConfigAbstract where screencode='Backup') = 1  
		BEGIN  
			select @gracedays = [value] from tbl_mERP_ConfigDetail where screencode = 'Backup'  
			-- Alert will be shown only if Last Backup date is less than or equal to grace days  
			IF @lastbackupdate <= dbo.stripdatefromtime(getdate())-@gracedays  
			BEGIN  
				Select 1  
			END  
			ELSE  
			BEGIN  
				Select 0  
			END  
		END  
		ELSE  
		BEGIN  
			Select 0  
		END  
	 end
END

