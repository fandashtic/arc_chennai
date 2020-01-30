
Create PROCEDURE [dbo].[FSU_sp_NoOfLatestThinClientUpdate](
@ClientID Int
)
AS
BEGIN
DECLARE @nodevalue nvarchar(100)
SELECT @nodevalue=node FROM tblClientMaster WHERE clientid =@ClientID

CREATE TABLE #tmpResult (FSUID int, [Filename] nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS, versionumber nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS ,DestinationFolder varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS )

if not ((Select top 1 isnull(FYCPStatus,0) from setup) = 2)
Begin
--Gets the new files in thinserver
INSERT INTO #tmpResult(FSUID,[Filename],versionumber,DestinationFolder)
SELECT isnull(a.FSUID,0) AS FSUid,a.FileName,a.versionnumber,a.DestinationFolder
FROM tbl_mERP_fileinfo a left outer join tbl_merp_Clientfileinfo b
ON isnull(a.versionnumber,0)!=isnull(b.version,0)
WHERE isnull(a.filename,'')=isnull(b.filename,'')
and active=1 and node = @nodevalue and a.FileName not in('DBLibrary.dll','DBVersion.dll','DotZLib.dll','FSUCommonLibrary.dll',
'FSUDataPacket.dll','FSUValidation.dll','UtilityFx.dll','XPProgBar.dll','MERPInstaller.exe','PSApp.exe','DatapostListener.exe','MoveDPL.exe','Datapost.exe','HHSync.exe','VajraUserID.exe'
,'DnDRFAXML.exe','VajraPatch.exe','HandleHHBatchFiles.exe','AutoServieCheck.bat','CA_SERVICE_AUTO_CHECK_V.bat','DMS_SERVICE_AUTO_CHECK_V.bat','R7MM_SERVICE_AUTO_CHECK_V.bat','ShrinkDB.exe')
and a.filename not like '%.dat' and a.filename not like '%.txt'
union
SELECT isnull(a.FSUID,0) AS FSUid,a.FileName,a.versionnumber,a.DestinationFolder
FROM tbl_mERP_fileinfo a
WHERE a.filename not in (SELECT c.filename FROM tbl_merp_Clientfileinfo c WHERE node=@nodevalue)
and a.FileName not in('DBLibrary.dll','DBVersion.dll','DotZLib.dll','FSUCommonLibrary.dll',
'FSUDataPacket.dll','FSUValidation.dll','UtilityFx.dll','XPProgBar.dll','MERPInstaller.exe','PSApp.exe','DatapostListener.exe','MoveDPL.exe','Datapost.exe','HHSync.exe','VajraUserID.exe'
,'DnDRFAXML.exe','VajraPatch.exe','HandleHHBatchFiles.exe','AutoServieCheck.bat','CA_SERVICE_AUTO_CHECK_V.bat','DMS_SERVICE_AUTO_CHECK_V.bat','R7MM_SERVICE_AUTO_CHECK_V.bat','ShrinkDB.exe')
and a.filename not like '%.dat' and a.filename not like '%.txt'
and a.active=1
End
Delete FROM #tmpResult Where Right(Filename,4) = '.ini' and Filename Not in (select Distinct ININame from tbl_mERP_TransactionIni Where Active = 1)
and Filename not in (
'Purchase ReturnCG_Inter_Dos.ini',
'Purchase ReturnCG_Inter_Windows.ini',
'Purchase ReturnCG_Intra_Dos.ini',
'Purchase ReturnCG_Intra_Windows.ini',
'Purchase ReturnNonCG_Inter_Dos.ini',
'Purchase ReturnNonCG_Inter_Windows.ini',
'Purchase ReturnNonCG_Intra_Dos.ini',
'Purchase ReturnNonCG_Intra_Windows.ini'
)


SELECT count(*) FROM #tmpResult

DROP TABLE #tmpResult
END

