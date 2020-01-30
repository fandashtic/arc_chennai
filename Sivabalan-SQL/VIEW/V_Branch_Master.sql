CREATE VIEW  [V_Branch_Master]
([Branch_ID],[Branch_Name],[Bank_ID],[Active])
AS
SELECT     BranchCode, BranchName,BankCode, Active 
FROM         dbo.BranchMaster
