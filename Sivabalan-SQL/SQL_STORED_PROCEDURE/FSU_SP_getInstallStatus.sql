Create  Procedure FSU_SP_getInstallStatus(  
@InstallationID int)
As
select Count(*) as "RowCount" from tblInstallationDetail IND
where 
	IND.InstallationID = @InstallationID
	AND IND.Status & 4 = 4
