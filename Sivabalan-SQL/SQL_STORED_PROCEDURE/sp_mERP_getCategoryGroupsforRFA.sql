Create Procedure sp_mERP_getCategoryGroupsforRFA  
AS  
BEGIN  
 Select distinct Categorygroup from tblcgdivmapping where CategoryGroup in ('GR1','GR2','GR3','GR4')  
END
