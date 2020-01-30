Create Procedure mERP_SP_GetMismatchFSUInstall
AS
BEGIN
	Declare @MinFSUID int
	Declare @MaxInstallationDate Datetime
	Declare @NonInstalledFSU int
	Declare @CountMismatchFSU int
	Declare @FSUInstallCount int
	Declare @TmpFSUID int

	Create Table #tmpFSUIDs(PatchName nvarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS, FSUID int)


	Select @MinFSUID=Flag from tbl_merp_configabstract where screencode='FSUCutoff'

	Truncate Table FSUInstallStatus
	/* Stores all successfully installed FSUs*/
	Insert into FSUInstallStatus(FSUID,Status,InstallationDate)
	Select Distinct FSUID,0,Max(DateofInstallation) from tblinstallationdetail where FSUID>=@MinFSUID and status = 5 and FileName not like '%-DC-%' and FSUID not in(select distinct FSUID from ExceptionalFSU)
	Group by FSUID

	Select @MaxInstallationDate = Max(DateofInstallation) from tblinstallationdetail where FSUID=@MinFSUID and status = 5 and FileName not like '%-DC-%'; 
	/* Getting ALL FSUs installation count greater than least FSU installation Date*/
	With AllFSU (FSUID,InstallCount)
	As
	(
		Select FSUID,Count(FSUID) from tblinstallationdetail where FSUID>=@MinFSUID and status = 5 and FileName not like '%-DC-%' and Dateofinstallation >= @MaxInstallationDate and FSUID not in(select distinct FSUID from ExceptionalFSU)
		Group by FSUID
	)

	/* Updating Installation Count and setting Status as 1 */
	Update F Set F.InstallCount=A.InstallCount,status=1 From FSUInstallStatus F,AllFSU A Where F.FSUID=A.FSUID

	Update FSUInstallStatus Set InstallCount=0 where InstallCount is null

	/* Minimum of FSU ID which is not installed after the least FSU installation*/
	Select @NonInstalledFSU=min(FSUID) from FSUInstallStatus where status = 0
	/* Below logic did not work 
	Select @FSUInstallCount = Max(InstallCount) from FSUInstallStatus 
	Select @MaximumInstalledFSU=Min(FSUID) from FSUInstallStatus where InstallCount=@FSUInstallCount
	Select @CountMismatchFSU = min(FSUID) from FSUInstallStatus where Status = 1 and InstallCount < @FSUInstallCount and FSUID > @MaximumInstalledFSU
	*/
	/* We are taking max of installationdate and it's FSU ID and if there is any FSUID greater than that then it is wrong*/
	Select @TmpFSUID=Min(FSUID) from FSUInstallStatus where Status = 1 And InstallationDate = (select max(installationDate) from FSUInstallStatus)

	Select @CountMismatchFSU = min(FSUID) from FSUInstallStatus where Status = 1 and FSUID >@TmpFSUID
	

	/* A FSU is not installed */
	if isnull(@NonInstalledFSU,0) <> 0 
		Insert into #tmpFSUIDs(PatchName,FSUID)
		Select distinct I.[FileName],F.FSUID from FSUInstallStatus F, tblinstallationdetail I Where F.FSUID = I.FSUID And F.FSUID >=@NonInstalledFSU order by F.FSUID
	/* If there is a Count mismatch*/
	Else if isnull(@CountMismatchFSU,0)<>0
	BEGIN
		/* If there is no NON Installed FSU*/
		If isnull(@NonInstalledFSU,0) = 0
		BEGIN
			Insert into #tmpFSUIDs(PatchName,FSUID)
			Select distinct I.[FileName],F.FSUID from FSUInstallStatus F, tblinstallationdetail I Where F.FSUID = I.FSUID And F.FSUID >=@CountMismatchFSU order by F.FSUID
		END
		ELSE
		BEGIN
			/* If NON Installed FSUID is less than Count Mismatch FSU ID, consider NON Installed FSU ID*/
			If isnull(@NonInstalledFSU,0) <= isnull(@CountMismatchFSU,0)
			Insert into #tmpFSUIDs(PatchName,FSUID)
			Select distinct I.[FileName],F.FSUID from FSUInstallStatus F, tblinstallationdetail I Where F.FSUID = I.FSUID And F.FSUID >=@NonInstalledFSU order by F.FSUID			
			Else
			/* If NON Installed FSUID is greater than Count Mismatch FSU ID, consider Count Mismatch FSU ID */
			Insert into #tmpFSUIDs(PatchName,FSUID)
			Select distinct I.[FileName],F.FSUID from FSUInstallStatus F, tblinstallationdetail I Where F.FSUID = I.FSUID And F.FSUID >=@CountMismatchFSU order by F.FSUID			
		END
	END
	Select * from #tmpFSUIDs
	Drop Table #tmpFSUIDs
END
