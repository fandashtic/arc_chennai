CREATE VIEW  [V_WD_Information]
([Company_Name],[Address],[Fiscal_Year],[Voucher_Start],[Tin_Number],[Localized_Name],[Organization_Type])
AS
SELECT     OrganisationTitle, BillingAddress, FiscalYear, VoucherStart, 
	   Tin_Number,LocalizedName, OrganisationType 
FROM        Setup                    
