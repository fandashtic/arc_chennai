Create procedure mERP_sp_Upgrade_HHScripts
As
Begin
--itcuser DB User Creation
Declare @sid varbinary(16)
,@Name_in_db sysname
,@loginName sysname
,@passwd sysname
Select @loginName = 'itcuser',@passwd = 'eureka12'
select @sid = sid from master..syslogins where name = @loginName
if @sid Is NULL
exec sp_addlogin @LoginName,@passwd
if exists(Select name from sys.schemas where name=@LoginName) drop schema itcuser
select @Name_in_db = name from sysusers Where name = @loginName
if @Name_in_db Is not NULL
exec sp_dropUser @Name_in_db

else
Begin
if exists(Select name from sys.schemas where name=@LoginName) drop schema itcuser
select @Name_in_db = name from sysusers Where name = @loginName
if @Name_in_db Is not NULL
exec sp_dropUser @Name_in_db
end
exec sp_addUser @loginName

-- itcuser DB Access Permission setting
GRANT SELECT,INSERT,UPDATE,DELETE ON Order_Header TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Order_Details TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Scheme_Details TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Collection_Details TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Stock_Return TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Inbound_Log TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON SyncError TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Scheme_Details_copy TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Stock_Return_copy TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON AssetInfoTracking_HH TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON OLTargetAchievement TO itcuser;

DENY update (SchemeID_HH,GroupID,SchemeID_HH) ON Scheme_Details TO itcuser;

GRANT SELECT,INSERT,UPDATE,DELETE ON DS_TimeSpent TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Fail_Visit_Reason TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Product_Focus TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Product_Launch TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON DS_SOH_HDR TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON DS_SOH_DTL TO itcuser;

GRANT ALTER ON TmpPM TO itcuser;
GRANT ALTER ON TmpPMDetail TO itcuser;
GRANT ALTER ON TmpPMGroups TO itcuser;
GRANT ALTER ON tmpDSPMSalesman TO itcuser;
GRANT ALTER ON Tmp_SKUOPT_DailySKU TO itcuser;
GRANT ALTER ON Tmp_VInvoice TO itcuser;
GRANT ALTER ON TmpNewCustomers TO itcuser;
GRANT ALTER ON HHViewLog TO itcuser;
GRANT ALTER ON TmpDSTypeCategoryMap TO itcuser;
GRANT ALTER ON NewCustomer_HH TO itcuser;
--GRANT ALTER ON Tmp_ViewItemMaster TO itcuser;
--GRANT ALTER ON TmpView_OLTargetAchievement TO itcuser;
GRANT ALTER ON DSRouteInfo TO itcuser;


GRANT SELECT,INSERT,UPDATE,DELETE ON TmpPM TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON TmpPMDetail TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON TmpPMGroups TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON tmpDSPMSalesman TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Tmp_SKUOPT_DailySKU TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON Tmp_VInvoice TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON TmpNewCustomers TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON HHViewLog TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON TmpDSTypeCategoryMap TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON SYS_DE_LOG TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON NewCustomer_HH TO itcuser;
--GRANT SELECT,INSERT,UPDATE,DELETE ON Tmp_ViewItemMaster TO itcuser;
--GRANT SELECT,INSERT,UPDATE,DELETE ON TmpView_OLTargetAchievement TO itcuser;
GRANT SELECT,INSERT,UPDATE,DELETE ON DSRouteInfo TO itcuser;

