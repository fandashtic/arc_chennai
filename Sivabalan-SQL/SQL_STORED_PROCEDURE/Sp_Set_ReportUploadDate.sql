
CREATE Procedure Sp_Set_ReportUploadDate    
as  
Update Setup Set ReportUploadDate = DateAdd(d, -1, OpeningDate)
where  ReportUploadDate is Null

