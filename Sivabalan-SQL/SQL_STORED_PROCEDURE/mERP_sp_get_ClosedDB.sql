Create Procedure mERP_sp_get_ClosedDB
As

If (Select Top 1 FYCPStatus From Setup) = 2 And IsNull((Select Top 1 NextDataBase From Setup),'') <> ''
Select 1,IsNull(NextDataBase,''),IsNull(OperatingYear,'') From Setup
Else
Select 0,IsNull(NextDataBase,''),IsNull(OperatingYear,'') From Setup

