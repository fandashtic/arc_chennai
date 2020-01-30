Create Procedure mERP_sp_getTablesToShrink
As
Select Name From Sysobjects 
Where xType = 'U' And Name Not in 
('dtproperties', 'items', 'setup', 'ReportAbstractReceived', 'ReportDetailReceived',
 'Inbound_Log', 'tblClientMaster', 'tblDocumentDetail', 'tblErrorLog',
 'tblInstallationDetail', 'tblInstalledVersions', 'tblMessageDetail', 
 'tblReleaseDetail', 'tblUpdateDetail')
