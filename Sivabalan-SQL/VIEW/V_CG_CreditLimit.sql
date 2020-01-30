CREATE VIEW  [V_CG_CreditLimit]
([Customer_ID], [Customer_Name], [Category_Group], [Group_wise_Credit_term], [Group_wise_Credit_Limit], 
[Group_Wise_No_of_open_invoices], [Active])
AS
SELECT      Customer.CustomerID, Customer.Company_Name, CustomerCreditLimit.GroupID, CustomerCreditLimit.CreditTermDays, 
	    CustomerCreditLimit.CreditLimit, CustomerCreditLimit.NoOFbills, 
	    'Active' = (Case When Isnull(Customer.Active, 1) + Isnull(ProductCategoryGroupAbstract.Active, 1) 
	    + Isnull(CreditTerm.Active, 1) <> 3 then 0 else 1 end) 
FROM        Customer
Left Outer Join CustomerCreditLimit On Customer.CustomerID = CustomerCreditLimit.CustomerID 
Left Outer Join ProductCategoryGroupAbstract On CustomerCreditLimit.GroupID = ProductCategoryGroupAbstract.GroupID 
Left Outer Join CreditTerm On CreditTerm.CreditID = CustomerCreditLimit.CreditTermDays
where ProductCategoryGroupAbstract.OCGtype = ( Select flag from tbl_merp_configabstract where screencode = 'OCGDS' )
