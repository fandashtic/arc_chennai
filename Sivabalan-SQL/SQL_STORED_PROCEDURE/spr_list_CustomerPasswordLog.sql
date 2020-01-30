CREATE Procedure spr_list_CustomerPasswordLog(@FromDate datetime,@Todate datetime)
As

Declare @SETPASSWORD As NVarchar(50)
Declare @CHANGEPASSWORD As NVarchar(50)
Declare @RESETPASSWORD As NVarchar(50)

Set @SETPASSWORD = dbo.LookupDictionaryItem(N'Set Password', Default)
Set @CHANGEPASSWORD = dbo.LookupDictionaryItem(N'Change Password', Default)
Set @RESETPASSWORD = dbo.LookupDictionaryItem(N'Reset Password', Default)

Select 1,"CustomerID"=PasswordLog.CustomerID,"CustomerName"=Customer.Company_Name,"Modified By"=PasswordLog.UserName,
"Transaction Type"=Case PasswordLog.Type When 'N' then @SETPASSWORD
When 'C' then @CHANGEPASSWORD When 'R' then @RESETPASSWORD End,
"Transaction Date"=PasswordLog.TransactionDate
From PasswordLog,Customer
Where PasswordLog.CustomerID=Customer.CustomerID
And PasswordLog.TransactionDate Between @FromDate And @ToDate
order by PasswordLog.Customerid,PasswordLog.TransactionDate

