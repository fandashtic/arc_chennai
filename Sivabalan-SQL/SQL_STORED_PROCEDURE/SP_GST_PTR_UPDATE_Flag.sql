CREATE PROCEDURE [dbo].[SP_GST_PTR_UPDATE_Flag]    
as
BEGIN
         
         update Reports_To_Upload set Frequency=2 where ReportName='VAT Stock Report'
         
         update tbl_mERP_ConfigAbstract set flag=1  where ScreenCode='GSTPTRUpdate' and ScreenName='GSTPTRUpdate'
   
END
