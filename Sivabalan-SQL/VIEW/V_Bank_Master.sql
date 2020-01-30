CREATE VIEW  [V_Bank_Master]
([Bank_ID],[Bank_Name],[Active])
AS
SELECT     BankCode, BankName, Active
FROM         dbo.BankMaster
