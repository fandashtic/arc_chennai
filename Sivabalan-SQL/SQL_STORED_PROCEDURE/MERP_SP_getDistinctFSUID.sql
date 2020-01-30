
Create Procedure MERP_SP_getDistinctFSUID
AS
Begin
	-- Since Old version FSU should not requested to portal, we are making the below change
	select distinct T.FSUID from tblinstallationdetail T,Setup S, tbl_merp_fileinfo F,Tbl_merp_configabstract Config where IsNull(T.Status, 0) & 4 = 4     
	and S.Version=F.BuildVersion    
	And Config.ScreenCode='FSUCutoff'
	And T.FSUID >= Cast(Description as int) 
	and T.FSUID = F.FSUID    
	order by T.FSUID   

End
