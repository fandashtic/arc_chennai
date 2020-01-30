
CREATE Procedure FSU_sp_getDocuments
as    
Select RD.ReleaseId ,  FileName,LocalFilePath from tblDocumentDetail DD 
	inner join tblReleaseDetail RD on DD.ReleaseID = RD.ReleaseID Where isnull(DD.SavedLocalPath,'') = ''
	and RD.Status & 4 = 0 
	and RD.Status & 2 = 2 

Order by  RD.ReleaseID
