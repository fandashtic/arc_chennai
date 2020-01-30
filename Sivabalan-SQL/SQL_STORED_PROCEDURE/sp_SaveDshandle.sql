CREATE Procedure sp_SaveDshandle(@SalesmanId Integer, @DstypeId Integer)
As
Begin
    Delete from Dshandle where SalesmanId = @SalesmanId 
    Insert Into Dshandle 
    Select Distinct @SalesmanId, DsCgm.GroupId, 1 from tbl_mERP_DSTypeCGMapping DsCgm 
        Join ProductCategoryGroupabstract pcga on DsCgm.GroupId = pcga.GroupId 
        where DstypeId = @DstypeId and DsCgm.active = 1 
end    
SET QUOTED_IDENTIFIER ON 
