Create Procedure sp_InsOrUpDate_DSType  
(@SmanID Integer,@DsTypeName nVarchar(100),@DsTypeValue nVarchar(100),@nPos Integer)  
As  
Begin  

    Declare @SManDSTypeID int
    Declare @tblDshandle Table (SalesmanId Int) 

    Declare @Modify As Integer
    Declare @TypeID as Integer  
    If exists ( Select * from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup' and flag = 0 )  
    Begin    
        if @DsTypeValue <> ''   
        Begin   
            if Not Exists(Select * From DsType_Master Where DSTypeName = @DsTypeName and DSTypeValue = @DsTypeValue and DSTypeCtlPos = @nPos and OCGtype = 0)  
            begin  
                Set @Modify = 1 
                Insert Into DsType_Master(DSTypeName,DSTypeValue,DSTypeCtlPos, OCGtype) Values ( @DsTypeName ,@DsTypeValue ,@nPos,0)
                If Not Exists(Select * From DSType_Details Where SalesmanID = @SmanID and DSTypeCtlPos =  @nPos)
                    Insert Into DSType_Details(SalesmanID,DSTypeID,DSTypeCtlPos) Values ( @SmanID,@@Identity,@nPos)  
                else
                    Update DSType_Details Set DSTypeID = @@Identity   Where DSTypeCtlPos = @nPos and SalesmanID = @SmanID   
            end   
            else  
            begin  
                Select @TypeID = DSTypeID From DsType_Master Where DSTypeName = @DsTypeName and DSTypeValue = @DsTypeValue and DSTypeCtlPos = @nPos and OCGtype = 0  
                if Not Exists (Select * From DSType_Details Where SalesmanID = @SmanID AND DSTypeCtlPos =  @nPos)  
                begin  
                    Set @Modify = 1 
                    Insert Into DSType_Details(SalesmanID,DSTypeID,DSTypeCtlPos) Values ( @SmanID,@TypeID,@nPos)  
                end  
                Else  
                begin 
                    if Not Exists (Select * From DSType_Details Where SalesmanID = @SmanID and DSTypeCtlPos =  @nPos and DSTypeID = @TypeID)  
                    Set @Modify = 1  
                    Update DSType_Details Set DSTypeID = @TypeID   Where DSTypeCtlPos = @nPos and SalesmanID = @SmanID   
                end  
            end  
        End  
        Else
        Begin
            If Exists(Select * From DSType_Details Where SalesmanID = @SmanID and DSTypeCtlPos =  @nPos)
                Delete from DSType_Details Where SalesmanID = @SmanID and DSTypeCtlPos =  @nPos
        End
    End    
    Else
    Begin 
        Select @TypeID = DSTypeID From DsType_Master Where DSTypeName = @DsTypeName and DSTypeValue = @DsTypeValue and DSTypeCtlPos = @nPos and IsNull(OCGtype, 0) = ( Case when DSTypeCtlPos = 1 then 1 Else IsNull(OCGtype, 0) End )
        If IsNull(@TypeID, 0) > 0
        Begin
            Delete from DSType_Details Where SalesmanID = @SmanID and DSTypeCtlPos = @nPos        
            Insert Into DSType_Details(SalesmanID, DSTypeID, DSTypeCtlPos) Values ( @SmanID, @TypeID, @nPos)  
        end    

    End
    if Exists(Select * from Beat_Salesman Where SalesManID = @SmanID  and BeatID <> 0 and isnull(CustomerID,'') <> '')
    Begin
        if @Modify = 1
        begin
            Update Salesman Set ModifiedDate = Getdate() Where SalesmanID  = @SmanID
            Update Customer Set ModifiedDate = GetDate() Where isnull(CustomerID,'') IN
            (Select ISNull(CustomerID,'') From Beat_Salesman Where SalesManID = @SmanID and BeatID <> 0)
        end
    End
    --modify Dshandle table for all salesman who are linked to the particular DstypeId ( @DstypeId)
    If ( isNull(@nPos, 0) = 1)
    Begin
        Select @SManDSTypeID = DStypeID from DStype_Details where SalesmanID = @SmanID and DStypeCTlPos = 1
        If IsNull(@SManDSTypeID, 0) <> 0 
        Begin
            Delete from @tblDshandle 
            begin transaction   
                Insert Into @tblDshandle Select distinct SalesmanId from DStype_Details where DstypeId = @SManDSTypeID and SalesmanID = @SmanID
              Delete from Dshandle where SalesmanId In (Select SalesmanId from @tblDshandle)
                Insert Into Dshandle 
                    Select tmp.SalesmanId, DsCgm.GroupId, 1 from tbl_mERP_DSTypeCGMapping DsCgm 
                    Join @tblDshandle tmp on DsCgm.DstypeId = @SManDSTypeID and DsCgm.active = 1                 
            Commit Transaction
        End    
    End
End  
