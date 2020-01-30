CREATE Procedure Sp_Acc_Rpt_List_CustomerCheques (@CustomerName nvarchar(50),@Type nVarchar(25))      
as      
Declare @UNUSED_CHEQUES nvarchar(25)
Declare @USED_CHEQUES nvarchar(25)

Set @UNUSED_CHEQUES = dbo.LookupDictionaryItem('Unused Cheques',Default)
Set @USED_CHEQUES = dbo.LookupDictionaryItem('Used Cheques',Default)

if @CustomerName = N'%'
Begin
	if @Type = @UNUSED_CHEQUES
	Begin
		select Distinct ltrim(rtrim(cast(CC.ChequeNumber as nvarchar(25)))) + N'€' + rtrim(ltrim(CC.BankCode)) +  N'€' + rtrim(ltrim(CC.BranchCode)),
		C.Company_Name as "Customer",CC.ChequeNumber as "Cheque Number",BM.BankName as "Bank",BRM.BranchName as "Branch",
		Case
			When CC.active = 1 then dbo.LookupDictionaryItem('Active',Default)
			Else dbo.LookupDictionaryItem('De-Active',Default)
		End as "Status"
		from customercheques CC,BankMaster as BM,BranchMaster as BRM,Customer as C
		where -- CC.active = 1   and    
		Ltrim(rtrim(cast(CC.CustomerID as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.chequenumber as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.BankCode as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.BranchCode as nvarchar(50))))
		not in
		(
		select distinct 
			Isnull(
			case 
				when isnull(b.customerID,N'') = N'' then
					(Select CustomerID from Customer where AccountID = isnull(b.Others,0))
				Else
					Ltrim(rtrim(cast(b.customerid as nvarchar(50)))) 
			End,N'')
		+ N'€' + Ltrim(rtrim(cast(b.chequenumber as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(b.BankCode as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(b.BranchCode as nvarchar(50))))
		from customercheques a, collections b      
		where a.bankcode = b.bankcode and a.branchcode = b.branchcode and isnull(b.status,0) in (0,1,2)
		and (a.customerid = isnull(b.customerid,N'') or 
		a.CustomerID in 
			(Select CustomerID from Customer where AccountID = isnull(b.Others,0)))
		)
		and CC.BankCode = BM.BankCode      
		and cc.BranchCode = BRM.BranchCode      
		and BM.BankCode = BRM.BankCode      
		and CC.CustomerID = C.CustomerID
		Order by BankName,BranchName,CC.ChequeNumber
	End
	Else if @Type = @USED_CHEQUES
	Begin
		select Distinct ltrim(rtrim(cast(CC.ChequeNumber as nvarchar(25)))) + N'€' + rtrim(ltrim(CC.BankCode)) +  N'€' + rtrim(ltrim(CC.BranchCode)),
		C.Company_Name as "Customer",CC.ChequeNumber as "Cheque Number",BM.BankName as "Bank",BRM.BranchName as "Branch",
		Case
			When CC.active = 1 then dbo.LookupDictionaryItem('Active',Default)
			Else dbo.LookupDictionaryItem('De-Active',Default)
		End as "Status"
		from customercheques CC,BankMaster as BM,BranchMaster as BRM,Customer as C
		where 
		Ltrim(rtrim(cast(CC.CustomerID as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.chequenumber as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.BankCode as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.BranchCode as nvarchar(50))))
		in        
		(
		select distinct 
			Isnull(
			case 
				when isnull(b.customerID,N'') = N'' then
					(Select CustomerID from Customer where AccountID = isnull(b.Others,0))
				Else
					Ltrim(rtrim(cast(b.customerid as nvarchar(50)))) 
			End,N'')
		+ N'€' + Ltrim(rtrim(cast(b.chequenumber as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(b.BankCode as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(b.BranchCode as nvarchar(50))))
		from customercheques a, collections b      
		where a.bankcode = b.bankcode and a.branchcode = b.branchcode and isnull(b.status,0) in (0,1,2)
		and (a.customerid = isnull(b.customerid,N'') or 
		a.CustomerID in 
			(Select CustomerID from Customer where AccountID = isnull(b.Others,0)))
		)
		and CC.BankCode = BM.BankCode      
		and CC.BranchCode = BRM.BranchCode      
		and BM.BankCode = BRM.BankCode      
		and CC.CustomerID = C.CustomerID
		Order by BankName,BranchName,CC.ChequeNumber
	End
End
else
Begin
	if @Type = @UNUSED_CHEQUES
	Begin
		select ltrim(rtrim(cast(CC.ChequeNumber as nvarchar(25)))) + N'€' +  rtrim(ltrim(CC.BankCode)) +  N'€' + rtrim(ltrim(CC.BranchCode)),
		@CustomerName as "Customer",CC.ChequeNumber as "Cheque Number",BM.BankName as "Bank",BRM.BranchName as "Branch",
		Case
			When CC.active = 1 then dbo.LookupDictionaryItem('Active',Default)
			Else dbo.LookupDictionaryItem('De-Active',Default)
		End as "Status"
		from customercheques CC,BankMaster as BM,BranchMaster as BRM      
		where 
		Ltrim(rtrim(cast(CC.CustomerID as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.chequenumber as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.BankCode as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.BranchCode as nvarchar(50))))
		not in        
		(
		select Distinct
			Isnull(
			case 
				when isnull(b.customerID,N'') = N'' then
					(Select CustomerID from Customer where AccountID = isnull(b.Others,0))
				Else
					Ltrim(rtrim(cast(b.customerid as nvarchar(50)))) 
			End,N'')
		+ N'€' + Ltrim(rtrim(cast(b.chequenumber as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(b.BankCode as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(b.BranchCode as nvarchar(50))))
		from customercheques a, collections b      
		where a.bankcode = b.bankcode and a.branchcode = b.branchcode and isnull(b.status,0) in (0,1,2)
		and ((a.customerid in (select CustomerID from Customer where Company_Name = @CustomerName)) or
		(a.CustomerID in 
			(Select CustomerID from Customer where AccountID = isnull(b.Others,0))))
		and a.ChequeNumber = b.ChequeNumber
		)
		and CC.customerid in (select CustomerID from Customer where Company_Name = @CustomerName)
		and CC.BankCode = BM.BankCode      
		and cc.BranchCode = BRM.BranchCode      
		and BM.BankCode = BRM.BankCode      
	End
	Else if @Type = @USED_CHEQUES
	Begin
		select ltrim(rtrim(cast(CC.ChequeNumber as nvarchar(25)))) + N'€' +  rtrim(ltrim(CC.BankCode)) +  N'€' + rtrim(ltrim(CC.BranchCode)),
		@CustomerName as "Customer",CC.ChequeNumber as "Cheque Number",BM.BankName as "Bank",BRM.BranchName as "Branch",
		Case
			When CC.active = 1 then dbo.LookupDictionaryItem('Active',Default)
			Else dbo.LookupDictionaryItem('De-Active',Default)
		End as "Status"
		from customercheques CC,BankMaster as BM,BranchMaster as BRM      
		where 
		Ltrim(rtrim(cast(CC.CustomerID as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.chequenumber as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.BankCode as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(CC.BranchCode as nvarchar(50))))
		in        
		(
		select Distinct
			Isnull(
			case 
				when isnull(b.customerID,N'') = N'' then
					(Select CustomerID from Customer where AccountID = isnull(b.Others,0))
				Else
					Ltrim(rtrim(cast(b.customerid as nvarchar(50)))) 
			End,N'')
		+ N'€' + Ltrim(rtrim(cast(b.chequenumber as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(b.BankCode as nvarchar(50)))) + N'€' +
		Ltrim(rtrim(cast(b.BranchCode as nvarchar(50))))
		from customercheques a, collections b      
		where a.bankcode = b.bankcode and a.branchcode = b.branchcode and isnull(b.status,0) in (0,1,2)
		and ((a.customerid in (select CustomerID from Customer where Company_Name = @CustomerName)) or
		(a.CustomerID in 
			(Select CustomerID from Customer where AccountID = isnull(b.Others,0))))
		and a.ChequeNumber = b.ChequeNumber
		)
		and CC.customerid in (select CustomerID from Customer where Company_Name = @customername)
		and CC.BankCode = BM.BankCode      
		and cc.BranchCode = BRM.BranchCode      
		and BM.BankCode = BRM.BankCode      
	End
End      
    
  
/*
Useless Code
		union      
		select ltrim(rtrim(cast(CC.ChequeNumber as varchar(25)))) + '€' + rtrim(ltrim(CC.BankCode)) + '€' + rtrim(ltrim(CC.BranchCode)),
		C.Company_Name as "Customer",CC.ChequeNumber as "Cheque Number",BM.BankName as "Bank",BRM.BranchName as "Branch"    ,'1'
		from customercheques CC,BankMaster as BM,BranchMaster as BRM,Customer as C  
		where CC.active = 0      
		and CC.chequenumber in        
		(select b.chequenumber from customercheques a, collections b      
		where a.bankcode = b.bankcode and a.branchcode = b.branchcode and b.status is null)       
		and CC.BankCode = BM.BankCode      
		and cc.BranchCode = BRM.BranchCode      
		and BM.BankCode = BRM.BankCode      
		and CC.CustomerID = C.CustomerID
		Order by CC.ChequeNumber      

		union      
		select ltrim(rtrim(cast(CC.ChequeNumber as varchar(25)))) +  '€' + rtrim(ltrim(CC.BankCode)) + '€' + rtrim(ltrim(CC.BranchCode)),
		@CustomerName as "Customer",CC.ChequeNumber as "Cheque Number",BM.BankName as "Bank",BRM.BranchName as "Branch"
		from customercheques CC,BankMaster as BM,BranchMaster as BRM      
		where CC.active = 0      
		and CC.chequenumber in        
		(select b.chequenumber from customercheques a, collections b      
		where a.bankcode = b.bankcode and a.branchcode = b.branchcode and b.status is null)       
		and CC.customerid in (select CustomerID from Customer where Company_Name = @customername)
		and CC.BankCode = BM.BankCode      
		and cc.BranchCode = BRM.BranchCode      
		and BM.BankCode = BRM.BankCode      
		Order by CC.ChequeNumber      
*/







