Create Procedure mERPFYCP_ResetStatus_ItemsReceivedDetail ( @yearenddate datetime )
as
update ItemsReceivedabstract set Flag = Flag | 32 where Flag & 32 = 0 and creationdate <= @yearenddate 
update ItemsReceivedDetail set Flag = Flag | 32 where Flag & 32 = 0 and creationdate <= @yearenddate 
