Create Procedure mERP_SP_GetSMSAlertFlag  
AS  
BEGIN  
 If exists (select 'x' from Tbl_merp_Configabstract where screencode='SMSAlert')  
 select isnull(Flag,0) as 'SMSALERT'from Tbl_merp_Configabstract where screencode='SMSAlert'  
 else  
 Select 0 as 'SMSALERT'  
END  
