CREATE Procedure merp_sp_checkpatchfile
as 
begin
select distinct T.FileName,T.FSUID from tblInstallationdetail T,Setup S, tbl_merp_fileinfo F where T.status&4=4 and
S.Version=F.BuildVersion and T.FSUID = F.FSUID and T.[Filename] not like '%-DC-%' and T.fsuid >
(
select top 1 fsuid from tblInstallationdetail where status &4=4 and [ModifiedDate] =(select max([ModifiedDate]) from tblInstallationdetail where status & 4= 4 and Filename not like '%-DC-%') Order By fsuid Desc
)  
end
