CREATE FUNCTION [dbo].[Fn_SurveyOutletmapping_Report]() 
RETURNS @temptable TABLE (DSID int,CustomerID nvarchar(50),SurveyID nvarchar(50),Status int)
AS 
BEGIN 
DECLARE @SurveyCode nvarchar(50),@VSurveyID nvarchar(20) 
DECLARE @DSID int,@VDSID nvarchar(60) 
DECLARE @CustomerID nvarchar(30),@VCustomerID nvarchar(30) 
DECLARE @VStatus int 
declare @temp table(SurveyCode nvarchar(50),DSID int,CustomerID nvarchar(30)) 
insert into @temp 
select distinct SM.SurveyCode,DD.SalesmanID As DSID,BS.CustomerID from tbl_merp_SurveyDSMapping DS 
join tbl_merp_SurveyMaster SM on SM.SurveyID=DS.SurveyID 
join DSType_Master DM on isnull(DM.DSTypeValue,'')=DS.DSType 
join DSType_Details DD on isnull(DD.DSTypeId,0)=DM.DSTypeId 
join Beat_Salesman BS on cast(isnull(BS.SalesmanID,0) as nvarchar(60)) =isnull(DD.SalesmanID,'') 
join Salesman S on isnull(BS.SalesmanID,0)=S.SalesmanID
join Customer C on C.CustomerID=BS.CustomerID 
WHERE BS.CustomerID in (select OCM.CustomerID from tbl_merp_SurveyMaster ,tbl_mERP_OLClass OC,tbl_merp_SurveyChannelMapping SCM,tbl_mERP_OLClassMapping OCM 
where isnull(OC.Channel_Type_Desc,'')=SCM.ChannelType 
and isnull(OC.Outlet_Type_Desc,'')=SCM.OutletType 
and isnull(OC.SubOutlet_Type_Desc,'')=SCM.LoyaltyProgram 
and OC.ID=isnull(OCM.OLClassID,0) 
and SM.SurveyID=SCM.SurveyID 
and OCM.Active=1
and OC.Channel_Type_Active=1
and OC.Outlet_Type_Active=1
and OC.SubOutlet_Type_Active=1)  
--and SM.Active=1 
--and DM.Active=1 
--and S.Active=1 
--and C.Active=1
DECLARE V_cursor CURSOR FOR SELECT * from @temp
OPEN V_cursor; 
FETCH NEXT FROM V_cursor INTO @SurveyCode,@DSID,@CustomerID; 
WHILE @@FETCH_STATUS = 0 
BEGIN 
if exists(select * from DSSurveyDetails where @SurveyCode=SurveyID and @DSID=DSID and @CustomerID=CustomerID) 
INSERT INTO @temptable values (@DSID,@CustomerID,@SurveyCode,1) 
ELSE 
INSERT INTO @temptable values (@DSID,@CustomerID,@SurveyCode,0) 
FETCH NEXT FROM V_cursor INTO @SurveyCode, @DSID,@CustomerID; 
END 
CLOSE V_cursor; 
DEALLOCATE V_cursor; 
RETURN 
END