/* GGDRViewData is not required as ITC is no longer using it
GRANT SELECT,INSERT,UPDATE,DELETE ON dbo.GGDRViewData TO itcuser;
GRANT EXEC ON dbo.SP_PreLoad_GGDR_Views TO Public; */
GRANT EXEC ON dbo.mERP_sp_UpdateInboundLog_import TO Public;
GRANT EXEC ON dbo.SP_HHViewPostData TO itcuser;
GRANT SELECT ON V_WD_Information TO itcuser;
GRANT SELECT ON V_Customer_Master TO itcuser;
GRANT SELECT ON V_Category_Master TO itcuser;
GRANT SELECT ON V_Channel_Type TO itcuser;
GRANT SELECT ON V_Sub_Channel_Type TO itcuser;
GRANT SELECT ON V_Beat  TO itcuser;
GRANT SELECT ON V_Salesman TO itcuser;
GRANT SELECT ON V_Beat_Salesman TO itcuser;
GRANT SELECT ON V_CG_CreditLimit TO itcuser;
GRANT SELECT ON V_Item_Master TO itcuser;
GRANT SELECT ON V_Tax TO itcuser;
GRANT SELECT ON V_Category_Group TO itcuser;
GRANT SELECT ON V_Bank_Master TO itcuser;
GRANT SELECT ON V_Branch_Master TO itcuser;
GRANT SELECT ON V_Outstanding_Abstract TO itcuser;
GRANT SELECT ON V_Outstanding_Details TO itcuser;
GRANT SELECT ON V_Quotation_Abstract TO itcuser;
GRANT SELECT ON V_Quotation_Details TO itcuser;
GRANT SELECT ON V_Scheme TO itcuser;
GRANT SELECT ON V_SchemeDetail TO itcuser;
GRANT SELECT ON V_Item_Schemes TO itcuser;
GRANT SELECT ON V_Customer_Schemes TO itcuser;
GRANT SELECT ON V_SpecialCategory TO itcuser;
GRANT SELECT ON V_SpecialCategory_Item TO itcuser;
GRANT SELECT ON V_Uom TO itcuser;
GRANT SELECT ON V_CreditTerm TO itcuser;
GRANT SELECT ON V_Customer_Categoryhandler TO itcuser;
GRANT SELECT ON V_Van TO itcuser;
GRANT SELECT ON V_VanStatementAbstract TO itcuser;
GRANT SELECT ON V_VanStatementDetail TO itcuser;
GRANT SELECT ON V_SyncError TO itcuser;
GRANT SELECT ON V_CustomerCategory TO itcuser;
GRANT SELECT ON V_Collection_Abstract TO itcuser;
GRANT SELECT ON V_Area TO itcuser;
GRANT SELECT ON V_ItemCategories TO itcuser;
GRANT SELECT ON V_Collection_Detail TO itcuser;
GRANT SELECT ON V_Invoices TO itcuser;
GRANT SELECT ON V_OffTakeAchived TO itcuser;
GRANT SELECT ON V_Redemption_Abstract TO itcuser;
GRANT SELECT ON V_Redemption_Detail TO itcuser;
GRANT SELECT ON V_Customer_Merchandise TO itcuser;
GRANT SELECT ON V_Reason_Master TO itcuser;
GRANT EXECUTE ON sp_InvoiceHistory_Abstract_DataExport TO itcuser;
GRANT EXECUTE ON sp_InvoiceHistory_Detail_DataExport TO itcuser;
GRANT EXECUTE ON sp_SalesHistory_Item TO itcuser;
GRANT EXECUTE ON sp_SalesHistory_Outlet TO itcuser;
GRANT EXECUTE ON sp_SalesHistory_Category TO itcuser;
GRANT EXECUTE ON sp_Collection TO itcuser
GRANT SELECT ON V_DS_Metrics to itcuser;
GRANT SELECT ON V_Supervisor TO itcuser;
GRANT SELECT ON V_Supervisor_Salesman TO itcuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON DSSurveyDetails to itcuser;
GRANT SELECT ON V_SurveyDetailsGeneral to itcuser;
GRANT SELECT ON V_SurveyDetailsProductList to itcuser;
GRANT SELECT ON V_SurveyDetailsProductQuestion to itcuser;
GRANT SELECT ON V_SurveyMaster to itcuser;
GRANT SELECT ON V_SurveyOutletmapping to itcuser;
GRANT SELECT ON V_SurveyQuestionAnswers to itcuser;
GRANT SELECT ON V_LP_Customer TO itcuser;
GRANT SELECT ON V_Customerwise_LP TO itcuser;
GRANT SELECT ON V_LP_Target_Achievement TO itcuser;
GRANT SELECT ON V_DailySKU TO itcuser;
GRANT SELECT ON V_DS_Metrics_Abstract TO itcuser;
GRANT SELECT ON V_DS_Metrics_Detail TO itcuser;
GRANT SELECT ON V_DS_TypeMaster TO itcuser;
GRANT SELECT ON V_HH_Imagetype TO itcuser;
GRANT SELECT ON V_SD_PM TO itcuser;
GRANT SELECT ON V_SD_Outletflag to itcuser;
GRANT SELECT ON V_SD_OutletFlag_Prod to itcuser;
GRANT SELECT ON V_SD_OutletFlag_ProdDtl to itcuser;
GRANT SELECT ON V_WD_Master TO itcuser;
GRANT SELECT ON V_EANNUMBER TO itcuser;
GRANT SELECT ON V_Invoice_SMS TO itcuser;
GRANT SELECT ON V_Asset_Outlet TO itcuser;
GRANT SELECT ON V_OL_Target_Achievement TO itcuser;
GRANT SELECT ON V_TLC_Target_Achievement TO itcuser;
GRANT SELECT ON V_LaunchItems TO itcuser;
GRANT SELECT ON V_DSPM_TLC_NOA TO itcuser;
GRANT SELECT ON V_DSTypeCategoryMapping TO itcuser;
GRANT SELECT ON V_SKUWise_SOQ TO itcuser;
GRANT SELECT ON V_DS_TypeMaster_v8 TO itcuser;
GRANT SELECT ON V_Customer_Master_v8 TO itcuser;

IF NOT EXISTS (Select hasdbaccess from master..SysUsers
where sid in (select sid from master..syslogins where name = 'itcuser') and hasdbaccess = 1)
begin
EXEC master.dbo.sp_grantdbaccess 'itcuser'
end

End
