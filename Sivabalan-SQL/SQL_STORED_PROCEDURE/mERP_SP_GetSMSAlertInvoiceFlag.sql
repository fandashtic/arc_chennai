Create Procedure mERP_SP_GetSMSAlertInvoiceFlag AS BEGIN 
If exists (select 'x' from Tbl_merp_Configabstract where screencode='SMSINVALERT')
	select isnull(Flag,0) as 'SMSINVALERT'from Tbl_merp_Configabstract where screencode='SMSINVALERT' 
else
	Select 0 as 'SMSINVALERT' 
END 
