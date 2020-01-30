
CREATE PROCEDURE sp_GetCategoryGroup
As
--Select Distinct --ProductCategoryGroupAbstract.GroupID, 
--ProductCategoryGroupAbstract.GroupName 
--From ProductCategoryGroupAbstract
If (Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') = 0 
    Select Max(PDA.GroupID) as 'GroupID', TCD.CategoryGroup as 'GroupName'
    From ProductCategoryGroupAbstract PDA, tblCGDivMapping TCD
    Where TCD.CategoryGroup = PDA.GroupName and IsNull(OCGtype, 0) = 0 and active = 1 
    Group By TCD.CategoryGroup
Else
    Select GroupID, GroupName
    From ProductCategoryGroupAbstract 
    Where IsNull(OCGtype, 0) = 1 and active = 1 
    order By Groupid
